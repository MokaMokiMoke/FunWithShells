#!/bin/bash
in="$1"
start=$(date +"%Y-%m-%d_%H-%M-%S")
echo Start: $start
t_start=`date +%s`

## Preflight
rm -rf ~/bikes/ 2> /dev/null
mkdir ~/bikes/ 2> /dev/null
mkdir ~/backup/ 2> /dev/null
cp ~/rum-public/$in ~/
cp ~/rum-public/$in ~/backup/$start-$in
cd ~

## Crunch bikes
max=$(cat $in | grep '/ebike' | wc -l)
echo "Expecting: $max bikes"

for i in $(seq 1 $max); do
    bike=$(cat $in | head -n 1 | tr -d '\t' | tr -d \$'\r')
    sed -i '1d' $in
    head -n 28 $in > ./bikes/"$bike"
    sed -i '1,29d' $in
    per=$(echo "$i/$max * 100" | bc -l | cut -d. -f1)
    echo -ne "Fortschritt: $per%\r"
done
echo ""

echo "Generated: $(ls ./bikes/*.xml | wc -l) bikes"
arc="$start-bikes.zip"
zip -qqr $arc ./bikes/
cp $arc ~/rum-public/ 
echo "Compressed: $arc, size: $(du -k "$arc" | cut -f1) kB" 

if [ $(cat $in | wc -l) -eq 0 ]; then
    rm $in
fi

t_end=`date +%s`
echo "Ende: $(date +"%Y-%m-%d_%H-%M-%S"), duration: $((t_end-t_start)) s"

