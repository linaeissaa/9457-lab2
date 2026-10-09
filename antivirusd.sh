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
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            extension="${filename##*.}"

            malicious=false

            for ext in "${flagged_extensions[@]}"; do
                if [ "$extension" = "$ext" ]; then
                    malicious=true
                    break
                fi
            done

            if [ "$malicious" = false ]; then
                for keyword in "${flagged_keywords[@]}"; do
                    if grep -Fqi -- "$keyword" "$file"; then
                        malicious=true
                        break
                    fi
                done
            fi

            if [ "$malicious" = true ]; then
                echo "$filename is malicious and it is DELETED"
                if cp -- "$file" "$malicious_dir/"; then
                if rm -- "$file"; then
                    echo "$filename moved to quarantine."
                else
                    echo "Error: Could not remove '$filename' from '$dir'."
                fi
            else
                echo "Error: Could not copy '$filename' to quarantine. Original kept."
            fi
        fi
    done
}

if [ ! -f directory-info.last ]; then
    scan_directory
    ls -l "$dir" > directory-info.last
fi

while true; do
    sleep "$interval"

    ls -l "$dir" > directory-info.new

    if diff -q directory-info.last directory-info.new > /dev/null; then
        echo "Change detected in '$dir'. Scanning..."
	scan_directory
        
        ls -l "$dir" > directory-info.last

        echo "Scan complete."
    fi
done





