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

bash $HOME/dotfiles/setup_node.sh
bash $HOME/dotfiles/setup_uv.sh
bash $HOME/dotfiles/github.sh

echo "Installing system packages..."
if [[ $(id -u) -ne 0 ]]; then
  echo "Requesting sudo for package installation..."
  sudo apt-get update && sudo apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq tmux zsh
else
  apt-get update && apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq tmux zsh sudo
fi

bash $HOME/dotfiles/auth.sh
bash $HOME/dotfiles/autoreload.sh
bash $HOME/dotfiles/setup_zsh.sh
bash $HOME/dotfiles/tmux.sh

if [ "$INSTALL_CLAUDE" = true ]; then
  echo "Installing Claude Code assistant..."
  npm install -g @anthropic-ai/claude-code
else
  echo "Skipping Claude Code installation"
fi

echo "Syncing uv environment..."
cd /workspace/rm-bias
source $HOME/.venv/bin/activate
uv sync --active --no-install-package flash-attn
uv sync --active --no-build-isolation

echo "Setup complete! Restarting shell with Zsh to apply all changes..."
exec zsh
