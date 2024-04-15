#!/bin/bash

# Das Programm, das gestartet werden soll
PROGRAM="/home/pi/public/Scan/.ocr-and-rename/ocr-and-rename.sh"

# Modes: --file or --folder
MODE="--folder"

# Der Zielordner, der überwacht werden soll
FOLDER="/home/pi/public/Scan"
TARGET="/home/pi/public/Scan"

# Liste der bereits verarbeiteten Dateien
#processed_files=()

# Funktion zur Verarbeitung neuer PDF-Dateien
process_pdf() {
    local file="$1"
    # Überprüfen, ob die Datei eine PDF ist
    if [[ "$file" == *.pdf ]]; then
		MODE="--file"
		TARGET="$FOLDER/$file"
		#echo "DEBUG: " "$PROGRAM" "$MODE" "$TARGET"
        "$PROGRAM" "$MODE" "$TARGET" &
    fi
}

# Überwachen des Zielordners
inotifywait -m -e create "$TARGET" | while read FILE
do
    # Extrahieren des Dateinamens aus der Ausgabe von inotifywait
    file=$(echo "$FILE" | awk '{print $3}')
    # Verarbeitung der neuen PDF-Datei
    process_pdf "$file"
done
