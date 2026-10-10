#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <directory_to_monitor> <quarantine_directory> <interval-seconds>"
    exit 1
fi

dir="$1"
malicious_dir="$2"
interval="$3"

if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist."
    exit 1
fi

if ! [[ "$interval" =~ ^[0-9]+$ ]] || [ "$interval" -le 0 ]; then
    echo "Error: Interval must be a positive integer."
    exit 1
fi

if ! mkdir -p "$malicious_dir"; then
    echo "Error: Could not create quarantine directory '$malicious_dir'."
    exit 1
fi


flagged_extensions=("exe" "bat" "vbs" "scr" "ps1")
flagged_keywords=("virus" "trojan" "malware" "worm" "ransomware")

scan_directory() {
    for file in "$dir"/*; do
        
        [ -f "$file" ] || continue

        filename=$(basename "$file")
        malicious=false

        
        if [[ "$filename" == *.* ]]; then
            extension="${filename##*.}"
            for ext in "${flagged_extensions[@]}"; do
                if [ "$extension" = "$ext" ]; then
                    malicious=true
                    break
                fi
            done
        fi

        
        if [ "$malicious" = false ]; then
            for keyword in "${flagged_keywords[@]}"; do
                if grep -Fqi -- "$keyword" "$file" 2>/dev/null; then
                    malicious=true
                    break
                fi
            done
        fi

        if [ "$malicious" = true ]; then
            echo "$filename is malicious and it is DELETED"
            if cp -- "$file" "$malicious_dir/$filename"; then
                rm -- "$file" || echo "Error: could not delete '$filename'."
            else
                echo "Error: could not copy '$filename' to quarantine. Original kept."
            fi
        fi
    done
}

snapshot_last="directory-info.last"
snapshot_new="directory-info.new"


if [ ! -f "$snapshot_last" ]; then
    scan_directory
    ls -l -- "$dir" > "$snapshot_last"
fi

while true; do
    sleep "$interval"

    ls -l -- "$dir" > "$snapshot_new"

    if ! diff -q "$snapshot_last" "$snapshot_new" > /dev/null; then
        
        ls -l -- "$dir" > "$snapshot_last"
    fi
done
