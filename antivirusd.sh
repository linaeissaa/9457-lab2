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

        
        [ -e "$file" ] || continue

        
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

                    if grep -Fqi -- "$keyword" "$file" 2>/dev/null; then
                        malicious=true
                        break
                    fi

                done
            fi

            
            if [ "$malicious" = true ]; then

                echo "WARNING: '$filename' is suspicious."

                
                if cp -- "$file" "$malicious_dir/"; then

                    
                    if rm -- "$file"; then
                        echo "'$filename' successfully moved to quarantine."
                    else
                        echo "Error: Could not remove '$filename' from '$dir'."
                    fi

                else
                    echo "Error: Could not copy '$filename' to quarantine. Original kept."
                fi

            fi

        fi

    done
}


snapshot_last="directory-info.last"
snapshot_new="directory-info.new"


echo "Performing initial scan of '$dir'..."
scan_directory


ls -la -- "$dir" > "$snapshot_last"

echo "Initial scan complete."
echo "Monitoring '$dir' every $interval seconds..."


while true; do

    sleep "$interval"

    
    ls -la -- "$dir" > "$snapshot_new"

    
    if ! diff -q "$snapshot_last" "$snapshot_new" > /dev/null; then

        echo "Change detected in '$dir'. Scanning..."

        
        scan_directory

        
        ls -la -- "$dir" > "$snapshot_last"

        echo "Scan complete."

    fi

done
