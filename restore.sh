#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory_to_monitor> <quarantine_directory>"
    exit 1
fi

dir="$1"
malicious_dir="$2"

if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist."
    exit 1
fi

if [ ! -d "$malicious_dir" ]; then
    echo "Error: Quarantine directory '$malicious_dir' does not exist."
    exit 1
fi

first_run=true

while true; do

    files=()
    for file in "$malicious_dir"/*; do
        if [ -f "$file" ]; then
            files+=("$file")
        fi
    done

    if [ "${#files[@]}" -eq 0 ]; then
        if [ "$first_run" = true ]; then
            echo "No malicious files to review."
        else
            echo "Quarantine is now empty."
        fi
        exit 0
    fi
    first_run=false

    echo "Files in quarantine:"
    for i in "${!files[@]}"; do
        echo "$((i + 1)): $(basename "${files[$i]}")"
    done

    read -r -p "Choose a file: " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Invalid selection. Please enter a number."
        continue
    fi

    if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]; then
        echo "Invalid selection. Please choose a number from the list."
        continue
    fi

    selected_file="${files[$((choice - 1))]}"
    filename=$(basename "$selected_file")

    echo "For $filename:"
    echo "1: Restore this file back into $dir (it was a false positive)"
    echo "2: Permanently delete this file from $malicious_dir (it was genuinely malicious)"
    echo "3: Leave this file as-is and go back to the list"

    read -r -p "> " option

    case "$option" in
        1)
            if [ -e "$dir/$filename" ]; then
                echo "Cannot restore: '$dir/$filename' already exists."
                continue
            fi
            if cp -- "$selected_file" "$dir/$filename"; then
                if rm -- "$selected_file"; then
                    echo "Restored $filename to $dir."
                else
                    echo "Error: copied back, but could not remove from quarantine."
                fi
            else
                echo "Error: Could not restore '$filename'."
            fi
            ;;
        2)
            if rm -- "$selected_file"; then
                echo "$filename permanently deleted."
            else
                echo "Error: Could not delete '$filename'."
            fi
            ;;
        3)
            continue
            ;;
        *)
            echo "Invalid option. Please choose 1, 2, or 3."
            ;;
    esac

done
