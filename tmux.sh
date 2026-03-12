#!/bin/bash

echo "Setting up tmux..."

if [ ! -f "$HOME/.tmux.conf" ]; then
    cat <<'EOF' >> "$HOME/.tmux.conf"
set -g mouse on
set -g history-limit 50000
set -g default-terminal "screen-256color"
set -g default-shell /bin/zsh
EOF
fi