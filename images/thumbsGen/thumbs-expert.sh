# DO NOT ADD A #!/bin/bash or any other shell reference
# DO NOT ADD an empty line at the end of the script

## This Script generates thumbnails for an given folder (SRC)
## including subdirectories into a given directory (THUMBS)
## while preserving the directory structure in parallel
## Copyright (C) 2021 Maximilian Fries - All Rights Reserved
## Contact: maxfries@t-online.de
## Last revised 2021-08-27

## Usage: Set SRC, set THUMBS and run the script

SRC=/home/max/jpg
THUMBS=/home/max/thumbs

export THUMBS=$(readlink -f "$THUMBS")
cd "$SRC"; find . -type f -regextype egrep -iregex '.*\.(jpg|png|tiff|cr2|crw|raw)' -print0 | parallel -0 --bar 't="$THUMBS"/{.}.jpg; test {} -nt "$t" && mkdir -p "$THUMBS"/{//} && convert {} "$t"'
