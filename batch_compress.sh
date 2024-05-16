#!/bin/bash

# Check if the input arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <directory> <start_date> <end_date>"
    exit 1
fi

directory="$1"
start_date="$2"
end_date="$3"

# Validate the start and end dates
date -j -f "%Y-%m-%d" "$start_date" &>/dev/null
if [ $? -ne 0 ]; then
    echo "Invalid start date. Please provide a valid date in the format YYYY-MM-DD."
    exit 1
fi

date -j -f "%Y-%m-%d" "$end_date" &>/dev/null
if [ $? -ne 0 ]; then
    echo "Invalid end date. Please provide a valid date in the format YYYY-MM-DD."
    exit 1
fi

# Loop through the files in the directory
count=0
for file in "$directory"/*; do
    # Check if the file is within the date range
    file_date=$(date -j -r "$(stat -f "%m" "$file")" "+%Y-%m-%d")
    if [[ "$file_date" < "$start_date" || "$file_date" > "$end_date" ]]; then
        continue
    fi

    # Compress every three files
    if [ $((count % 5)) -eq 0 ]; then
        compressed_file="${directory}/batch_${start_date}_${end_date}_${count}.zip"
        zip -q -j "$compressed_file" "$file"
    else
        zip -q -j "$compressed_file" "$file"
    fi

    ((count++))
done

echo "Compression completed."
