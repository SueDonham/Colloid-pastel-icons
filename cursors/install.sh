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

# Ensure user is in the right dir:
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
[[ "$PWD" != "$SCRIPT_DIR" ]] && cd "$SCRIPT_DIR"


# Select which theme(s) to install:
read -p $'Install Xcursor, hyprcursor, or both?\n1) Xcursor\n2) hyprcursor\n3) Both\nEnter selection [1|2|3]: ' format
case $format in
	1) XCURSOR=true ;;
	2) HYPRCURSOR=true ;;
	3) XCURSOR=true && HYPRCURSOR=true ;;
	*) echo "Invalid selection; exiting" && exit ;;
esac


# Copy light or dark cursor variant to DEST_DIR:
copy_variant() {
	var=$1
	dest_dir="$DEST_DIR/$THEME_NAME-cursors-$var"

	[[ -d "$dest_dir" ]] && rm -r "$dest_dir"

	mkdir -p $dest_dir
	cp -r dist-$var/* $dest_dir
}


if [[ "$XCURSOR" ]] ; then
  copy_variant 'light'
  copy_variant 'dark'
fi

if [[ "$HYPRCURSOR" ]] ; then
  copy_variant 'hl-light'
  copy_variant 'hl-dark'
fi

echo "Cursors copied to $DEST_DIR"
