#!/bin/bash

echo "Setting up tmux..."

if [ ! -f "$HOME/.tmux.conf" ]; then
    touch $HOME/.tmux.conf
    cat <<'EOF' >> $HOME/.tmux.conf
set-option -g default-command "zsh"
EOF
fi