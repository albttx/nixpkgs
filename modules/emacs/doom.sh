#!/bin/sh

DOOM_DIR="$HOME/.config/emacs"

if [ ! -d "$DOOM_DIR" ]; then
  /usr/bin/git clone https://github.com/hlissner/doom-emacs.git $DOOM_DIR
  $DOOM_DIR/bin/doom -y install
else
  $DOOM_DIR/bin/doom sync
fi
