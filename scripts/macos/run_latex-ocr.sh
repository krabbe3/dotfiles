#!/bin/zsh

# this script activates and runs the latex-ocr snipping tool!
# requirements:
#   conda environment name=latex-ocr with pytorch and pix2tex[gui] installed

# initialize conda
source ~/miniforge3/etc/profile.d/conda.sh

# activate conda environment
conda activate latex-ocr
# run latex ocr command
latexocr
