#!/bin/bash
total=0
noOcr=0
while read f; do
        let "total++"
	if [ $(pdffonts "$f" | wc -l) -eq 2 ]; then
                echo "Found File without OCR:"
                echo -e "\t "$f" "
                echo ""
		let "noOcr++"
        fi
done <<< $(find . -type f -name "*.pdf") 

echo "Total found: $noOcr of $total PDFs without OCR"
