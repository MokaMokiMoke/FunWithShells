#!/bin/bash

## This SCript generates thumbnails from BASEDIR into 
## THUMBS while preserving the folder strcture. 
## Warning: Single threaded and quite slow
## Copyright (C) 2021 Maximilian Fries - All Rights Reserved
## Contact: maxfries@t-online.de
## Last revised 2021-08-27

## Usage: Set BASEDIR, set THUMBS and run the script

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

basedir="/home/max/jpg"
thumbs="/home/max/thumbs/"

cd "$basedir"
mkdir -p "$thumbs"

for i in $(find * -type f -regextype egrep -iregex '.*\.(jpg|png|tiff|cr2|crw|raw)');
do
        if [ `dirname $i` != "." ]
        then
                dirpath="${i%/*}"
                dir_arr=(`echo $dirpath | tr "/" "\n"`)
                path=""
                for x in "${dir_arr[@]}"
                do
                        if [ -z "$path" ]
                        then
                                path="$x"
                                mkdir -p "$thumbs$path"
                        else
                                path="$path"/"$x"
                                mkdir -p "$thumbs$path"
                        fi
                done
                ext="."${i##*.}
                output=${i/$ext/".jpg"}
                if [ ! -f "$thumbs$output" ] || [ "$i" -nt "$thumbs$output" ]
                then
                        echo "$i"
                        convert "$i" -resize '600>' -quality 60 "$thumbs$output"
                fi
        else
                ext="."${i##*.}
                output=${i/$ext/".jpg"}
                if [ ! -f "$thumbs$output" ] || [ "$i" -nt "$thumbs$output" ]
                then
                        echo "$i"
                        convert "$i" -resize '600>' -quality 60 "$thumbs$output"
                fi
        fi
done
