#!/bin/bash

echo "Configuring Zsh, Oh My Zsh, and Powerlevel10k..."

# Remove previous installations to ensure a clean slate
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Found existing Oh My Zsh installation. Removing for a clean reinstall..."
  rm -rf "$HOME/.oh-my-zsh"
fi
if [ -f "$HOME/.zshrc" ]; then
  echo "Found existing .zshrc file. Backing it up to .zshrc.bak..."
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
if [ -f "$HOME/.p10k.zsh" ]; then
    rm -f "$HOME/.p10k.zsh"
fi

# Install Oh My Zsh non-interactively
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Copy your pre-configured .p10k.zsh file
echo "Copying pre-configured Powerlevel10k theme file..."
cp $HOME/dotfiles/.p10k.zsh $HOME/.p10k.zsh

# Create .zshrc from scratch with the correct structure
echo "Creating .zshrc with Instant Prompt and custom configurations..."
cat <<'EOF' > $HOME/.zshrc
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Oh My Zsh Configuration ---
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set the Powerlevel10k theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Standard Oh My Zsh settings
plugins=(git)
source $ZSH/oh-my-zsh.sh

# To customize Powerlevel10k, uncomment the following line:
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Custom User Configuration ---

# Source NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias gs='git status'
alias gc='git add . && git commit -m'
alias gps='git push'
alias gpl='git pull'
alias tma='tmux attach -t'
alias tb='tensorboard --host=0.0.0.0 --port=6006'
alias cdsp='IS_SANDBOX=1 claude --dangerously-skip-permissions'
alias rsync_mats='rsync -avz /workspace/checkpoints/ $RUNPOD_MATS_USER@$RUNPOD_MATS_HOST:/$RUNPOD_MATS_PATH'

# Pixi
export PATH="$HOME/.pixi/bin:$PATH"
if command -v pixi &>/dev/null; then
  eval "$(pixi completion --shell zsh)"
fi
EOF

cat <<'EOF' > $HOME/.zshenv
export ZSH="$HOME/.oh-my-zsh"
export NVM_DIR="$HOME/.nvm"

# HF Environment Variables
export HF_HOME="/root/hf"
export CLAUDE_CONFIG_DIR="/workspace/.claude"
EOF

# Set Zsh as the default shell for the user
sudo chsh -s $(which zsh) $(whoami)
