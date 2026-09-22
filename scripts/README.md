# Scripts

Platform-specific helper scripts.

## Structure

```
scripts/
└── macos/
    └── run_latex-ocr.sh    # LaTeX OCR via pix2tex (macOS)
```

## macOS — LaTeX OCR

`scripts/macos/run_latex-ocr.sh` launches the pix2tex GUI snipping tool for converting math images to LaTeX.

### Requirements

- Miniforge installed at `~/miniforge3`
- Conda environment `latex-ocr` with `pytorch` and `pix2tex[gui]`

### Usage

```bash
source scripts/macos/run_latex-ocr.sh
```

Activates the `latex-ocr` conda env and runs `latexocr`.
