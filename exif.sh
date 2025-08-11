#!/usr/bin/env bash

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
    echo "exiftool is not installed. Please install it first."
    echo "On Debian/Ubuntu: sudo apt-get install libimage-exiftool-perl"
    echo "On macOS: brew install exiftool"
    exit 1
fi

# Check if files are provided as arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <image_file(s)>"
    echo "Example: $0 image.jpg or $0 *.jpg"
    exit 1
fi

# Process each file
for file in "$@"; do
    # Check if file exists
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        continue
    fi

    # Check if file is an image
    if file "$file" | grep -q "image"; then
        echo "Removing EXIF data from: $file"
        exiftool -all= "$file" -overwrite_original
        if [ $? -eq 0 ]; then
            echo "Successfully removed EXIF data from $file"
        else
            echo "Failed to remove EXIF data from $file"
        fi
    else
        echo "Skipping non-image file: $file"
    fi
done

echo "Processing complete!"
