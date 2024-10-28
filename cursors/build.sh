#! /usr/bin/env bash


DIST=$PWD/dist
BUILD=$PWD/build
SRC=$PWD/src
SVG=$SRC/svg
ALIASES=$SRC/cursorList
CONFIG=$SRC/config

SIZES=('1' '1.25' '1.5' '2' '2.5' '3')


# Check command availability:
has_command() {
  "$1" -v "$1" > /dev/null 2>&1
}

# Verify or install dependencies:
function check_dependencies(){
    for dep in "xcursorgen" "inkscape" ; do
        if [ ! "$(which $dep 2> /dev/null)" ]; then
            [[ $dep == "xcursorgen" ]] && pkg="x11-apps" || pkg=$dep
            echo "$dep needs to be installed to generate the cursors."
            read -p "Continue? [Y|n]: " yn
            [[ $yn =~ [nN]* ]] && exit
            if has_command zypper; then
                sudo zypper in $pkg
            elif has_command apt; then
                sudo apt install $pkg
            elif has_command dnf; then
                sudo dnf install $pkg
            elif has_command pacman; then
                sudo pacman -S $pkg
            fi
        fi
    done
}


# Create png files from svgs:
function export_png(){
    png_path=$BUILD/$1/x$2  # build/variant/size
    mkdir -p "$png_path"

    printf "Exporting %dpx pngs for %s variant ... " $3 $1

    for file in $SVG-$1/*; do
        in=${file##*/}      # name.svg
        out=${in%.*}.png    # name.png

        inkscape --export-filename=$png_path/$out -w $3 -h $3 $SVG-$1/$in > /dev/null 2>&1
    done
    echo "Done"
}


# Create cursor theme:
function create_variant(){
	var=$1
    theme="Colloid-Pastel ${var^}"
	build_path=$BUILD/$var
    dist_path="$DIST-$var/cursors"

    mkdir -p "$build_path" "$dist_path"

    # Call export_png function for each size/resolution:
    for s in "${!SIZES[@]}"; do
        size="${SIZES[$s]}"
        res=$(echo "$size*24" | bc) # resolution = 24 * size
        res=${res%.*}               # truncate at decimal
        export_png "$var" "$size" "$res"
    done

    cp "$CONFIG"/*.cursor "$build_path" # Copy .cursor files to where xcursorgen can find them

    # Create cursors:
    cd $build_path
    for c in *.cursor; do
        xcursorgen $c $dist_path/${c%.*}
    done

    # Link cursors to aliases:
    cd $dist_path
    while read ALIAS; do
		from="${ALIAS#* }"
		to="${ALIAS% *}"

        if [ -e "$to" ]; then continue; fi

		ln -s "$from" "$to"
	done < "$ALIASES"

    # Create index.theme file:
	INDEX="../index.theme"
	if [ ! -e $INDEX ]; then
		touch $INDEX
		echo -e "[Icon Theme]\nName=$theme\nComment=Pastel version of Colloid cursors\n" > "$INDEX"
	fi

	echo "${var^} variant built!"
}



check_dependencies
create_variant "light"
create_variant "dark"

rm -r "$BUILD"    # Clean up PNGs and copies of .cursor files
