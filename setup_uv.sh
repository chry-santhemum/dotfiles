
#!/bin/bash

echo "Installing uv and Python 3.12..."

cd $HOME
curl -L https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.12
uv venv
source .venv/bin/activate

echo "Configuring hf and wandb..."

uv pip install "huggingface_hub" "wandb"
hf auth login --token $RUNPOD_HF_TOKEN --add-to-git-credential
wandb login $RUNPOD_WANDB_TOKEN
