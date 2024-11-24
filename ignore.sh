#!/bin/bash

> .gitignore

for file in *; do
    if [[ ! $file =~ \.c$ && ! $file =~ \.h$ && $file != "Makefile" ]]; then
        echo "$file" >> .gitignore
    fi
done

echo ".gitignore updated with non-C source files and non-Makefile entries."
