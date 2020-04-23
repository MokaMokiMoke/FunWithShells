#for file in $(ls access*.log*); do
#	datum=$(date -r $file "+%Y-%m-%d_%H-%M-%S")
#	mv $file access_$datum.log
#done

# for i in {01..30}; do cat dec.log | grep $i/Dec/2019 >access_2019-12-$i.log; done

#Generate daily LOGS for ACCESS.LOG through YEARS, [08/Nov/2019
mons=(
	Jan
	Feb
	Mar
	Apr
	May
	Jun
	Jul
	Aug
	Sep
	Oct
	Nov
	Dec
)

for yr in {2019..2020}; do
	for mon in "${mons[@]}"; do
		for day in {01..31}; do
			fgrep $day/$mon/$yr access.log >access_$yr-$mon-$day.log
			lin=$(cat access_$yr-$mon-$day.log | wc -l)
			if [ $lin -lt 3 ]; then rm access_$yr-$mon-$day.log; fi
		done
	done
done


# Generate daily LOGS for ERROR.LOG through YEARS, 2019/01/08
for yr in {2019..2020}; do
	for mon in {01..12}; do
		for day in {01..31}; do
			fgrep $yr/$mon/$day error.log >error_$yr-$mon-$day.log
			lin=$(cat error_$yr-$mon-$day.log | wc -l)
			if [ $lin -lt 3 ]; then rm error_$yr-$mon-$day.log; fi
		done
	done
done
