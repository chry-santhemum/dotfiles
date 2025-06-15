#!/bin/bash

apt-get update
apt-get install -y tmux

# add aliases and environment variables to .bashrc
echo "alias gc='git add . && git commit -m'" >> /root/.bashrc
echo "alias tma='tmux attach -t'" >> /root/.bashrc
echo "alias venv='source /root/.venv/bin/activate'" >> /root/.bashrc
echo "export HF_HOME=/workspace/hf" >> /root/.bashrc
echo "export HF_HUB_ENABLE_HF_TRANSFER=1" >> /root/.bashrc
set +u
source /root/.bashrc
set -u

source /root/.venv/bin/activate

# install packages
uv pip install "huggingface_hub[cli]"
uv pip install "huggingface-hub[hf-transfer]"
uv pip install "wandb"
uv pip install "ipykernel"
uv pip install "python-dotenv"

huggingface-cli login --token $RUNPOD_HF_TOKEN --add-to-git-credential
wandb login $RUNPOD_WANDB_TOKEN

# coding help
npm install -g @anthropic-ai/claude-code