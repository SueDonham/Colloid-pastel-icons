#!/bin/bash

set -eo pipefail

ROOT_UID=0
DEST_DIR=
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CURSOR_DIR=$SCRIPT_DIR/cursors

[ "$UID" -eq "$ROOT_UID" ] && DEST_DIR="/usr/share/icons" || DEST_DIR="$HOME/.local/share/icons"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

THEME_NAME=Colloid-Pastel
VARIANTS=('-Light' '-Dark' '')
COLOR_OPTS=('' '-Blue' '-Pink' '-Red' '-Orange' '-Yellow' '-Green' '-Teal' '-Grey')
COLORS=()



print_menu() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR                  Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME                 Specify theme name (Default: $THEME_NAME)
    -c, --folder COLORS             Specify folder color(s) [default|blue|pink|red|orange|yellow|green|teal|grey|all] (Default: purple)
    -r, --remove, -u, --uninstall   Remove/Uninstall $THEME_NAME icon theme(s)
    -h, --help                      Show help menu
EOF
}


set_colors() {
  input=("$@")
  for color in "${input[@]}"; do
    color="${color^}"
    if [[ " ${COLOR_OPTS[*]} " == *" -$color "* ]]; then
      COLORS+=("-$color")
    elif [[ "$color" == "all" ]]; then
      COLORS+=("${COLOR_OPTS[@]}")
    else
      echo "ERROR: Unrecognized color variant '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
    fi
  done
}


color_folders() {
  case "$color" in
    '') theme_color='#c3b6c9' ;;
    -Blue) theme_color='#b9cfde' ;;
    -Pink) theme_color='#f4b9be' ;;
    -Red) theme_color='#d19494' ;;
    -Orange) theme_color='#f5cba3' ;;
    -Yellow) theme_color='#f3dea4' ;;
    -Green) theme_color='#aac69f' ;;
    -Teal) theme_color='#9fc6be' ;;
    -Grey) theme_color='#a19d91' ;;
  esac
}

install_theme() {
  for color in "${COLORS[@]}"; do
    for var in "${VARIANTS[@]}"; do
      install_variant "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${var}"
    done
  done
}


install_variant() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local variant=${4}
  local theme_dir="${dest}/${name}${color}${variant}"

  [[ -d "${theme_dir}" ]] && rm -rf "${theme_dir}"

  echo "Installing '${theme_dir}'..."

  mkdir -p "${theme_dir}"
  cp -r "${SRC_DIR}"/src/index.theme "${theme_dir}"
  sed -i "s/Colloid-Pastel/${name}${color}${variant}/g" "${theme_dir}"/index.theme

  if [[ "${variant}" == '-Light' ]]; then
    cp -r "${SRC_DIR}"/src/{actions,apps,categories,devices,emblems,mimetypes,places,status} "${theme_dir}"

    if [[ "${color}" != '' ]]; then
      color_folders
      sed -i "s/#c3b6c9/${theme_color}/g" "${theme_dir}"/places/scalable/*.svg
    fi

    cp -r "${SRC_DIR}"/links/* "${theme_dir}"
  fi

  if [[ "${variant}" == '-Dark' ]]; then
    mkdir -p "${theme_dir}"/{apps,categories,devices,emblems,mimetypes,places,status}
    cp -r "${SRC_DIR}"/src/actions "${theme_dir}"
    cp -r "${SRC_DIR}"/src/apps/{22,symbolic} "${theme_dir}"/apps
    cp -r "${SRC_DIR}"/src/categories/symbolic "${theme_dir}"/categories
    cp -r "${SRC_DIR}"/src/emblems/symbolic "${theme_dir}"/emblems
    cp -r "${SRC_DIR}"/src/mimetypes/symbolic "${theme_dir}"/mimetypes
    cp -r "${SRC_DIR}"/src/devices/{16,22,24,32,symbolic} "${theme_dir}"/devices
    cp -r "${SRC_DIR}"/src/places/{16,22,24,symbolic} "${theme_dir}"/places
    cp -r "${SRC_DIR}"/src/status/{16,22,24,symbolic} "${theme_dir}"/status

    # Change icon color for dark theme
    sed -i "s/#363636/#dedede/g" "${theme_dir}"/{actions,devices,places,status}/{16,22,24}/*.svg
    sed -i "s/#363636/#dedede/g" "${theme_dir}"/{actions,devices}/32/*.svg
    sed -i "s/#363636/#dedede/g" "${theme_dir}"/apps/22/*.svg
    sed -i "s/#363636/#dedede/g" "${theme_dir}"/{actions,apps,categories,devices,emblems,mimetypes,places,status}/symbolic/*.svg

    cp -r "${SRC_DIR}"/links/actions/{16,22,24,32,symbolic} "${theme_dir}"/actions
    cp -r "${SRC_DIR}"/links/devices/{16,22,24,32,symbolic} "${theme_dir}"/devices
    cp -r "${SRC_DIR}"/links/places/{16,22,24,symbolic} "${theme_dir}"/places
    cp -r "${SRC_DIR}"/links/status/{16,22,24,symbolic} "${theme_dir}"/status
    cp -r "${SRC_DIR}"/links/apps/{22,symbolic} "${theme_dir}"/apps
    cp -r "${SRC_DIR}"/links/categories/symbolic "${theme_dir}"/categories
    cp -r "${SRC_DIR}"/links/mimetypes/symbolic "${theme_dir}"/mimetypes

    cd "${dest}"
    ln -sf ../../"${name}${color}"-Light/apps/scalable "${name}${color}"-Dark/apps/scalable
    ln -sf ../../"${name}${color}"-Light/devices/scalable "${name}${color}"-Dark/devices/scalable
    ln -sf ../../"${name}${color}"-Light/places/scalable "${name}${color}"-Dark/places/scalable
    ln -sf ../../"${name}${color}"-Light/categories/32 "${name}${color}"-Dark/categories/32
    ln -sf ../../"${name}${color}"-Light/emblems/16 "${name}${color}"-Dark/emblems/16
    ln -sf ../../"${name}${color}"-Light/emblems/22 "${name}${color}"-Dark/emblems/22
    ln -sf ../../"${name}${color}"-Light/status/32 "${name}${color}"-Dark/status/32
    ln -sf ../../"${name}${color}"-Light/mimetypes/scalable "${name}${color}"-Dark/mimetypes/scalable
  fi

  if [[ "${variant}" == '' ]]; then
    cd ${dest}
    ln -sf ../"${name}${color}"-Light/apps "${name}${color}"/apps
    ln -sf ../"${name}${color}"-Light/actions "${name}${color}"/actions
    ln -sf ../"${name}${color}"-Light/devices "${name}${color}"/devices
    ln -sf ../"${name}${color}"-Light/emblems "${name}${color}"/emblems
    ln -sf ../"${name}${color}"-Light/places "${name}${color}"/places
    ln -sf ../"${name}${color}"-Light/categories "${name}${color}"/categories
    ln -sf ../"${name}${color}"-Light/mimetypes "${name}${color}"/mimetypes
    ln -sf ../"${name}${color}"-Dark/status "${name}${color}"/status
  fi

  (
    cd "${theme_dir}"
    ln -sf actions actions@2x
    ln -sf apps apps@2x
    ln -sf categories categories@2x
    ln -sf devices devices@2x
    ln -sf emblems emblems@2x
    ln -sf mimetypes mimetypes@2x
    ln -sf places places@2x
    ln -sf status status@2x
  )

  gtk-update-icon-cache "${theme_dir}" &> /dev/null
}


remove_theme() {
  echo "Removing theme(s) ..."
  for color in '' '-Blue' '-Pink' '-Red' '-Orange' '-Yellow' '-Green' '-Teal' '-Grey'; do
    for var in "${VARIANTS[@]}"; do
    local theme_dir="${DEST_DIR}/${THEME_NAME}${color}${var}"
    [[ -d "$theme_dir" ]] && rm -rf "$theme_dir" && echo -e "Removed $theme_dir"
    done
  done
  exit 0
}



while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2 ;;
    -n|--name)
      name="${2}"
      shift 2 ;;
    -r|--remove|-u|--uninstall)
      remove_theme
      shift ;;
    -c|--color)
      shift
      set_colors "${@,,}"
      shift "${#@}" ;;
    -h|--help)
      print_menu
      exit 0 ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1 ;;
  esac
done

[[ "${#COLORS[@]}" -eq 0 ]] && COLORS=("${COLOR_OPTS[0]}")

install_theme
echo "Done."

read -p "Install cursor theme? [y|N] " YN
[[ "$YN" == [yY]* ]] && bash $CURSOR_DIR/install.sh
