#!/bin/bash

dir="$1"
malicious_dir="$2"

while true; do

    files=("$malicious_dir"/*)

    if [ ! -e "${files[0]}" ]; then
        echo "No malicious files to review."
        exit 0
    fi

    echo "Files in quarantine:"

    i=1

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            echo "$i. $(basename "$file")"
            i=$((i + 1))
        fi
    done

    echo "Enter the number of the file you want to review:"
    read choice

    selected_file="${files[$((choice - 1))]}"

    if [ ! -f "$selected_file" ]; then
        echo "Invalid selection."
        continue
    fi

    filename=$(basename "$selected_file")

    echo "1. Restore this file back into dir"
    echo "2. Permanently delete this file from malicious_dir"
    echo "3. Leave this file as-is and go back to the list"

    read option

    case "$option" in
        1)
            cp "$selected_file" "$dir/"
            rm "$selected_file"
            echo "Restored $filename to $dir."
            ;;

        2)
            rm "$selected_file"
            echo "$filename permanently deleted."
            ;;

        3)
            ;;

        *)
            echo "Invalid option."
            ;;
    esac
done
