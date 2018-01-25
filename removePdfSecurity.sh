for i in *.pdf; do gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="new-$i" -c .setpdfwrite -f "$i"; done
