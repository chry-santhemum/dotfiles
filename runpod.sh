
#!/bin/bash
set -euo pipefail

# install node for vscode
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"
# Download and install Node.js:
nvm install 22
# Verify the Node.js version:
node -v # Should print "v22.14.0".
nvm current # Should print "v22.14.0".
# Verify npm version:
npm -v # Should print "10.9.2".

# 1) Install uv and create virtual environment
curl -L https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# expects the data directory to be synced to /root/ocr/data
export HF_HOME="/root/ocr/data/hf"
export HF_HUB_ENABLE_HF_TRANSFER=1

git clone https://github.com/chry-santhemum/ocr.git

cd ocr

# this will create a virtual environment and install the dependencies
uv sync

source .venv/bin/activate
# # Setup git so huggingface works
git config --global user.email "o.clivegriffin@gmail.com"
git config --global user.name "oli-clive-griffin"
git config --global credential.helper store
huggingface-cli login --token $RUNPOD_HF_TOKEN --add-to-git-credential
wandb login $RUNPOD_WANDB_TOKEN

echo "\n\n Setup complete. Please source the virtual environment with:\nsource .venv/bin/activate"
