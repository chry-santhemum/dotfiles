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

source $HOME/dotfiles/setup_node.sh
source $HOME/dotfiles/setup_uv.sh
source $HOME/dotfiles/github.sh

echo "Installing system packages..."
if [[ $(id -u) -ne 0 ]]; then
  echo "Requesting sudo for package installation..."
  sudo apt-get update && sudo apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq tmux zsh
else
  apt-get update && apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq tmux zsh sudo
fi

source $HOME/dotfiles/auth.sh
source $HOME/dotfiles/autoreload.sh
source $HOME/dotfiles/setup_zsh.sh
source $HOME/dotfiles/tmux.sh

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
