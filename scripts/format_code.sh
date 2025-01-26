#!/bin/bash

# Check if a directory or file is provided as an argument
if [ -z "$1" ]; then
    echo "Warning: No directory or filename provided. Please specify a directory or a .c/.cpp file."
    exit 1
fi

# Get the absolute path of the directory where this script resides
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Get the input (directory or file)
TARGET="$1"

# Check if the input is a directory
if [ -d "$TARGET" ]; then
    # If the target is a directory, loop through all .c and .cpp files in the provided directory
    for file in $(find "$TARGET" -maxdepth 1 -type f \( -name "*.c" -or -name "*.cpp" \)); do
        if [ -f "$file" ]; then
            indent -linux "$file" -o "$file.tmp" && mv "$file.tmp" "$file"
        fi
    done
# Check if the input is a file
elif [ -f "$TARGET" ]; then
    # If the target is a single file, format it
    indent -linux "$TARGET" -o "$TARGET.tmp" && mv "$TARGET.tmp" "$TARGET"
else
    echo "Error: '$TARGET' is not a valid file or directory."
    exit 1
fi

