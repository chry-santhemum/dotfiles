#!/bin/bash
set -euo pipefail

# Parse arguments
INSTALL_CLAUDE=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --claude)
      INSTALL_CLAUDE=true
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# install node
echo "Installing Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
node -v # Should print "v22.14.0".
nvm current # Should print "v22.14.0".
npm -v # Should print "10.9.2".

# install uv
echo "Installing uv and Python..."
curl -L https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.11
uv venv
source /root/.venv/bin/activate

# run github setup
echo "Setting up GitHub..."
bash dotfiles/github.sh

# system packages
echo "Installing system packages..."
apt-get update
apt-get install -y tmux

# add aliases and environment variables to .bashrc
echo "Configuring shell aliases and environment..."
echo "alias gc='git add . && git commit -m'" >> /root/.bashrc
echo "alias tma='tmux attach -t'" >> /root/.bashrc
echo "alias venv='source /root/.venv/bin/activate'" >> /root/.bashrc
echo "export HF_HOME=/workspace/hf" >> /root/.bashrc
echo "export HF_HUB_ENABLE_HF_TRANSFER=1" >> /root/.bashrc

# install Python packages
echo "Installing Python packages..."
uv pip install "huggingface_hub[cli]"
uv pip install "huggingface-hub[hf-transfer]"
uv pip install "wandb"
uv pip install "ipykernel"
uv pip install "python-dotenv"

# authentication
echo "Setting up authentication..."
huggingface-cli login --token $RUNPOD_HF_TOKEN --add-to-git-credential
wandb login $RUNPOD_WANDB_TOKEN

# coding help (conditional)
if [ "$INSTALL_CLAUDE" = true ]; then
  echo "Installing Claude Code assistant..."
  npm install -g @anthropic-ai/claude-code
else
  echo "Skipping Claude Code installation"
fi

echo "Restarting shell to apply all changes..."
exec bash 

echo "Syncing uv environment..."
cd /workspace/pm-bias
venv
uv sync --active --no-install-package flash-attn
uv sync --active --no-build-isolation
