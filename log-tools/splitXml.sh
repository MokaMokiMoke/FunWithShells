#/bin/bash
rm -rf ./bikes
mkdir bikes

for i in {1..490}; do
	bike=$(cat alle.xml | head -n 1 | tr -d '\t' | tr -d \$'\r')
	sed -i '1d' alle.xml
	head -n 28 alle.xml > ./bikes/"$bike"
	sed -i '1,29d' alle.xml
done
