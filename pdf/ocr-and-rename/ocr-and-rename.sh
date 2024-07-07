#!/bin/bash

################################################################################
# Script Name: ocr-and-rename.sh
# Author: Maximilian Fries (maxfries(at)t-online.de)
# Date: 07.07.2024 (dd-mm-yyyy)
# Purpose: This script reads PDF files and renames them.
# Version: 0.8.1
################################################################################

# Modes: --file or --folder
# Setze den Standardwert für MODE auf "--folder" und für TARGET auf das aktuelle Verzeichnis, falls keine Parameter angegeben sind
MODE="--folder"
TARGET="."

# Parse Parameters
if [ $# -eq 0 ]; then
	echo "INFO: No parameters. Assuming MODE = --folder and TARGET = $(pwd)" && echo
elif [ $# -eq 2 ]; then
	# DEBUG
	#echo "DEBUG: 1 is $1 and 2 is $2"
	
	if [ "$1" == "--file" ]; then
		MODE="--file"
	elif [ "$1" == "--folder" ]; then
		MODE="--folder"
	else
		echo "Error: Invalid first parameter. Expected --file or --folder"
		exit 1
	fi
	TARGET="$2"
	if [ ! -e "$TARGET" ]; then
		echo "Error: Target does not exist: $TARGET"
		exit 1
	fi
else
	echo "Error: Invalid number of parameters. Expected 0 or 2."
	exit 1
fi

# Funktion zum Überprüfen der installierten Programme
pre_flight_check() {

    # Check if necessary programs are installed
    local programs=("tesseract" "awk" "ocrmypdf" "rename" "pdftotext" "qpdf")
    for program in "${programs[@]}"; do
        command -v "$program" >/dev/null 2>&1 || { echo "$program is required but not installed. Exiting." >&2; exit 1; }
    done

    # Fix input files with spaces in filename
    IFS=$'\n'

	if [ "$MODE" == "--folder" ]; then
		if ! ls "$TARGET"/*.pdf 1>/dev/null 2>&1; then
			echo "Keine PDFs vorhanden"
			exit 1
		fi
		
		# Check if directory contains any pdf files
		pdf_files=$(find "$TARGET" -maxdepth 1 -iname "*.pdf" -print)
		if [ -z "$pdf_files" ]; then
			echo "No pdf files found in directory: $TARGET"
        exit 1
		else
			rename 's/\.([^.]+)$/.\L$1/' "$TARGET"/*
		fi
	fi
	
	if [ "$MODE" == "--file" ]; then
		rename 's/\.pdf$/.pdf/i' "$TARGET"
	fi

}

# Funktion zur Konvertierung von PDF in Text
pdf_to_text() {

	if [ "$MODE" == "--folder" ]; then
	    cd "$TARGET" || { echo "Cannot change directory to $TARGET. Exiting." >&2; exit 1; }
		for f in *.pdf; do
			# Überprüfen, ob die entsprechende Textdatei bereits existiert
			if [ -e "${f%.pdf}.txt" ]; then
				echo "Textdatei existiert bereits, überspringe: ${f%.pdf}.txt"
				continue
			fi
		
			# PDF in Text konvertieren
			pdftotext "$f" "${f%.pdf}.txt"
			#echo "converted to TXT: $f"
		done		
	fi 

	if [ "$MODE" == "--file" ]; then	
		f="$TARGET"
		cd "$(dirname "$f")"
		if [ -e "${f%.pdf}.txt" ]; then
			echo "Textdatei existiert bereits, überspringe: ${f%.pdf}.txt"
			return
		fi
		
		# PDF in Text konvertieren
		pdftotext "$f" "${f%.pdf}.txt"
		#echo "converted to TXT: $f"
	fi
	
	# Lade Variablen aus separaten Datei
	source ./.ocr-and-rename/vars.txt
}

safe_rename() {
    local old_filename="$1"
    local new_filename="$2"
	local old_textfile="${old_filename%.*}.txt"
	local new_textfile="${new_filename%.*}.txt"
	
	#echo "DEBUG: old_filename: $old_filename, new_filename: $new_filename, old_textfile: $old_textfile, new_textfile: $new_textfile"
	
    # Prüfen, ob der neue Dateiname bereits existiert
    if [ -e "$new_filename" ]; then
		echo "DEBUG: Der neue Dateiname existiert bereits: $new_filename"
		# Prüfen, ob eine Textdatei mit demselben Dateinamen existiert
        if [ -e "$new_textfile" ]; then
            # Beide Dateien existieren, also lösche die Textdatei
            rm "$old_textfile"
        else
			# Es existiert nur die Zieldatei, aber keine Quell-Textdatei dazu
			local base="${new_filename%.*}"
			local extension="${new_filename##*.}"
			local suffix="_DEDUP_"
			local counter=1
			safeNewName=""
			
			while true; do
				safeNewName="${base}${suffix}${counter}.${extension}"
				echo "Checking safeNewName: $safeNewName"
				if [ ! -e "$safeNewName" ]; then
					echo "$safeNewName is unique. Found a new name"
					break
				fi
				echo "$safeNewName already exists! Counting up"
				((counter++))
			done
			
			mv "$old_filename" "$safeNewName" && rm "$old_textfile"
			echo "GOOD: "$old_filename" --> "$safeNewName""
		fi
    fi

    # Falls nur eine Datei mit demselben Zielnamen (ohne Textdatei) existiert,
    # dann tue nichts; andernfalls, benenne die Datei um
    if [ ! -e "$new_filename" ]; then
        mv "$old_filename" "$new_filename" && rm "$old_textfile" && echo "GOOD: "$old_filename" --> "$new_filename""
    fi
}

renaultBank() {
    local text_file="$1"
	[ -e "$text_file" ] || return

    # Check if file is a Renault Bank Kontoauszug
    if grep -q "$renault" "$text_file"; then
        echo "INFO: $(basename "$text_file") is a Renault Bank Kontoauszug"
        datum=$(grep -B1 "1 von" "$text_file" | head -1 | awk -v FS=/ '{print $2,$1}' | sed -e 's: :-:g')
        filename=${text_file%.*}
		local new_filename="Renault Bank Kontoauszug $datum.pdf"
		safe_rename "$filename.pdf" "$new_filename"
    fi
}

klarmobilRech() {
	local text_file="$1"
	[ -e "$text_file" ] || return

	# Check if file is a Klarmobil Rechnung
	if grep -q "$klarmob" "$text_file" && grep -q "$klarmobNr" "$text_file" && grep -q "$klarmobRech" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a Klarmobil Rechnung"
		datum=$(grep -B2 "$klarmob" "$text_file" | head -1 | awk -v FS=. '{print $3,$2}' | sed -e 's: :-:g')
		filename=${text_file%.*}
		local new_filename="Rechnung Klarmobil $datum.pdf"
		safe_rename "$filename.pdf" "$new_filename"
	fi

}

klarmobilEvn() {
	local text_file="$1"
	[ -e "$text_file" ] || return

	# Check if file is a Klarmobil Einzelverbindungsnachweis
	if grep -q "$klarmob" "$text_file" && grep -q "$klarmobNr" "$text_file" && grep -q "$klarmobEvn" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a Klarmobil Einzelverbindungsnachweis"
		datum=$(grep -B2 "$klarmob" "$text_file" | head -1 | awk -v FS=. '{print $3,$2}' | sed -e 's: :-:g')
		filename=${text_file%.*}
		local new_filename="EVN Klarmobil $datum.pdf"
		safe_rename "$filename.pdf" "$new_filename"
	fi

}

tradeRepublic() {
	local text_file="$1"
	echo "DEBUG: Übergebener Wert für text_file ist: $text_file"
	[ -e "$text_file" ] || return

	# Check if file is a Trade Republic ETF Sparplan Abrechnung
	if grep -q "$tr1" "$text_file" && grep -q "$tr2" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a Trade Republic ETF Sparplan Abrechnung"
		datum=$(grep "Sparplanausführung am" "$text_file" | head -1 | awk '{print $3}' | awk -v FS=. '{print $3,$2,$1}' | sed -e 's: :-:g')
		isin=$(grep "ISIN" "$text_file" | head -1 | awk '{print $2}')
		filename=${text_file%.*}
		
		local new_filename="$datum TR Wertpapierabrechnung Sparplan"
		
		case "$isin" in 
			"$ftseAccISIN") new_filename+=" Vanguard FTSE All-World (Acc).pdf" ;;
			"$ftseDistISIN") new_filename+=" Vanguard FTSE All-World (Dist).pdf" ;;
			"$worldSRIAccISIN") new_filename+=" MSCI World SRI EUR (Acc).pdf" ;;
			"$emSRIAccISIN") new_filename+=" MSCI EM SRI USD (Acc).pdf" ;;
			*) echo "Unknown ISIN: $isin"; return ;;
		esac

		#echo "DEBUG: ISIN: $isin, old filename: $filename.pdf, new_filename: $new_filename"
		
		safe_rename "$filename.pdf" "$new_filename"
		#mv "$filename.pdf" "$new_filename" && rm "$filename.txt"
	fi
}

tradeRepublicSaveback() {
	local text_file="$1"
	echo "DEBUG: Übergebener Wert für text_file ist: $text_file"
	[ -e "$text_file" ] || return

	# Check if file is a Trade Republic ETF Saveback Abrechnung
	if grep -q "$trSaveback" "$text_file" && grep -q "$tr2" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a Trade Republic ETF Saveback Abrechnung"
		datum=$(grep "Ausführung von Saveback am" "$text_file" | head -1 | awk '{print $5}' | awk -v FS=. '{print $3,$2,$1}' | sed -e 's: :-:g')
		isin=$(grep "ISIN" "$text_file" | head -1 | awk '{print $2}')
		filename=${text_file%.*}
		
		local new_filename="$datum TR Wertpapierabrechnung Saveback"
		
		case "$isin" in 
			"$ftseAccISIN") new_filename+=" Vanguard FTSE All-World (Acc).pdf" ;;
			"$ftseDistISIN") new_filename+=" Vanguard FTSE All-World (Dist).pdf" ;;
			"$worldSRIAccISIN") new_filename+=" MSCI World SRI EUR (Acc).pdf" ;;
			"$emSRIAccISIN") new_filename+=" MSCI EM SRI USD (Acc).pdf" ;;
			*) echo "Unknown ISIN: $isin"; return ;;
		esac

		#echo "DEBUG: ISIN: $isin, old filename: $filename.pdf, new_filename: $new_filename"
		
		safe_rename "$filename.pdf" "$new_filename"
		#mv "$filename.pdf" "$new_filename" && rm "$filename.txt"
	fi
}

vodafone() {
	local text_file="$1"
	[ -e "$text_file" ] || return

	if grep -q "$vod1" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a Vodafone Rechnung"
		datum=$(grep -B1 "$vod2" "$text_file" | head -1 | awk -v FS=. '{print $3,$2}' | sed -e 's: :-:g')
		filename=${text_file%.*}
		local new_filename="Rechnung Vodafone $datum.pdf"
		safe_rename "$filename.pdf" "$new_filename"
	fi
}

dkbGirokonto() {
	local text_file="$1"
	[ -e "$text_file" ] || return

	if grep -q "$dkb1" "$text_file" && grep -q "$dkb2" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a DKB Girokonto Kontoauszug"
		# Fetch Auszug Nummer and Year
		year=$(grep -A 2 "Seite 1 von" "$text_file" | tail --lines 1 | grep -oP '\d{4}')
		month=$(grep -A 2 "Seite 1 von" "$text_file" | tail --lines 1 | grep -oP '\d+/(?=\d{4})' | grep -oP '\d+' | awk '{printf "%02d\n", $1}')
		filename=${text_file%.*}
		local new_filename="DKB Kontoauszug $year-$month.pdf"
		safe_rename "$filename.pdf" "$new_filename"
	fi
}

dkbTagesgeld() {
	local text_file="$1"
	[ -e "$text_file" ] || return

	if grep -q "$dkbTg" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a DKB Tagesgeld Kontoauszug"
		year=$(grep -A 2 "Seite 1 von" "$text_file" | tail --lines 1 | grep -oP '\d{4}')
		month=$(grep -A 2 "Seite 1 von" "$text_file" | tail --lines 1 | grep -oP '\d+/(?=\d{4})' | grep -oP '\d+' | awk '{printf "%02d\n", $1}')
		filename=${text_file%.*}
		local new_filename="DKB Kontoauszug Tagesgeld $year-$month.pdf"
		safe_rename "$filename.pdf" "$new_filename"
	fi
}

simplytel() {
	local text_file="$1"
	[ -e "$text_file" ] || return

	if grep -q $SimplyKdNr "$text_file"; then
		echo "INFO: $(basename "$text_file") is a Simply Rechnung"
		datumDE=$(grep -B2 $SimplyKdNr $text_file | head -1)
		datumEN=$(echo $datumDE | awk -v FS=. '{print $3,$2,$1}' | sed -e 's: :-:g')
		datumMON=$(echo $datumEN | awk -v FS=- '{print $1,$2}' | sed -e 's: :-:g')
		filename=${text_file%.*}
		local new_filename=""
		if grep -q "stellen wir Ihnen in Rechnung" "$text_file"; then
			new_filename="SimplyTel Rechnung $datumMON.pdf"
		elif grep -q "Komfort-Einzelverbindungsnachweis" "$text_file"; then 
			new_filename="SimplyTel EVN $datumMON.pdf"
		fi
		safe_rename "$filename.pdf" "$new_filename"
	fi
}

o2() {
	local text_file="$1"
	[ -e "$text_file" ] || return

	if grep -q "$O2Header" "$text_file" && grep -q "$O2Rech" "$text_file" && grep -q "$O2KdNr" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a O2 Rechnung"
		datum=$(grep -A 7 "Rechnungsdatum" "$text_file" | tail --lines 1 | awk -F'.' '{print $3,$2}' | sed -e 's: :-:g')
		filename=${text_file%.*}
		
		# Remove protection from pdf
		rand=$RANDOM
		mkdir -p ./tmp
		local new_filename="Rechnung O2 $datum.pdf"
		qpdf --decrypt "$filename.pdf" "./tmp/$rand.pdf"
		echo "INFO: Decrypted $filename.pdf"
		mv "./tmp/$rand.pdf" "$filename.pdf" && rm -rf "./tmp"
		
		safe_rename "$filename.pdf" "$new_filename"		
	fi
}

simDotDe() {
	local text_file="$1"
	[ -e "$text_file" ] || return

	if grep -q "$sim1" "$text_file" && grep -q "$sim2" "$text_file"; then
		echo "INFO: $(basename "$text_file") is a sim.de Rechnung"
		datum=$(grep "$sim3" "$text_file" | head --lines 1 | awk -F '[.]' '{print $NF,$(NF-1)}' | sed -e 's: :-:g')
		#year=$(grep "$sim3" "$text_file" | head --lines 1 | awk -F '[.]' '{print $NF}')
        #month=$(grep "$sim3" "$text_file" | head --lines 1 | awk -F '[.]' '{print $(NF-1)}')
		filename=${text_file%.*}
		#local new_filename="Rechnung sim.de $year-$month.pdf"
		local new_filename="Rechnung sim.de $datum.pdf"
		safe_rename "$filename.pdf" "$new_filename"
	fi
}

tradeRepublicZinsen(){
	local text_file="$1"
	[ -e "$text_file" ] || return
	
	# Check if file is a TR Zinsen Abrechnung
	if grep -q "$trZin1" "$text_file" && grep -q "$trZin2" "$text_file" && grep -q "$trZin3" "$text_file" && grep -q "$trZin4" "$text_file"; then
		echo "INFO: $text_file is a TR Zinsen Abrechnung"
		datum=$(grep -E "$trZinRegEx" "$text_file" | awk -F '[.]' '{print $NF,$(NF-1)}' | sed -e 's: :-:g')
		filename=${text_file%.*}
		local new_filename="TR Zinsen $datum.pdf"
		safe_rename "$filename.pdf" "$new_filename"
	fi
}

run_all_checks() {

	renaultBank "$1"
	klarmobilRech "$1"
	klarmobilEvn "$1"
	tradeRepublic "$1"
	vodafone "$1"
	dkbGirokonto "$1"
	dkbTagesgeld "$1"
	simplytel "$1"
	o2 "$1"
	simDotDe "$1"
	tradeRepublicZinsen "$1"
	tradeRepublicSaveback "$1"
}

main() {

	pre_flight_check
    pdf_to_text
	
	if [ "$MODE" == "--file" ]; then
		#echo "DEBUG: MODE is $MODE"
		f=${TARGET%.*}
		run_all_checks "$f.txt"
		echo 
	elif [ "$MODE" == "--folder" ]; then
		#echo "DEBUG: MODE is $MODE"
		for f in $(ls *.txt); do
			run_all_checks "$f"
			echo
		done
	else
		echo "ERROR: check your program :("
		exit 1
	fi
	
	exit 0
}

# Aufrufen der Hauptfunktion
main
