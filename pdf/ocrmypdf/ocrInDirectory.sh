#!/bin/bash
for i in *.pdf; do
        echo "START: $i"

        oHash=$(md5sum "$i" | awk '{ print $1 }')
        sTime=$(date +%s)
        oSize=$(wc -c "$i" | cut -d ' ' -f1)

        #ocrmypdf -l deu --optimize 2 --redo-ocr "$i" "$(basename "$i" ".pdf")_ocr.pdf" >/dev/null 2>&1
        ocrmypdf -l deu --optimize 2 --redo-ocr "$i" "$(basename "$i" ".pdf").pdf" >/dev/null 2>&1

        nHash=$(md5sum "$i" | awk '{ print $1 }')
        eTime=$(date +%s)
        nSize=$(wc -c "$i" | cut -d ' ' -f1)

        if [ "$oHash" = "$nHash" ]; then
                echo -e "\tNothing changed!"
        else
                echo -e "\tSometing changed"
        fi
        echo "ENDE: $i, Time: $((eTime-sTime)) [s], -$((oSize-nSize)) [Byte]"
        echo ""
done
