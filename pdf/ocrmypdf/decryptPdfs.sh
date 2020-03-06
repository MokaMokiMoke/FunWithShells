#!/bin/bash
find . -type f -name "*.pdf" | while read f; do
  encStatus=$(pdfinfo -rawdates "$f" | grep Encrypted)
  if [[ $encStatus == *"yes"* ]]; then
    echo "encrypted: $f"
    gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="$f" -c .setpdfwrite -f "$f"
    echo -e "\t File decrypted"
    echo ""
  fi
done
