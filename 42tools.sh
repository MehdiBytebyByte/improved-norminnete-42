#!/bin/bash

# Color Definitions
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
PURPLE="\033[1;35m"
NC="\033[0m"

# Norminette Function
run_norminette() {
    local issue_count=0

    print_final_message() {
        local count=$1

        if (( count == 0 )); then
            echo -e "${GREEN}🎉 Awesome! No norm errors found! Keep it up!${NC}"
        elif (( count <= 3 )); then
            echo -e "${GREEN}😄 Great job! Just a few minor issues (${count})!${NC}"
        elif (( count <= 7 )); then
            echo -e "${YELLOW}😬 Uh-oh! You have ${count} errors. Not bad, but let's improve!${NC}"
        elif (( count <= 15 )); then
            echo -e "${RED}😱 Oh no! ${count} norm errors detected! Time to buckle down!${NC}"
        elif (( count <= 25 )); then
            echo -e "${RED}🤦‍♂️ Yikes! ${count} errors! You might need a coffee break!${NC}"
        elif (( count <= 40 )); then
            echo -e "${RED}💔 Ouch! ${count} errors! This is starting to hurt!${NC}"
        else
            echo -e "${RED}👀 Whoa there! ${count} errors! Only god can help you!${NC}"
        fi
    }

    check_files() {
        local files=("$@")
        
        echo -e "${BLUE}Running norminette on files...${NC}"

        for file in "${files[@]}"; do
            echo -e "${BLUE}Checking $file...${NC}"

            norm_output=$(norminette "$file")

            while IFS= read -r line; do
                line=${line#-e }

                if [[ $line == OK* ]]; then
                    echo -e "${YELLOW}✅ $line${NC}"
                elif [[ $line == Error* ]]; then
                    ((issue_count++))

                    if [[ $line =~ line:\ *([0-9]+),\ col:\ *([0-9]+) ]]; then
                        line_num="${BASH_REMATCH[1]}"
                        col_num="${BASH_REMATCH[2]}"
                        
                        error_type=$(echo "$line" | cut -d' ' -f1-2)
                        error_desc=$(echo "$line" | cut -d')' -f2-)
                        echo -e "${RED}$error_type${NC} --> ${GREEN}$file:$line_num:$col_num${NC} <--${RED}$error_desc${NC}"
                    else
                        echo -e "${RED}$line${NC}"
                    fi
                else
                    echo "$line"
                fi
            done <<< "$norm_output"

            echo -e "${BLUE}---- Finished checking $file ----${NC}"
        done
    }

    # Argument handling for norminette
    local files
    if [ "$#" -eq 0 ]; then
        files=($(find . -type f \( -name "*.c" -o -name "*.h" \)))
    else
        if [ -d "$1" ]; then
            files=($(find "$1" -type f \( -name "*.c" -o -name "*.h" \)))
        elif [[ "$1" == *.c || "$1" == *.h ]]; then
            files=("$1")
        else
            echo -e "${RED}Invalid argument. Please provide a directory or a .c/.h file.${NC}"
            return 1
        fi
    fi

    check_files "${files[@]}"

    echo -e "${BLUE}All files have been checked.${NC}"
    echo -e "\n${PURPLE}Norminette issues count is = ${issue_count}${NC}"
    print_final_message "$issue_count"
}

# Cleanup Function
run_cleanup() {
    for file in *; do
        if [[ ! $file =~ \.c$ && ! $file =~ \.h$ && $file != "Makefile" ]]; then
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
}

# Gitignore Generation Function
run_gitignore() {
    > .gitignore

    for file in *; do
        if [[ ! $file =~ \.c$ && ! $file =~ \.h$ && $file != "Makefile" ]]; then
            echo "$file" >> .gitignore
        fi
    done

    echo ".gitignore updated with non-C source files and non-Makefile entries."
}

# Main Menu
main_menu() {
    while true; do
        echo -e "\n${BLUE}=== 42 Project Utility Script ===${NC}"
		echo -e "${GREEN}What would you like to do?${NC}"
        echo -e "${GREEN}1. Run Norminette Checker${NC}"
        echo -e "${GREEN}2. Clean Up Project Directory${NC}"
        echo -e "${GREEN}3. Generate .gitignore${NC}"
        echo -e "${GREEN}4. Exit${NC}"
        echo -e "\n${YELLOW}Select an option (1-4):${NC}"

        read -r choice

        # If user just presses Enter, default to Norminette check
        if [ -z "$choice" ]; then
            choice=1
        fi

        case $choice in
            1)
                echo -e "${BLUE}Enter a file or directory to check (or press Enter for all C/H files):${NC}"
                read -r target
                if [ -z "$target" ]; then
                    run_norminette
                else
                    run_norminette "$target"
                fi
                ;;
            2)
                run_cleanup
                ;;
            3)
                run_gitignore
                ;;
            4)
                echo -e "${PURPLE}Exiting the utility script. Goodbye!${NC}"
				echo -e "\n${GREEN}Script created by ${RED}\033]8;;https://github.com/MehdiBytebyByte\033\\Mehdi Boughrara\033]8;;${NC}"
				exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please select 1-4.${NC}"
                ;;
        esac

        read -p "Press Enter to continue..." pause
    done
}

# Check for Norminette installation
if ! command -v norminette &> /dev/null; then
    echo -e "${RED}Norminette is not installed. Some features may not work.${NC}"
fi

# Start the main menu
main_menu
