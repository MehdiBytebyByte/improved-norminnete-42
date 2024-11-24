#!/bin/bash

# Use `find` to iterate over all files and directories
find . -type f -o -type d | while read -r file; do
    # Skip files ending with .c, .h, or named Makefile
    if [[ ! $file =~ \.c$ && ! $file =~ \.h$ && $(basename "$file") != "Makefile" ]]; then
        read -p "Do you want to delete '$file'? (y/n): " response
        case "$response" in
            [yY]) 
                rm -rf "$file"
                echo "'$file' has been deleted."
                ;;
            [nN]) 
                echo "'$file' was not deleted."
                ;;
            *) 
                echo "Invalid response. Skipping '$file'."
                ;;
        esac
    fi
done

echo "Cleanup process completed."
