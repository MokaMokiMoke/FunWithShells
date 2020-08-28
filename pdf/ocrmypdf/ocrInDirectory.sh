#!/bin/bash
# Check if dependencies are installed

verbose=">/dev/null 2>&1"
if [ $1 = "--verbose" ]; then
	verbose=""
fi

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

        ocrmypdf -l deu --optimize 2 --redo-ocr --output-type pdf "$i" "$(basename "$i" ".pdf").pdf" $verbose

        nHash=$(md5sum "$i" | awk '{ print $1 }')
        eTime=$(date +%s)
        nSize=$(wc -c "$i" | cut -d ' ' -f1)

        if [ "$oHash" = "$nHash" ]; then
                echo -e "\tNothing changed!"
        else
                echo -e "\tSometing changed"
        fi
        echo "ENDE: Time: $((eTime-sTime)) [s], -$((oSize-nSize)) [Byte]"
        echo ""
done
