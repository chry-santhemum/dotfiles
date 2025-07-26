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
source $HOME/.venv/bin/activate

# run github setup
echo "Setting up GitHub..."
bash dotfiles/github.sh

# system packages
echo "Installing system packages..."
apt-get update
apt install -y tmux
apt install -y rsync

# add aliases and environment variables to .bashrc
echo "Configuring shell aliases and environment..."
echo "alias gs='git status'" >> $HOME/.bashrc
echo "alias gc='git add . && git commit -m'" >> $HOME/.bashrc
echo "alias tma='tmux attach -t'" >> $HOME/.bashrc
echo "alias venv='source $HOME/.venv/bin/activate'" >> $HOME/.bashrc
echo "alias tb='tensorboard --host=0.0.0.0 --port=6006'" >> $HOME/.bashrc
echo "export HF_HOME=/workspace/hf" >> $HOME/.bashrc
echo "export HF_HUB_ENABLE_HF_TRANSFER=1" >> $HOME/.bashrc
echo "alias rsync_mats='rsync -avz /workspace/checkpoints/ $RUNPOD_MATS_USER@$RUNPOD_MATS_HOST:/$RUNPOD_MATS_PATH'" >> $HOME/.bashrc

# install Python packages
echo "Installing Python packages..."
uv pip install "huggingface_hub[cli]"
uv pip install "huggingface-hub[hf-transfer]"
uv pip install "wandb"
uv pip install "ipykernel"
uv pip install "python-dotenv"

# authentication
echo "Setting up authentication..."
hf auth login --token $RUNPOD_HF_TOKEN --add-to-git-credential
wandb login $RUNPOD_WANDB_TOKEN

# ipython autoreload
ipython profile create
echo "c.InteractiveShellApp.exec_lines = []" >> $HOME/.ipython/profile_default/ipython_config.py
echo "c.InteractiveShellApp.exec_lines.append('%load_ext autoreload')" >> $HOME/.ipython/profile_default/ipython_config.py
echo "c.InteractiveShellApp.exec_lines.append('%autoreload 2')" >> $HOME/.ipython/profile_default/ipython_config.py

# coding help (conditional)
if [ "$INSTALL_CLAUDE" = true ]; then
  echo "Installing Claude Code assistant..."
  npm install -g @anthropic-ai/claude-code
else
  echo "Skipping Claude Code installation"
fi

echo "Syncing uv environment..."
cd /workspace/pm-bias
source $HOME/.venv/bin/activate
uv sync --active --no-install-package flash-attn
uv sync --active --no-build-isolation

echo "Restarting shell to apply all changes..."
exec bash 