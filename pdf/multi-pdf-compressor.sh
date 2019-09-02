#!/bin/bash

# Set spacing set (IFS) to prevent errors with filenames including spaces
IFS=$(echo -en "\n\b")

declare -a params=("screen" "ebook" "prepress" "default")
files=$(ls *.pdf)

for p in "${params[@]}"; do
  for f in $files; do
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$p -dNOPAUSE -dBATCH -sOutputFile=$p-"$f" "$f";
  done;
done
