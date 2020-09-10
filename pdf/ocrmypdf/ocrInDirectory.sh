#!/bin/bash
# Check if dependencies are installed

if [ $# -gt 1 ]; then
	echo Invalid number of parameters
	echo Usage: ocrmypdf [--quiet]
	exit 1
fi

quiet=""
if [ $# -gt 0 ] && [ $1 = "--quiet" ]; then
	quiet="--quiet"
fi

# DEBUG
# echo quiet: $quiet, hash: $#, 1st: $1

declare -a dep=("ocrmypdf" "tesseract" "ghostscript")
for d in "${dep[@]}"; do
	if ! command -v $d &> /dev/null; then
		echo "$d could not be found!"
		exit
	fi
done

lang="deu"
if [ -z $(tesseract --list-langs | grep $lang) ]; then
	echo "tesseract language $lang could not be found!"
	exit
fi


find . -type f -iname "*.pdf" | while read i; do
        echo "START: $i"
        oHash=$(md5sum "$i" | awk '{ print $1 }')
        sTime=$(date +%s)
        oSize=$(wc -c "$i" | cut -d ' ' -f1)

        ocrmypdf -l deu --optimize 2 --redo-ocr --output-type pdf "$i" "$(basename "$i" ".pdf").pdf" $quiet

        nHash=$(md5sum "$i" | awk '{ print $1 }')
        eTime=$(date +%s)
        nSize=$(wc -c "$i" | cut -d ' ' -f1)

        if [ "$oHash" = "$nHash" ]; then
                echo -e "\tNothing changed!"
        else
                echo -e "\tSometing changed"
        fi

	dSize=-$((oSize-nSize))

        echo "ENDE: Time: $((eTime-sTime)) [s], ${dSize//--/+} [Bytes]"
        echo ""
done
