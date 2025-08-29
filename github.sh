#!/bin/bash

echo "Setting up GitHub..."

email=${1:-"zifanawang04@gmail.com"}
name=${2:-"chry-santhemum"}

git config --global user.email "$email"
git config --global user.name "$name"
git config --global init.defaultBranch "main"
git config --global credential.helper 'store --file=/workspace/.git-credentials'
