#!/bin/bash
set -euo pipefail

# install node for vscode
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
node -v # Should print "v22.14.0".
nvm current # Should print "v22.14.0".
npm -v # Should print "10.9.2".

# install uv
curl -L https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.11
uv venv

# run setup scripts
bash dotfiles/github.sh
source dotfiles/install.sh

# clone repos
cd /workspace
git clone https://github.com/chry-santhemum/ocr || true
set +u
source /root/.bashrc
set -u