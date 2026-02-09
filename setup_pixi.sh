#!/bin/bash

echo "Setting up Pixi..."

curl -fsSL https://pixi.sh/install.sh | sh
export PATH="$HOME/.pixi/bin:$PATH"
