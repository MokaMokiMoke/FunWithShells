#!/bin/bash

gitUrl="https://github.com"
gitUser="MokaMokiMoke"

magenta="\033[35m"
green="\033[32m"
def="\033[0m"

declare -a repos=($(curl -s "https://api.github.com/users/$gitUser/repos?page=$PAGE&per_page=100" | grep -e 'git_url*' | cut -d \" -f 4 | cut -d"/" -f5 | cut -d"." -f1))

# Init clone
echo -e "$magenta Cloning new Repositories $def"
for repo in "${repos[@]}"
do
	if [ -d $repo ]; then
		echo -e "$green \tRepo $repo already exists $def"
		continue
	fi

	git clone $gitUrl/$gitUser/$repo

done
echo -e "$green Colning finished $def"

# Update Repos
echo -e "$magenta Updating Repositories $def"
for repo in "${repos[@]}"
do
	cd $repo
	pullReport=$(git pull)
	if [ "$pullReport" = "Already up-to-date." ]; then
		echo -e "$green \tRepo $repo is already up to date $def"
	fi
	cd ..
done
echo -e "$green Update finished $def"
