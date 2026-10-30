# Supernote Transcriber

Converts Supernote `.note` files into clean, scientific Markdown using `supernotelib` and a local vision model: `qwen3-vl:8b-instruct` via Ollama (default) or olmOCR 2 via `mlx-vlm`.

## Compatibility & Requirements

- **Tested Firmware**: Supernote Chauvet `3.29.42` (A5X2)
- **Ollama**: Installed and running (`ollama pull qwen3-vl:8b-instruct`), for `--model qwen`
- **Apple Silicon**: Required for `--model olmocr`; the 9.5 GB model downloads on first use
- **Conda / Miniforge**: For managing Python dependencies

## Setup

### 1. Create Conda Environment
From this directory:
```bash
conda env create -f environment.yml
```

### 2. Shell Integration
Add the following line to `~/.zshrc`:
```zsh
[[ -f "$HOME/.dotfiles/transcriber/transcribe-notes.zsh" ]] && source "$HOME/.dotfiles/transcriber/transcribe-notes.zsh"
```

## Usage

The `transcribe-notes` function runs the pipeline inside the `note-converter` environment via `conda run`:

```bash
# Single file
transcribe-notes path/to/notebook.note path/to/output_dir/

# Entire directory (recursive)
transcribe-notes path/to/notebooks/ path/to/output_dir

# Use olmOCR 2 instead of Qwen
transcribe-notes --model olmocr path/to/notebook.note path/to/output_dir/
```

Set `TRANSCRIBER_MODEL=olmocr` to change the default. Output files are named after the notebook, so use a separate output directory per model when comparing.

`--model olmocr` uses its own prompt (`prompt_olmocr.md`), so the rules in `prompt.md` do not apply. Tables come out as HTML. It starts `mlx_vlm.server` on port 8080 (override with `MLX_VLM_PORT`).

## Behavior & Cleanup
- Temporary rendered PNG pages are processed and deleted automatically.
- Model weights are evicted from VRAM (`keep_alive: 0`) once conversion finishes.
