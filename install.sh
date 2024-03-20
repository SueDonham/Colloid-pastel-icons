#!/bin/bash

set -eo pipefail

ROOT_UID=0
DEST_DIR=
CURSOR_DIR=$PWD/cursors

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

THEME_NAME=Colloid-pastel
VARIANTS=('-light' '-dark' '')
COLORS=('' '-blue' '-pink' '-red' '-orange' '-yellow' '-green' '-teal' '-grey')


# Print help menu:
usage() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME         Specify theme name (Default: $THEME_NAME)
    -c, --folder COLORS     Specify folder color(s) [default|blue|pink|red|orange|yellow|green|teal|grey|all] (Default: purple)
    -h, --help              Show help
EOF
}


# Install icon theme:
install() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local variant=${4}

  local THEME_DIR=${dest}/${name}${color}${variant}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p   ${THEME_DIR}
  cp -r "${SRC_DIR}"/src/index.theme ${THEME_DIR}
  sed -i "s/Colloid-pastel/${2}${3}${4} /g"  ${THEME_DIR}/index.theme

  if [[ ${variant} == '-light' ]]; then
    cp -r "${SRC_DIR}"/src/{actions,apps,categories,devices,emblems,mimetypes,places,status} ${THEME_DIR}
    cp -r "${SRC_DIR}"/links/*   ${THEME_DIR}

    if [[ ${color} != '' ]]; then
  cp -r "${SRC_DIR}"/colors/color${color}/*.svg ${THEME_DIR}/places/scalable
	else
  cp -r "${SRC_DIR}"/colors/color-purple/*.svg    ${THEME_DIR}/places/scalable
    fi
  fi

  if [[ ${variant} == '-dark' ]]; then
    mkdir -p ${THEME_DIR}/{apps,categories,devices,emblems,mimetypes,places,status}
    cp -r "${SRC_DIR}"/src/actions   ${THEME_DIR}
    cp -r "${SRC_DIR}"/src/apps/symbolic ${THEME_DIR}/apps
    cp -r "${SRC_DIR}"/src/categories/symbolic ${THEME_DIR}/categories
    cp -r "${SRC_DIR}"/src/emblems/symbolic    ${THEME_DIR}/emblems
    cp -r "${SRC_DIR}"/src/mimetypes/symbolic  ${THEME_DIR}/mimetypes
    cp -r "${SRC_DIR}"/src/devices/{16,22,24,symbolic}   ${THEME_DIR}/devices
    cp -r "${SRC_DIR}"/src/places/{16,22,24,symbolic}    ${THEME_DIR}/places
    cp -r "${SRC_DIR}"/src/status/{16,22,24,symbolic}    ${THEME_DIR}/status

	# Change icon color for dark theme:
    sed -i "s/#050505/#fdfdfd/g" "${THEME_DIR}"/{actions,devices,places,status}/{16,22,24}/*
    sed -i "s/#050505/#fdfdfd/g" "${THEME_DIR}"/actions/32/*
    sed -i "s/#050505/#fdfdfd/g" "${THEME_DIR}"/{actions,apps,categories,devices,emblems,mimetypes,places,status}/symbolic/*

    cp -r "${SRC_DIR}"/links/actions/{16,22,24,32,symbolic}  ${THEME_DIR}/actions
    cp -r "${SRC_DIR}"/links/devices/{16,22,24,symbolic} ${THEME_DIR}/devices
    cp -r "${SRC_DIR}"/links/places/{16,22,24,symbolic}  ${THEME_DIR}/places
    cp -r "${SRC_DIR}"/links/status/{16,22,24,symbolic}  ${THEME_DIR}/status
    cp -r "${SRC_DIR}"/links/apps/symbolic ${THEME_DIR}/apps
    cp -r "${SRC_DIR}"/links/categories/symbolic   ${THEME_DIR}/categories
    cp -r "${SRC_DIR}"/links/mimetypes/symbolic    ${THEME_DIR}/mimetypes

    cd ${dest}
    ln -sf ../../${name}${color}-light/apps/scalable ${name}${color}-dark/apps/scalable
    ln -sf ../../${name}${color}-light/devices/scalable ${name}${color}-dark/devices/scalable
    ln -sf ../../${name}${color}-light/places/scalable ${name}${color}-dark/places/scalable
    ln -sf ../../${name}${color}-light/categories/32 ${name}${color}-dark/categories/32
    ln -sf ../../${name}${color}-light/emblems/16 ${name}${color}-dark/emblems/16
    ln -sf ../../${name}${color}-light/emblems/22 ${name}${color}-dark/emblems/22
    ln -sf ../../${name}${color}-light/status/32 ${name}${color}-dark/status/32
    ln -sf ../../${name}${color}-light/mimetypes/scalable ${name}${color}-dark/mimetypes/scalable
  fi

  if [[ ${variant} == '' ]]; then
    mkdir -p ${THEME_DIR}/status
    cp -r "${SRC_DIR}"/src/status/{16,22,24}   ${THEME_DIR}/status
    # Change icon color for dark panel:
    sed -i "s/#050505/#fdfdfd/g" "${THEME_DIR}"/status/{16,22,24}/*
    cp -r "${SRC_DIR}"/links/status/{16,22,24} ${THEME_DIR}/status

    cd ${dest}
    ln -sf ../${name}${color}-light/apps ${name}${color}/apps
    ln -sf ../${name}${color}-light/actions ${name}${color}/actions
    ln -sf ../${name}${color}-light/devices ${name}${color}/devices
    ln -sf ../${name}${color}-light/emblems ${name}${color}/emblems
    ln -sf ../${name}${color}-light/places ${name}${color}/places
    ln -sf ../${name}${color}-light/categories ${name}${color}/categories
    ln -sf ../${name}${color}-light/mimetypes ${name}${color}/mimetypes
    ln -sf ../../${name}${color}-light/status/32 ${name}${color}/status/32
    ln -sf ../../${name}${color}-light/status/symbolic ${name}${color}/status/symbolic
  fi

  (
    cd ${THEME_DIR}
    ln -sf actions actions@2x
    ln -sf apps apps@2x
    ln -sf categories categories@2x
    ln -sf devices devices@2x
    ln -sf emblems emblems@2x
    ln -sf mimetypes mimetypes@2x
    ln -sf places places@2x
    ln -sf status status@2x
  )

  gtk-update-icon-cache ${THEME_DIR}
}


while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -c|--color)
      shift
      for c in "${@}"; do
        case "${c}" in
          default)
            colors+=("${COLORS[0]}")
            shift
            ;;
          blue)
            colors+=("${COLORS[1]}")
            shift
            ;;
          pink)
            colors+=("${COLORS[2]}")
            shift
            ;;
          red)
            colors+=("${COLORS[3]}")
            shift
            ;;
          orange)
            colors+=("${COLORS[4]}")
            shift
            ;;
          yellow)
            colors+=("${COLORS[5]}")
            shift
            ;;
          green)
            colors+=("${COLORS[6]}")
            shift
            ;;
          teal)
            colors+=("${COLORS[7]}")
            shift
            ;;
          grey)
            colors+=("${COLORS[8]}")
            shift
            ;;
          all)
            colors+=("${COLORS[@]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done


if [[ "${#colors[@]}" -eq 0 ]]; then
  colors=("${COLORS[0]}")
fi


install_theme() {
  for var in "${VARIANTS[@]}"; do
	for color in "${colors[@]}"; do
	install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${var}"
	done
  done
}


install_theme	# Install theme(s)


# Prompt to install cursors:
read -p "Install cursor theme? [y/n] " YN
[[ "$YN" == [yY]* ]] && bash $CURSOR_DIR/install.sh
