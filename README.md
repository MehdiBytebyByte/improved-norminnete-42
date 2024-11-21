# 42TOOLS

(WARNING  !!!)
	Make sure to duplicate your folder before trying this script

A utility script designed to streamline the workflow for 42 projects. This script provides several functions, including running the Norminette checker, cleaning up project files, generating a `.gitignore` file, and setting up your project directories. It is especially useful for managing your 42 C projects with a clean and organized file structure.

## Features

1. **Run Norminette Checker**  
   - Runs the Norminette linter on all `.c` and `.h` files in the project.
   - Provides detailed output for each file, showing the number of errors and where they are located.
   - Displays a final message based on the number of issues detected.

2. **Clean Up Project Directory**  
   - Prompts you to delete non-C source files, non-header files, and non-Makefile files from your project directory.
   - Helps remove unnecessary files to keep your project clean and focused on C code.

3. **Generate `.gitignore`**  
   - Automatically generates a `.gitignore` file by adding non-C, non-header, and non-Makefile files to it.
   - Keeps unnecessary files from being tracked by Git.

4. **Setup Project Structure**  
   - Creates `src/` and `include/` directories if they don't exist.
   - Moves `.c` files to the `src/` directory and `.h` files to the `include/` directory.
   - Updates the `Makefile` to reflect the correct paths for `SRCS` and `HEADER`.

5. **Update Include Paths**  
   - Updates the `#include` paths in all `.c` files to reference the `include/` directory.

## Usage

1. Make the script executable by running:

   ```bash
   chmod +x 42tools.sh

2. Run the script by executing:

./42tools.sh

Requirements
Norminette: This script assumes that you have Norminette installed and available in your PATH

Note: Please ensure that you understand the changes this script will make to your project, especially when it comes to moving files and deleting unnecessary ones. Always keep backups of important files before running any script that modifies your project structure.

