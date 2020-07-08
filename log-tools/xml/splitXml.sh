#/bin/bash
in="$1"

# Empty ./bikes folder
sh ./preflight.sh

max=$(cat $in | grep '/ebike' | wc -l)

echo "Expecting: $max bikes"

for i in $(seq 1 $max); do
	bike=$(cat $in | head -n 1 | tr -d '\t' | tr -d \$'\r')
	sed -i '1d' $in
	head -n 28 $in > ./bikes/"$bike"
	sed -i '1,29d' $in
done

echo "Generated: $(ls ./bikes/*.xml | wc -l) bikes"
arc="bikes.zip"
zip -qqr $arc ./bikes/ 
echo "Bikes compressed: $arc" 

if ( $(cat $in | wc -l) == 0 ); then
    rm $in
fi
