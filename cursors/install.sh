#!/bin/bash

ROOT_UID=0
DEST_DIR=
THEME_NAME=Colloid-pastel

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.icons"
fi




# Copy light or dark cursor variant to DEST_DIR:
copy_variant(){
var=$1
dest_dir=$DEST_DIR/$THEME_NAME-cursors-$var


if [ -d "$dest_dir" ]; then
  rm -r "$dest_dir"
fi

mkdir -p $dest_dir
cp -r dist-$var/* $dest_dir
}


cd "$(dirname "$0")"
copy_variant 'light'
copy_variant 'dark'

echo "Cursors copied to $DEST_DIR"

