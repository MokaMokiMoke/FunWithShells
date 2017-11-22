#!/bin/sh

for file in "$@"; do
    if test "${file##*.}" = "svg" -a \( ! -e "${file%.svg}.eps" -o "$file" -nt "${file%.svg}.eps" \)
    then
	inkscape "$file" -E "${file%.svg}.eps"
    fi
done
