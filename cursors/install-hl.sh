#!/bin/bash

echo -e "install-hl.sh is supposed to be run from Colloid-pastel-icons/cursors/\nIf it is not true, cd into cursors first"

if [ "$ICONS" = "" ]; then
	ICONS="${1:-$HOME/.local/share/icons}"
fi
echo -e "Theme will be installed into $ICONS\nProvide ICONS envvar or specify first argument to change installation path"

if [ ! -d "dist-hl-light" -o ! -d "dist-hl-dark" ]; then
	if ! which "./build-hl.sh" >/dev/null 2>&1; then
		echo -e "build-hl.sh not found, unable to continue.\nIf you have your theme built already, just copy it into $ICONS to install"
		exit 1
	fi
	./build-hl.sh
fi
echo -e "Prebuilt light theme found, copying it into $ICONS"
cp -r dist-hl-light "$ICONS/Colloid-pastel-cursors-light-hy"
echo -e "Prebuilt dark theme found, copying it into $ICONS"
cp -r dist-hl-dark "$ICONS/Colloid-pastel-cursors-dark-hy"

