
#!/bin/bash

echo "Configuring hf and wandb..."

uv run --with huggingface_hub hf auth login --token $HF_TOKEN --add-to-git-credential
uv run --with wandb wandb login $WANDB_API_KEY
