#!/bin/bash

declare -a param=("screen" "ebook" "prepress" "default")
file=$(ls *.pdf)

for p in "${param[@]}"; do
  for f in $file; do
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$p -dNOPAUSE -dBATCH -sOutputFile=$p-$f $f; 
  done;
done
