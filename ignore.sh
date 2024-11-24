#!/bin/bash

# Function to check if a directory should be ignored
check_directory() {
    local dir="$1"
    
    # Skip if it's a .git directory
    if [[ "$dir" == *.git* ]]; then
        return 1
    fi

    local has_valid_files=false
    
    # Check all files in this directory and subdirectories
    while IFS= read -r -d '' file; do
        if [[ $file =~ \.(c|h)$ || $file =~ /[Mm]akefile$ ]]; then
            has_valid_files=true
            return 1  # Directory contains valid files
        fi
    done < <(find "$dir" -type f -not -path '*.git*' -print0)

    return 0  # Directory and all subdirectories have no valid files
}

# Function to process a directory and its contents
process_directory() {
    local dir="$1"
    local dir_path="${dir#./}"  # Remove leading ./ if present
    
    # Skip if it's a .git directory
    if [[ "$dir_path" == *.git* ]]; then
        return
    fi

    # Check if directory should be ignored entirely
    if [ "$dir" != "." ] && check_directory "$dir"; then
        echo "${dir_path}/" >> .gitignore
        return
    fi

    # If not ignoring the whole directory, process its contents
    for item in "$dir"/*; do
        # Skip if item is .git related
        if [[ "$item" == *.git* ]]; then
            continue
        fi

        if [ -d "$item" ]; then
            # Recursively process subdirectories
            process_directory "$item"
        elif [ -f "$item" ] && [[ ! $item =~ \.(c|h)$ && ! $item =~ /[Mm]akefile$ && "$item" != *"/.gitignore" ]]; then
            # Add non-source files to gitignore
            local rel_path="${item#./}"
            echo "$rel_path" >> .gitignore
        fi
    done
}

# Clear existing .gitignore
> .gitignore

# Process current directory and all subdirectories
process_directory "."

echo ".gitignore updated with invalid files and directories."