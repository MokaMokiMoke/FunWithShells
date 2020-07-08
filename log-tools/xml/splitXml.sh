#/bin/bash
in="$1"
start=$(date +"%Y-%m-%d_%H-%M-%S")
echo Start: $start

# Empty ./bikes folder
sh ./preflight.sh

# Bakup input xml file
cp $in ./backup/$start-$in

max=$(cat $in | grep '/ebike' | wc -l)

echo "Expecting: $max bikes"

ctr=1
for i in $(seq 1 $max); do
	bike=$(cat $in | head -n 1 | tr -d '\t' | tr -d \$'\r')
	sed -i '1d' $in
	head -n 28 $in > ./bikes/"$bike"
	sed -i '1,29d' $in
        if [ $(( $ctr % 10 )) -eq 0 ]; then
            echo $ctr..
        fi
        let ctr++
done

echo "Generated: $(ls ./bikes/*.xml | wc -l) bikes"
arc="$start-bikes.zip"
zip -qqr $arc ./bikes/ 
echo "Compressed: $arc, size: $(du -k "$arc" | cut -f1) kB" 

if [ $(cat $in | wc -l) -eq 0 ]; then
    rm $in
fi

echo "Ende: $(date +"%Y-%m-%d_%H-%M-%S")"
