#!/bin/sh

set -e
set -v

# check current with e.g.:
# xdg-mime query default text/plain

FILE_MANAGER="ranger.desktop"
TEXT_EDITOR="nvim.desktop"
ARCHIVE_MANAGER="org.kde.ark.desktop"
DOCUMENT_VIEWER="org.kde.okular.desktop"
IMAGE_VIEWER="org.kde.gwenview.desktop"
XOURNALPP="com.github.xournalpp.xournalpp.desktop"
VIDEO_VIEWER="vlc.desktop"

# default file manager
xdg-mime default "${FILE_MANAGER}" inode/directory

xdg-mime default "${TEXT_EDITOR}" text/plain
xdg-mime default "${TEXT_EDITOR}" inode/x-empty

xdg-mime default "${ARCHIVE_MANAGER}" application/gzip
xdg-mime default "${ARCHIVE_MANAGER}" application/zip

xdg-mime default "${DOCUMENT_VIEWER}" application/pdf

xdg-mime default "${IMAGE_VIEWER}" image/png

xdg-mime default "${VIDEO_VIEWER}" video/x-msvideo
xdg-mime default "${VIDEO_VIEWER}" video/mp4
xdg-mime default "${VIDEO_VIEWER}" video/x-matroska

xdg-mime default "${XOURNALPP}" application/x-xojpp
xdg-mime default "${XOURNALPP}" application/x-xopt
xdg-mime default "${XOURNALPP}" application/x-xopp
