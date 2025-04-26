#!/bin/bash

# Input arguments
email=${1:-"zifanawang04@gmail.com"}
name=${2:-"chry-santhemum"}
github_url=${3:-""}

# Setup git
git config --global user.email "$email"
git config --global user.name "$name"
git config --global credential.helper 'store --file=/workspace/.git-credentials'
