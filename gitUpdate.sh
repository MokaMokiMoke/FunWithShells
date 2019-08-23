#!/bin/bash

gitHttpUrl="https://github.com"
gitUser="MokaMokiMoke"
#gitProtocol="git"
gitProtocol="https"

magenta="\033[35m"
green="\033[32m"
blue="\033[34m"
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
	
	if [ $gitProtocol = "git" ]; then
		git clone git@github.com:$gitUser/$repo.git
	elif [ $gitProtocol = "https" ]; then
		git clone $gitHttpUrl/$gitUser/$repo
	else
		echo -e "$red Protocol is not set properly$def"
		exit 1
	fi

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
	else
		echo -e "$blue \tRepo $repo was updated $def"
	fi
	cd ..
done
echo -e "$green Update finished $def"
