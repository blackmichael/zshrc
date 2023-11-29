#!/bin/sh

DIR=$(dirname "$0")

cp $DIR/zshrc $HOME/.zshrc
cp $DIR/zsh_plugins.txt $HOME/.zsh_plugins.txt

echo
echo "NOTE: zshrc must be sourced."
echo "  source ~/.zshrc"

