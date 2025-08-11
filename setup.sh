
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

# --- Initial Installations ---
echo "Installing Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
# Source nvm for the current script session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22
node -v
npm -v

echo "Installing uv and Python..."
curl -L https://astral.sh/uv/install.sh | sh
# Source uv for the current script session
source $HOME/.local/bin/env
uv python install 3.11
uv venv
source $HOME/.venv/bin/activate

echo "Setting up GitHub..."
bash $HOME/dotfiles/github.sh

echo "Installing system packages..."
if [[ $(id -u) -ne 0 ]]; then
  echo "Requesting sudo for package installation..."
  sudo apt-get update && sudo apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq tmux zsh
else
  apt-get update && apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq tmux zsh sudo
fi

# --- Configure Zsh & .zshrc ---
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

# Source uv (Python environment)
source $HOME/.local/bin/env

# Aliases
alias gs='git status'
alias gc='git add . && git commit -m'
alias gps='git push'
alias gpl='git pull'
alias tma='tmux attach -t'
alias venv='source $HOME/.venv/bin/activate'
alias tb='tensorboard --host=0.0.0.0 --port=6006'
alias rsync_mats='rsync -avz /workspace/checkpoints/ $RUNPOD_MATS_USER@$RUNPOD_MATS_HOST:/$RUNPOD_MATS_PATH'
EOF

cat <<'EOF' >> $HOME/.zshenv

export ZSH="$HOME/.oh-my-zsh"
export NVM_DIR="$HOME/.nvm"

# HF Environment Variables
export HF_HOME="/workspace/hf"
export HF_HUB_ENABLE_HF_TRANSFER=1
EOF

# Set Zsh as the default shell for the user
sudo chsh -s $(which zsh) $(whoami)

# --- Python and Auth ---
echo "Installing Python packages..."
uv pip install "huggingface_hub[cli,hf-transfer]" "wandb" "ipykernel" "python-dotenv"

echo "Setting up authentication..."
hf auth login --token $RUNPOD_HF_TOKEN --add-to-git-credential
wandb login $RUNPOD_WANDB_TOKEN

echo "Configuring iPython autoreload..."
ipython profile create
cat <<'EOF' >> $HOME/.ipython/profile_default/ipython_config.py
c.InteractiveShellApp.exec_lines = [
    '%load_ext autoreload',
    '%autoreload 2'
]
EOF

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

echo "Setting up tmux..."
touch $HOME/.tmux.conf
cat <<'EOF' >> $HOME/.tmux.conf
set-option -g default-command "zsh"
EOF

# --- Final Step ---
echo "Setup complete! Restarting shell with Zsh to apply all changes..."
exec zsh