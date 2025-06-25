#!/bin/bash

# Define input and output files
INPUT_FILE="formatted_dependencies.txt"
OUTPUT_FILE="outdated-dependencies.csv"

# Add CSV header
echo "Dependency,Current Version,Latest Version" > "$OUTPUT_FILE"

# Read input file and process lines correctly
awk 'NR>1 && NF {print $1 "," $2 "," $3}' "$INPUT_FILE" >> "$OUTPUT_FILE"

echo "Conversion completed: Check $OUTPUT_FILE"
