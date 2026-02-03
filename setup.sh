#!/bin/bash
set -euo pipefail

# Parse arguments
INSTALL_CLAUDE=true
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-claude)
      INSTALL_CLAUDE=false
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo "Installing Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 24
node -v
npm -v

echo "Installing system packages..."
if [[ $(id -u) -ne 0 ]]; then
  echo "Requesting sudo for package installation..."
  sudo apt-get update && sudo apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq tmux zsh unzip
else
  apt-get update && apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq tmux zsh sudo unzip
fi

source $HOME/dotfiles/github.sh
source $HOME/dotfiles/setup_uv.sh
source $HOME/dotfiles/autoreload.sh
source $HOME/dotfiles/setup_zsh.sh
source $HOME/dotfiles/tmux.sh

# Claude Code installation
if [ "$INSTALL_CLAUDE" = true ]; then
  echo "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
  # npm i -g @openai/codex
else
  echo "Skipping Claude Code installation"
fi

echo "Setup complete! Restarting shell with Zsh to apply all changes..."
exec zsh
