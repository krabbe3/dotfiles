#!/usr/bin/env python3
import argparse
import base64
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from PIL import Image, ImageEnhance
import requests
from supernotelib import parser
from supernotelib.converter import ImageConverter

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "localhost:11434")
QWEN_MODEL = "qwen3-vl:8b-instruct"
MLX_HOST = f"127.0.0.1:{os.getenv('MLX_VLM_PORT', '8080')}"
OLMOCR_MODEL = "mlx-community/olmOCR-2-7B-1025-8bit"


# Resolve prompt files sitting in the same directory as this script
PROMPT_DIR = Path(__file__).resolve().parent


def load_prompt(filename: str) -> str:
    prompt_file = PROMPT_DIR / filename
    if not prompt_file.is_file():
        raise FileNotFoundError(f"Prompt file not found at: {prompt_file}")
    return prompt_file.read_text(encoding="utf-8").strip()


MODELS = {
    "qwen": {
        "name": QWEN_MODEL,
        "api_url": f"http://{OLLAMA_HOST}/v1/chat/completions",
        "prompt": load_prompt("prompt.md"),
        "temperature": 0.0,
        "timeout": 180,
        "max_side": None,
        "extra_params": {"keep_alive": "5m"},
    },
    "olmocr": {
        "name": OLMOCR_MODEL,
        "api_url": f"http://{MLX_HOST}/v1/chat/completions",
        "prompt": load_prompt("prompt_olmocr.md"),
        "temperature": 0.1,
        "timeout": 600,
        "max_side": 1288,  # olmOCR expects this longest dimension
        "extra_params": {"max_tokens": 8000},
    },
}


def ensure_model_available():
    """Checks if QWEN_MODEL is present locally; pulls it automatically if missing."""
    try:
        res = requests.get(f"http://{OLLAMA_HOST}/api/tags", timeout=5)
        if res.status_code == 200:
            installed = [m["name"] for m in res.json().get("models", [])]
            # Match exact name or base tag without :latest
            if any(QWEN_MODEL in m for m in installed):
                print(
                    f"Model '{QWEN_MODEL}' found. Continuing transcription..."
                )
                return
    except Exception:
        pass

    print(
        f"Model '{QWEN_MODEL}' not found locally. Pulling now (one-time setup)..."
    )
    subprocess.run(["ollama", "pull", QWEN_MODEL], check=True)


def ensure_ollama_running() -> subprocess.Popen | None:
    """Starts 'ollama serve' as a background subprocess if not already accessible."""
    try:
        r = requests.get(f"http://{OLLAMA_HOST}/api/version", timeout=1.0)
        if r.status_code == 200:
            return None
    except Exception:
        pass

    print("Ollama daemon is not running. Starting 'ollama serve'...")
    proc = subprocess.Popen(
        ["ollama", "serve"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    for _ in range(25):
        try:
            r = requests.get(f"http://{OLLAMA_HOST}/api/version", timeout=0.5)
            if r.status_code == 200:
                print("Ollama daemon is ready.")
                return proc
        except Exception:
            time.sleep(0.5)

    proc.terminate()
    raise RuntimeError(
        "Failed to connect to Ollama daemon after launching 'ollama serve'."
    )


def ensure_mlx_server_running() -> subprocess.Popen | None:
    """Starts mlx_vlm.server if needed. The first run downloads the model."""
    try:
        r = requests.get(f"http://{MLX_HOST}/health", timeout=1.0)
        if r.status_code == 200:
            return None
    except Exception:
        pass

    print(f"Starting mlx_vlm.server with {OLMOCR_MODEL}...")
    proc = subprocess.Popen(
        [
            sys.executable,
            "-m",
            "mlx_vlm.server",
            "--model",
            OLMOCR_MODEL,
            "--host",
            MLX_HOST.split(":")[0],
            "--port",
            MLX_HOST.split(":")[1],
        ],
        stdout=subprocess.DEVNULL,
    )

    # /health only answers once the model is downloaded and loaded
    for _ in range(1800):
        if proc.poll() is not None:
            raise RuntimeError(
                f"mlx_vlm.server exited with code {proc.returncode}."
            )
        try:
            r = requests.get(f"http://{MLX_HOST}/health", timeout=1.0)
            if r.status_code == 200:
                print("MLX server is ready.")
                return proc
        except Exception:
            pass
        time.sleep(1)

    proc.terminate()
    raise RuntimeError("Timed out waiting for mlx_vlm.server to load.")


def unload_model(model_key: str):
    """Forces the serving backend to evict model weights from unified memory."""
    name = MODELS[model_key]["name"]
    try:
        print(f"Evicting {name} from VRAM...")
        if model_key == "olmocr":
            res = requests.post(f"http://{MLX_HOST}/unload", timeout=10)
        else:
            res = requests.post(
                f"http://{OLLAMA_HOST}/api/generate",
                json={"model": name, "keep_alive": 0},
                timeout=10,
            )
        if res.status_code == 200:
            print("VRAM successfully cleared.")
    except Exception as e:
        print(f"Warning: Failed to unload model: {e}")


def export_note_to_png_folder(
    note_path: Path, output_dir: Path
) -> tuple[Path, list[Path]]:
    """Renders all pages of a .note file into a temporary-style subfolder using supernotelib."""
    png_folder = output_dir / f"{note_path.stem}_temp_pngs"
    png_folder.mkdir(parents=True, exist_ok=True)

    notebook = parser.load_notebook(note_path)
    converter = ImageConverter(notebook)
    total_pages = notebook.get_total_pages()
    png_files = []

    print(f"  Extracting {total_pages} page(s)...")
    for idx in range(total_pages):
        page_img = converter.convert(idx)
        out_path = png_folder / f"page_{idx + 1:03d}.png"
        page_img.save(out_path, format="PNG")
        png_files.append(out_path)

    return png_folder, png_files


def preprocess_image(src: Path, max_side: int | None = None) -> Path:
    """Enhances contrast on fine strokes and sub/superscripts."""
    prep_path = src.parent / f"prep_{src.name}"
    with Image.open(src) as img:
        gray = img.convert("L")
        enhancer = ImageEnhance.Contrast(gray)
        contrasted = enhancer.enhance(1.35)
        if max_side:
            contrasted.thumbnail((max_side, max_side))
        contrasted.save(prep_path, format="PNG")
    return prep_path


def clean_latex(text: str) -> str:
    """Fixes JSON double-escapes, strips inner math whitespace, and removes fences."""
    # 1. Fix double-escaped LaTeX commands (\\\\frac -> \\frac)
    text = re.sub(r"\\\\([a-zA-Z]+)", r"\\\1", text)

    # 2. Fix inline math whitespace: "$ x $" -> "$x$"
    # Matches single dollar signs (not $$ block math) and trims inner whitespace
    text = re.sub(
        r"(?<!\$)\$(?!\$)\s*([^\$\n]+?)\s*(?<!\$)\$(?!\$)", r"$\1$", text
    )

    # 3. Strip accidental outer markdown fences
    if text.startswith("```markdown"):
        text = text.removeprefix("```markdown").removesuffix("```").strip()
    elif text.startswith("```"):
        text = text.removeprefix("```").removesuffix("```").strip()

    return text


def normalize_olmocr(text: str) -> str:
    """Drops olmOCR's YAML front matter and converts math delimiters to $."""
    text = re.sub(r"\A\s*---\n.*?\n---\s*", "", text, flags=re.DOTALL)
    # The lookbehind keeps LaTeX line breaks like \\[2pt] intact
    text = re.sub(r"(?<!\\)\\\((.+?)\\\)", r"$\1$", text, flags=re.DOTALL)
    text = re.sub(r"(?<!\\)\\\[(.+?)\\\]", r"$$\1$$", text, flags=re.DOTALL)
    return text


def transcribe_page(img_path: Path, page_num: int, model_key: str) -> str:
    model = MODELS[model_key]
    with open(img_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("utf-8")

    prompt = model["prompt"]
    if model_key == "qwen":
        prompt = f"Page {page_num}:\n{prompt}"

    payload = {
        "model": model["name"],
        "temperature": model["temperature"],
        **model["extra_params"],
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": prompt,
                    },
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/png;base64,{b64}"},
                    },
                ],
            }
        ],
    }
    res = requests.post(
        model["api_url"], json=payload, timeout=model["timeout"]
    )
    res.raise_for_status()
    raw = res.json()["choices"][0]["message"]["content"]
    if model_key == "olmocr":
        raw = normalize_olmocr(raw)
    return clean_latex(raw)


def process_single_note(note_path: Path, out_dir: Path, model_key: str):
    print(f"\nProcessing notebook: {note_path.name}")
    out_dir.mkdir(parents=True, exist_ok=True)
    target_md = out_dir / f"{note_path.stem}.md"

    png_folder, png_files = export_note_to_png_folder(note_path, out_dir)
    if not png_files:
        print("  No pages found to transcribe.")
        if png_folder.exists():
            shutil.rmtree(png_folder)
        return

    try:
        md_output = [f"# {note_path.stem}\n"]
        for idx, page_path in enumerate(png_files, start=1):
            print(f"  Transcribing page {idx}/{len(png_files)}...")
            prep_img = preprocess_image(
                page_path, MODELS[model_key]["max_side"]
            )
            try:
                content = transcribe_page(prep_img, idx, model_key)
                if content.strip():
                    md_output.append(content.strip())
            finally:
                if prep_img.exists():
                    prep_img.unlink()

        target_md.write_text("\n\n".join(md_output) + "\n", encoding="utf-8")
        print(f"Saved Markdown to: {target_md}")

    finally:
        if png_folder.exists():
            print(f"Cleaning up temporary images: {png_folder.name}")
            shutil.rmtree(png_folder)


def main():
    arg_parser = argparse.ArgumentParser(
        description="Transcribe Supernote .note files into Markdown."
    )
    arg_parser.add_argument("src", help="A .note file or directory of notes")
    arg_parser.add_argument("out_dir", help="Output directory")
    arg_parser.add_argument(
        "--model",
        choices=MODELS,
        default=os.getenv("TRANSCRIBER_MODEL", "qwen"),
        help="Vision model (default: $TRANSCRIBER_MODEL, else qwen)",
    )
    args = arg_parser.parse_args()

    src = Path(args.src).expanduser()
    dst = Path(args.out_dir).expanduser()
    model_key = args.model

    if model_key == "olmocr":
        server_proc = ensure_mlx_server_running()
    else:
        server_proc = ensure_ollama_running()
        ensure_model_available()
    print(
        f"Pipeline running using model: {MODELS[model_key]['name']} "
        f"at {MODELS[model_key]['api_url']}"
    )

    try:
        if src.is_file() and src.suffix == ".note":
            process_single_note(src, dst, model_key)
        elif src.is_dir():
            notes = sorted(src.rglob("*.note"))
            if not notes:
                print(f"No .note files found in {src}")
                return
            for note in notes:
                process_single_note(note, dst, model_key)
        else:
            print(f"Invalid input path: {src}")
    finally:
        unload_model(model_key)
        if server_proc:
            print("Terminating spawned model server...")
            server_proc.terminate()
            server_proc.wait()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nAborted by user.")
        sys.exit(130)
