#!/bin/bash

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
PURPLE="\033[1;35m"
NC="\033[0m"

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
	local files
	files=($(find . -type f \( -name "*.c" -o -name "*.h" \)))

	check_files "${files[@]}"

	echo -e "${BLUE}All files have been checked.${NC}"
	echo -e "\n${PURPLE}Norminette issues count is = ${issue_count}${NC}"
	print_final_message "$issue_count"
}

run_cleanup() {
	for file in *; do
		if [[ -d $file ]]; then
			for dir_file in "$file"/*; do
				if [[ ! $dir_file =~ \.c$ && ! $dir_file =~ \.h$ && $dir_file != "Makefile" ]]; then
					read -p "Do you want to delete '$dir_file'? (y/n): " response
					case "$response" in
						[yY]) 
							rm -rf "$dir_file"
							echo "'$dir_file' has been deleted."
							;;
						[nN]) 
							echo "'$dir_file' was not deleted."
							;;
						*) 
							echo "Invalid response. Skipping '$dir_file'."
							;;
					esac
				fi
			done
		elif [[ ! $file =~ \.c$ && ! $file =~ \.h$ && $file != "Makefile" ]]; then
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

run_gitignore() {
	> .gitignore

	for file in *; do
		if [[ -d $file ]]; then
			# If it's a directory, add its contents to the .gitignore
			echo "Checking directory: '$file'"
			for dir_file in "$file"/*; do
				if [[ ! $dir_file =~ \.c$ && ! $dir_file =~ \.h$ && $dir_file != "Makefile" ]]; then
					echo "$dir_file" >> .gitignore
				fi
			done
		elif [[ ! $file =~ \.c$ && ! $file =~ \.h$ && $file != "Makefile" ]]; then
			# If it's not a directory and matches criteria, add it to the .gitignore
			echo "$file" >> .gitignore
		fi
	done

	echo ".gitignore updated with non-C source files and non-Makefile entries."
}

# run_project_setup() {
#     mkdir -p src include
#     echo "Checking and moving source files..."

#     for file in $(find . -maxdepth 1 -type f -name "*.c"); do
#         mv "$file" "src/"
#         echo "Moved $file to src/"
#     done

#     for file in $(find . -maxdepth 1 -type f -name "*.h"); do
#         mv "$file" "include/"
#         echo "Moved $file to include/"
#     done

#     echo "Updating Makefile paths..."
#     if [[ -f Makefile ]]; then
#         SRCS=$(find src/ -type f -name "*.c" | sed 's#//*#/#g' | sed 's#^#src/#' | tr '\n' ' ')
#         sed -i'' -E "
#             s#^SRCS *=.*#SRCS = $SRCS#;
#         " Makefile
#         echo "Makefile paths updated."
#     else
#         echo "Makefile not found. Skipping update."
#     fi

#     update_includes
#     echo -e "${GREEN}Project setup completed successfully!${NC}"
# }


update_includes() {
    echo "Updating #include paths in .c files..."

    # Loop through all .c files in the src/ directory
    find src/ -type f -name "*.c" | while read -r file; do
        # Use sed to update #include "example.h" to #include "../include/example.h"
        sed -i '' -E 's|#include "([a-zA-Z0-9_]+\.h)"|#include "../include/\1"|g' "$file"
        echo "Updated includes in $file"
    done

    echo "All #include paths updated successfully!"
}

# run_project_setup() {
#     mkdir -p src include
#     echo "Checking and moving source files..."

#     for file in $(find . -maxdepth 1 -type f -name "*.c"); do
#         mv "$file" "src/"
#         echo "Moved $file to src/"
#     done

#     for file in $(find . -maxdepth 1 -type f -name "*.h"); do
#         mv "$file" "include/"
#         echo "Moved $file to include/"
#     done

#     echo "Updating Makefile paths..."
#     if [[ -f Makefile ]]; then
#         # Dynamically find all .c files and ensure paths are normalized to start with "src/"
#         SRCS=$(find src/ -type f -name "*.c" | sed 's#^src/##' | sed 's#^#src/#' | tr '\n' ' ')
        
#         # Update the SRCS line in the Makefile
#         sed -i'' -E "
#             s#^SRCS *=.*#SRCS = $SRCS#;
#         " Makefile
#         echo "Makefile paths updated."
#     else
#         echo "Makefile not found. Skipping update."
#     fi

#     # Update include paths in .c files (if needed)
#     update_includes
#     echo -e "${GREEN}Project setup completed successfully!${NC}"
# }




# run_project_setup() {
#     mkdir -p src include
#     c_files=()
#     h_files=()

#     echo "Checking and moving source files..."

#     while IFS= read -r file; do
#         filename=$(basename "$file")
#         if [[ ! "$file" =~ ^src/ ]]; then
#             c_files+=("$file")
#         fi
#     done < <(find . -maxdepth 1 -type f -name "*.c")

#     while IFS= read -r file; do
#         filename=$(basename "$file")
#         if [[ ! "$file" =~ ^include/ ]]; then
#             h_files+=("$file")
#         fi
#     done < <(find . -maxdepth 1 -type f -name "*.h")

#     if [ ${#c_files[@]} -gt 0 ]; then
#         for file in "${c_files[@]}"; do
#             mv "$file" "src/"
#             echo "Moved $file to src/"
#         done
#     else
#         echo "No .c files needed to be moved."
#     fi

#     if [ ${#h_files[@]} -gt 0 ]; then
#         for file in "${h_files[@]}"; do
#             mv "$file" "include/"
#             echo "Moved $file to include/"
#         done
#     else
#         echo "No .h files needed to be moved."
#     fi

#     echo "Updating Makefile paths..."
#     if [[ -f Makefile ]]; then
# 		SRCS=$(find src/ -name "*.c" | sort | sed 's#^src/##' | tr '\n' ' ' | sed 's/ $//')
# 		HEADER=$(find include/ -name "*.h" | sort | sed 's#^include/##' | tr '\n' ' ' | sed 's/ $//')
# 		SRCS_WITH_PREFIX=$(find src/ -name "*.c" | sort | sed 's#^#src/#' | tr '\n' ' ' | sed 's/ $//')
# 		HEADER_WITH_PREFIX=$(find include/ -name "*.h" | sort | sed 's#^#include/#' | tr '\n' ' ' | sed 's/ $//')

# sed -i'' -E "
#     s#SRCS *=.*#SRCS = $HEADER#;
#     s#HEADER *=.*#HEADER = $HEADER#;
#     s#OBJS *=.*#OBJS = \$(SRCS:.c=.o)#
# " Makefile

# 		SRCS=$(echo "$SRCS" | sed 's#^#src/#' | tr '\n' ' ' | sed 's/ $//')
#         HEADER=$(echo "$HEADER" | sed 's#^#include/#g' | tr '\n' ' ' | sed 's/ $//')
# 		SRCS=$(find src/ -type f -name "*.c" | sed 's#^#src/#' | tr '\n' ' ')
# sed -i'' -E "
#     s#^SRCS *=.*#SRCS = $SRCS#;
# " Makefile


#         echo "Makefile paths updated."
#     else
#         echo "Makefile not found. Skipping update."
#     fi

#     update_includes
#     echo -e "${GREEN}Project setup completed successfully!${NC}"
# }
echo -e "\n${BLUE}=== 42 Project Utility Script ===${NC}"
echo -e "${GREEN}What would you like to do?${NC}"
echo -e "${GREEN}1. Run Norminette Checker${NC}"
echo -e "${GREEN}2. Clean Up Project Directory${NC}"
echo -e "${GREEN}3. Generate .gitignore${NC}"
echo -e "${GREEN}4. Make src and includes folder ${NC}"
echo -e "${GREEN}5. Exit${NC}"
echo -e "\n${YELLOW}Select an option (1-4):${NC}"

read -r choice

case $choice in
	1)
		run_norminette
		;;
	2)
		run_cleanup
		;;
	3)
		run_gitignore
		;;
	4)
		run_project_setup
		;;
	5)
		echo -e "${PURPLE}Exiting the utility script. Goodbye!${NC}"
		echo -e "\n${GREEN}Script created by ${RED}\033]8;;https://github.com/MehdiBytebyByte\033\\Mehdi Boughrara\033]8;;${NC}"
		exit 0
		;;
	*)
		echo -e "${RED}Invalid option. Please select 1-4.${NC}"
		exit 1
		;;
esac
echo -e "\n${GREEN}Script created by ${RED}\033]8;;https://github.com/MehdiBytebyByte\033\\Mehdi Boughrara\033]8;;${NC}"
