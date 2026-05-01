#!/bin/bash

echo "Setting up tmux..."

if [ ! -f "$HOME/.tmux.conf" ]; then
    cat <<'EOF' >> "$HOME/.tmux.conf"
set -g mouse on
set -g history-limit 50000
set -g default-terminal "screen-256color"
set -g default-shell /bin/zsh
set -g mode-keys vi
bind -T copy-mode-vi WheelUpPane send-keys -X -N 2 scroll-up
bind -T copy-mode-vi WheelDownPane select-pane \; send-keys -X -N 2 scroll-down
bind -T root WheelUpPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
bind -T root WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"
EOF
fi