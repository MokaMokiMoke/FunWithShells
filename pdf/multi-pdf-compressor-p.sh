#!/bin/bash
# Maximilian Fries, 25.07.2021
# maxfries@t-online.de

ls *.pdf > pdfs.txt
declare -a params=("screen" "ebook" "prepress" "default")

for p in "${params[@]}"; do
  cat pdfs.txt | parallel gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$p -dNOPAUSE -dBATCH -sOutputFile=$p-"{1}" "{}";
done