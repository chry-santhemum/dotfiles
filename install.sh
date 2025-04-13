#!/bin/bash

# 1) Install packages
apt-get update
apt-get install -y tmux

# 2) Add aliases and environment variables to .bashrc
echo "alias gc='git add . && git commit -m'" >> /root/.bashrc
echo "alias tma='tmux attach -t'" >> /root/.bashrc
echo "alias venv='source /root/.venv/bin/activate'" >> /root/.bashrc

echo "export HF_HOME=/workspace/hf" >> /root/.bashrc
echo "export HF_HUB_ENABLE_HF_TRANSFER=1" >> /root/.bashrc

source /root/.bashrc

# 3) Set up huggingface cache at /workspace/hf
uv pip install -U "huggingface_hub[cli]"
uv pip install -U "huggingface-hub[hf-transfer]"
uv pip install -U wandb
source .venv/bin/activate

huggingface-cli login --token $RUNPOD_HF_TOKEN --add-to-git-credential
wandb login $RUNPOD_WANDB_TOKEN