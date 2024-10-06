#!/bin/bash

# warning: this script removes your files if you run script in wrong directory

# Ensure user is in the right dir:
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
[[ "$PWD" != "$SCRIPT_DIR" ]] && echo -e "build-hl.sh is supposed to be run from Colloid-pastel-icons/cursors/\nIf it is not true, cd into cursors first" && exit 1

if ! which hyprcursor-util >/dev/null 2>&1; then
	echo "You need \`hyprcursor-util\` to be available to build hyprcursor theme"
	exit 1
fi

if ! which bc >/dev/null 2>&1; then
	echo "Please install \`bc\`. It is needed to calculate resolutions and other valuable stuff"
	exit 2
fi

ROOT="$PWD"
SRC="$ROOT/src"
CONFIG="$SRC/config"
ALIASES="$SRC/cursorList"

function gen() {
	theme="$1"
	files="hl-$theme"
	cursors="$files/hyprcursors"
	mkdir -p "$cursors"
	echo -e "name = Colloid-pastel-cursors-${theme}-hy\ncursors_directory = hyprcursors" > "$files/manifest.hl"

	for i in "$CONFIG"/*.cursor; do
		curname=${i##*/}
		curname=${curname%.*}
		curdir="${cursors}/${curname}"
		mkdir "${curdir}"
		meta="${curdir}/meta.hl"
		touch $meta
		ARR=($(head -n1 $i))
		res=${ARR[0]}
		hotx=$(echo -e "scale=10\n${ARR[1]}/$res" | bc)
		hoty=$(echo -e "scale=10\n${ARR[2]}/$res" | bc)
	echo -e "hotspot_x = $hotx\nhotspot_y = $hoty\n" >> $meta
		while read LINE; do
			L=($LINE)
			lres=${L[0]}
			if [ "$lres" != "$res" ]; then continue; fi
			lname=${L[3]##x1/}
			lname=${lname%.*}.svg
			ldelay=${L[4]:-50}
			# echo $curname $lres $lname $ldelay
			echo -e "define_size = 0, $lname, $ldelay" >> $meta
			# Try symliks later, but I'm not sure if hyrcursor-util will process them or not
			# Just manually remove hl-* dirs after build if you care
			cp "$SRC/svg-${theme}/${lname}" "${curdir}"
		done < $i
		echo "" >> $meta # newline
		echo -e "define_override = ${curname}" >> $meta
	done

	while read ALIAS; do
		from="${ALIAS#* }"
		to="${ALIAS% *}"
		meta="${cursors}/${from}/meta.hl"
		if [ -f "$meta" ]; then
			echo -e "define_override = ${to}" >> $meta
		fi
	done < $ALIASES

	cd $ROOT
}

rm -r hl-dark hl-light dist-hl-dark dist-hl-light 2>/dev/null
gen "light"
gen "dark"
echo "Theme sources generated, running huprcursor-util to pack them into hyprcursor themes"
hyprcursor-util --create hl-light
hyprcursor-util --create hl-dark
mv theme_Colloid-pastel-cursors-dark-hy dist-hl-dark
mv theme_Colloid-pastel-cursors-light-hy dist-hl-light
echo "Themes packed. Finished"
