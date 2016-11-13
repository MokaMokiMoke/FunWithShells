FILES=$( find . -type f -name "*jpg" | cut -d/ -f 2)
mkdir tmp && cd tmp
for file in $FILES; do
    BASE=$(echo $file | sed 's/.jpg//g');
    convert ../$BASE.jpg $BASE.pdf;
    done
pdfunite *.pdf unite.pdf
pdf2ps unite.pdf out1.ps
ps2pdf out1.ps ../merge.pdf
cd ..
rm -rf tmp
