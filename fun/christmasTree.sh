#!/bin/bash

spaces() {
  for ((i=0; i<$1; i++)) ; do
    echo -n " "
  done 
}

stars() {
  for ((i=0; i<$1; i++)) ; do
    echo -n "*"
  done
  echo ""
}

display_tree() {
    local rows=$1
    local columns=$2

    # ausgabe
    for (( r=1; r <= $rows; r++ )); do
      s=$(( (((columns-1) * (r-1)/(rows-1) + 1)/2)*2 +1 ))
      spaces $(((columns-s)/2))
      stars $s
    done
}

if [ $# -eq 2 ]; then
    display_tree $1 $2
else
    echo "Usage: $0 rows columns"
fi
