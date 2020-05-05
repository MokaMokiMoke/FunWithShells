#/bin/bash
rm -rf ./bikes
mkdir bikes

max=$(cat alle.xml | grep UTF-8 | wc -l)

for i in $(seq 1 $max); do
	bike=$(cat alle.xml | head -n 1 | tr -d '\t' | tr -d \$'\r')
	sed -i '1d' alle.xml
	head -n 28 alle.xml > ./bikes/"$bike"
	sed -i '1,29d' alle.xml
done
