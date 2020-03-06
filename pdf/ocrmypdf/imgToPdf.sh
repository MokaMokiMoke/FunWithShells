#!/bin/bash
for i in $(find . -type f -not -name "*.pdf"); do
        i=$(echo $i | cut -d '/' -f2)
        noExt=$(echo "${i%%.*}")
        ocrmypdf -l deu --image-dpi 200 "$i" $noExt.pdf
done
