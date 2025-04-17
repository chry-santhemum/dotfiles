#!/bin/bash

# 1) Install uv and create virtual environment
curl -L https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.11
uv venv

# 2) Assuming repo is cloned, run setup scripts
bash dotfiles/github.sh
source dotfiles/install.sh

# 3) Clone the current working repo
cd /workspace
git clone https://github.com/chry-santhemum/ocr
# uv pip install -r requirements.txt
