#!/bin/bash

dir="$1"
malicious_dir="$2"
interval="$3"

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
                    if grep -qi "$keyword" "$file"; then
                        malicious=true
                        break
                    fi
                done
            fi

            if [ "$malicious" = true ]; then
                echo "$filename is malicious and it is DELETED"
                cp "$file" "$malicious_dir/"
                rm "$file"
            fi
        fi
    done
}

if [ ! -f directory-info.last ]; then
    scan_directory
    ls -1 "$dir" > directory-info.last
fi

while true; do
    sleep "$interval"

    ls -1 "$dir" > directory-info.new

    if diff -q directory-info.last directory-info.new > /dev/null; then
        :
    else
        scan_directory
        cp directory-info.new directory-info.last
    fi
done





