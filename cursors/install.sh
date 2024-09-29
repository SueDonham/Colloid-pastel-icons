#!/bin/bash

ROOT_UID=0
DEST_DIR=
THEME_NAME=Colloid-pastel
# set these as envvars
XCURSOR=${XCURSOR:-1}
HYPRCURSOR=${HYPRCURSOR:-0}
DRY_RUN=${DRY_RUN:-0}

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.icons"
fi

function print_install_info() {
  if [ "$XCURSOR" == "1" ]; then
    install_xcursor="\e[32mYES\e[0m"
  else
    install_xcursor="\e[31mNO\e[0m"
  fi
  if [ "$HYPRCURSOR" == "1" ]; then
    install_hyprcursor="\e[32mYES\e[0m"
  else
    install_hyprcursor="\e[31mNO\e[0m"
  fi
  echo -e "Install xcursor theme? $install_xcursor"
  echo -e "Install hyprcursor theme? $install_hyprcursor"
  if [ "$DRY_RUN" == "1" ]; then
    echo "Dry run, do not install theme"
  fi
}
print_install_info

# Copy light or dark cursor variant to DEST_DIR:
function copy_variant() {
  if [ "$DRY_RUN" != "1" ]; then
    var=$1
    dest_dir=$DEST_DIR/$THEME_NAME-cursors-$var

    if [ -d "$dest_dir" ]; then
      rm -r "$dest_dir"
    fi

    mkdir -p $dest_dir
    cp -r dist-$var/* $dest_dir
  fi
}

cd "$(dirname "$0")"
if [ "$XCURSOR" == "1" ]; then
  copy_variant 'light'
  copy_variant 'dark'
fi
if [ "$HYPRCURSOR" == "1" ]; then
  copy_variant 'hl-light'
  copy_variant 'hl-dark'
fi

echo "Cursors copied to $DEST_DIR"
