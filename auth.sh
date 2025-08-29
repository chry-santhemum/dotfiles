#!/bin/bash

echo "Installing hf and wandb python packages..."
uv pip install "huggingface_hub[cli,hf-transfer]" "wandb"

echo "Setting up hf authentication..."
hf auth login --token $RUNPOD_HF_TOKEN --add-to-git-credential

echo "Setting up wandb authentication..."
wandb login $RUNPOD_WANDB_TOKEN