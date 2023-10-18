#!/bin/sh

# source: https://unix.stackexchange.com/questions/77136/xdg-open-default-applications-behavior
# run ./script file

set -e

if [ ! "${1}" ]; then
    echo "Usage: ${0} <file>"
    exit 1
fi

FILETYPE="$(xdg-mime query filetype "${1}")"
APP="$(find /usr/share -type f -name "*.desktop" -printf "%p\n" | wofi --show dmenu -i -p "select default app")"
APP="$(basename -- "${APP}")"
xdg-mime default "${APP}" "${FILETYPE}"
echo "${APP} set as default application to open ${FILETYPE}"
