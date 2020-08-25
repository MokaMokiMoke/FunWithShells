#!/bin/bash
# Maximilian Fries, 25.08.2020
# maxfries@t-online.de

# foo="screen ebook prepress default"

for f in *.pdf; do
  parallel -a params.txt \
  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/{} -dNOPAUSE -dBATCH -sOutputFile={}-"$f" "$f"
done
