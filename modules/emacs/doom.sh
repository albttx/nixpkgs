#!/bin/sh

DOOM_DIR="$HOME/.config/emacs"

if [ ! -d "$DOOM_DIR" ]; then
  /usr/bin/git clone --recurse-submodules https://github.com/doomemacs/core.git $DOOM_DIR
  $DOOM_DIR/bin/doom -y install
else
  /usr/bin/git -C "$DOOM_DIR" submodule update -f --init --recursive
  $DOOM_DIR/bin/doom sync
fi
