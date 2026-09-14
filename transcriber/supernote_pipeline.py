#!/usr/bin/env python3
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
MODEL_NAME = "qwen3-vl:8b-instruct"
API_URL = f"http://{OLLAMA_HOST}/v1/chat/completions"


# Resolve the prompt file sitting in the same directory as this script
PROMPT_FILE = Path(__file__).resolve().parent / "prompt.md"


def load_system_prompt() -> str:
    if not PROMPT_FILE.is_file():
        raise FileNotFoundError(
            f"System prompt file not found at: {PROMPT_FILE}"
        )
    return PROMPT_FILE.read_text(encoding="utf-8").strip()


SYSTEM_PROMPT = load_system_prompt()


def ensure_model_available():
    """Checks if MODEL_NAME is present locally; pulls it automatically if missing."""
    try:
        res = requests.get(f"http://{OLLAMA_HOST}/api/tags", timeout=5)
        if res.status_code == 200:
            installed = [m["name"] for m in res.json().get("models", [])]
            # Match exact name or base tag without :latest
            if any(MODEL_NAME in m for m in installed):
                print(
                    f"Model '{MODEL_NAME}' found. Continuing transcription..."
                )
                return
    except Exception:
        pass

    print(
        f"Model '{MODEL_NAME}' not found locally. Pulling now (one-time setup)..."
    )
    subprocess.run(["ollama", "pull", MODEL_NAME], check=True)


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


def unload_model():
    """Forces Ollama to evict model weights from unified memory."""
    try:
        print(f"Evicting {MODEL_NAME} from VRAM...")
        res = requests.post(
            f"http://{OLLAMA_HOST}/api/generate",
            json={"model": MODEL_NAME, "keep_alive": 0},
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


def preprocess_image(src: Path) -> Path:
    """Enhances contrast on fine strokes and sub/superscripts."""
    prep_path = src.parent / f"prep_{src.name}"
    with Image.open(src) as img:
        gray = img.convert("L")
        enhancer = ImageEnhance.Contrast(gray)
        contrasted = enhancer.enhance(1.35)
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


def transcribe_page(img_path: Path, page_num: int) -> str:
    with open(img_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("utf-8")

    payload = {
        "model": MODEL_NAME,
        "temperature": 0.0,
        "keep_alive": "5m",
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": f"Page {page_num}:\n{SYSTEM_PROMPT}",
                    },
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/png;base64,{b64}"},
                    },
                ],
            }
        ],
    }
    res = requests.post(API_URL, json=payload, timeout=180)
    res.raise_for_status()
    raw = res.json()["choices"][0]["message"]["content"]
    return clean_latex(raw)


def process_single_note(note_path: Path, out_dir: Path):
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
            prep_img = preprocess_image(page_path)
            try:
                content = transcribe_page(prep_img, idx)
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
    if len(sys.argv) < 3:
        print(
            "Usage: python supernote_pipeline.py <file.note | directory_of_notes> <out_dir>"
        )
        sys.exit(1)

    src = Path(sys.argv[1]).expanduser()
    dst = Path(sys.argv[2]).expanduser()

    ollama_proc = ensure_ollama_running()
    ensure_model_available()
    print(
        f"Pipeline running using model: {MODEL_NAME} at http://{OLLAMA_HOST}"
    )

    try:
        if src.is_file() and src.suffix == ".note":
            process_single_note(src, dst)
        elif src.is_dir():
            notes = sorted(src.rglob("*.note"))
            if not notes:
                print(f"No .note files found in {src}")
                return
            for note in notes:
                process_single_note(note, dst)
        else:
            print(f"Invalid input path: {src}")
    finally:
        unload_model()
        if ollama_proc:
            print("Terminating spawned Ollama daemon...")
            ollama_proc.terminate()
            ollama_proc.wait()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nAborted by user.")
        unload_model()
        sys.exit(130)
