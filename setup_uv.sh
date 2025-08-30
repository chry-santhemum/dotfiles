#!/bin/bash

echo "Installing uv and Python 3.12..."

cd $HOME
curl -L https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.12
uv venv
