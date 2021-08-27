#!/bin/bash

## This Script finds all JPG files within BASEDIR and generates 
## thumnails and puts them in THUMBDIR without preserving the 
## folder structure (!)
## Files (even from different soure folders) with identical names
## will be overwritten as thumbnail
## Copyright (C) 2021 Maximilian Fries - All Rights Reserved
## Contact: maxfries@t-online.de
## Last revised 2021-08-27

## Usage: Set BASEDIR, set THUMBDIR and run the script

QUALITY='60%'
MAXSIZE='400>'
BASEDIR="/home/max/jpg"
THUMBDIR="/home/max/thumbs"
mkdir -p "$THUMBDIR"

find "$BASEDIR" -type f -iname \*.jpg -exec convert {} -quality $QUALITY -resize "$MAXSIZE"\> \
-set filename:name '%t' "$THUMBDIR/%[filename:name]_thumb.jpg" \;
