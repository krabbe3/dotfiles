# Supernote Transcriber

Converts Supernote `.note` files into clean, scientific Markdown using `supernotelib` and a local vision model (`qwen3-vl:8b-instruct`) via Ollama.

## Compatibility & Requirements

- **Tested Firmware**: Supernote Chauvet `3.29.42` (A5X2)
- **Ollama**: Installed and running (`ollama pull qwen3-vl:8b-instruct`)
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
```

## Behavior & Cleanup
- Temporary rendered PNG pages are processed and deleted automatically.
- Model weights are evicted from VRAM (`keep_alive: 0`) once conversion finishes.
