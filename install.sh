#!/bin/bash

set -eo pipefail

ROOT_UID=0
DEST_DIR=
CURSOR_DIR=$PWD/cursors

[ "$UID" -eq "$ROOT_UID" ] && DEST_DIR="/usr/share/icons" || DEST_DIR="$HOME/.local/share/icons"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

THEME_NAME=Colloid-pastel
VARIANTS=('-light' '-dark' '')
COLOR_OPTS=('' '-blue' '-pink' '-red' '-orange' '-yellow' '-green' '-teal' '-grey')
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
    if [[ " ${COLOR_OPTS[*]} " == *" -$color "* ]]; then
      COLORS+=("-$color")
    elif [[ "$color" == "all" ]]; then
      COLORS+=("${COLOR_OPTS[@]}")
    else
      echo "ERROR: Unrecognized color variant '$i'."
      echo "Try '$0 --help' for more information."
      exit 1
    fi
  done
}


color_folders() {
  case "$color" in
    '') theme_color='#c3b6c9' ;;
    -blue) theme_color='#b9cfde' ;;
    -pink) theme_color='#f4b9be' ;;
    -red) theme_color='#d19494' ;;
    -orange) theme_color='#f5cba3' ;;
    -yellow) theme_color='#f3dea4' ;;
    -green) theme_color='#aac69f' ;;
    -teal) theme_color='#9fc6be' ;;
    -grey) theme_color='#a19d91' ;;
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
  local theme_dir=${dest}/${name}${color}${variant}

  [[ -d "${theme_dir}" ]] && rm -rf "${theme_dir}"

  echo "Installing '${theme_dir}'..."

  mkdir -p "${theme_dir}"
  cp -r "${SRC_DIR}"/src/index.theme "${theme_dir}"
  sed -i "s/Colloid-pastel/${name}${color}${variant}/g" "${theme_dir}"/index.theme

  if [[ "${variant}" == '-light' ]]; then
    cp -r "${SRC_DIR}"/src/{actions,apps,categories,devices,emblems,mimetypes,places,status} "${theme_dir}"

    if [[ "${color}" != '' ]]; then
      color_folders
      sed -i "s/#c3b6c9/${theme_color}/g" "${theme_dir}"/places/scalable/*.svg
    fi

    cp -r "${SRC_DIR}"/links/* "${theme_dir}"
  fi

  if [[ "${variant}" == '-dark' ]]; then
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
    ln -sf ../../"${name}${color}"-light/apps/scalable "${name}${color}"-dark/apps/scalable
    ln -sf ../../"${name}${color}"-light/devices/scalable "${name}${color}"-dark/devices/scalable
    ln -sf ../../"${name}${color}"-light/places/scalable "${name}${color}"-dark/places/scalable
    ln -sf ../../"${name}${color}"-light/categories/32 "${name}${color}"-dark/categories/32
    ln -sf ../../"${name}${color}"-light/emblems/16 "${name}${color}"-dark/emblems/16
    ln -sf ../../"${name}${color}"-light/emblems/22 "${name}${color}"-dark/emblems/22
    ln -sf ../../"${name}${color}"-light/status/32 "${name}${color}"-dark/status/32
    ln -sf ../../"${name}${color}"-light/mimetypes/scalable "${name}${color}"-dark/mimetypes/scalable
  fi

  if [[ "${variant}" == '' ]]; then
    cd ${dest}
    ln -sf ../"${name}${color}"-light/apps "${name}${color}"/apps
    ln -sf ../"${name}${color}"-light/actions "${name}${color}"/actions
    ln -sf ../"${name}${color}"-light/devices "${name}${color}"/devices
    ln -sf ../"${name}${color}"-light/emblems "${name}${color}"/emblems
    ln -sf ../"${name}${color}"-light/places "${name}${color}"/places
    ln -sf ../"${name}${color}"-light/categories "${name}${color}"/categories
    ln -sf ../"${name}${color}"-light/mimetypes "${name}${color}"/mimetypes
    ln -sf ../"${name}${color}"-dark/status "${name}${color}"/status
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
  for color in '' '-blue' '-pink' '-red' '-orange' '-yellow' '-green' '-teal' '-grey'; do
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
      set_colors "${@}"
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

read -p "Install cursor theme? [y/n] " YN
[[ "$YN" == [yY]* ]] && bash $CURSOR_DIR/install.sh

