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


echo "Installing Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 24
node -v
npm -v


source $HOME/dotfiles/github.sh
source $HOME/dotfiles/setup_uv.sh
source $HOME/dotfiles/tmux.sh
source $HOME/dotfiles/setup_zsh.sh


if [ "$INSTALL_CLAUDE" = true ]; then
  echo "Installing Claude Code"
  npm install -g @anthropic-ai/claude-code
else
  echo "Skipping Claude Code installation"
fi

echo "Setup complete! Restarting zsh shell..."
exec zsh
