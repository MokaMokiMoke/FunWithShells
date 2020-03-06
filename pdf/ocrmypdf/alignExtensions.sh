#!/bin/bash
find . -type f -name "*.PDF" | while read f; do
        dir=$(dirname "$f")
        fname=$(basename "$f" .PDF)
        comb=$dir"/"$fname".pdf"
        echo "$f"
        mv "$f" "$comb"
done
