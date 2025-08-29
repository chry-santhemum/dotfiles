#!/bin/bash

echo "Configuring iPython autoreload..."
uv pip install "ipykernel"
ipython profile create
cat <<'EOF' >> $HOME/.ipython/profile_default/ipython_config.py
c.InteractiveShellApp.exec_lines = [
    '%load_ext autoreload',
    '%autoreload 2'
]
EOF