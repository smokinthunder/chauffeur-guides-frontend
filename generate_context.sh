#!/bin/bash

# Output file name
OUTPUT_FILE="project_context.txt"

# Clear the output file
> "$OUTPUT_FILE"

echo "Generating project context..."

# ================================================================
# 1. GENERATE DIRECTORY TREE
# ================================================================

echo "PROJECT STRUCTURE:" >> "$OUTPUT_FILE"
echo "================================================================" >> "$OUTPUT_FILE"

# Check if 'tree' command exists
if command -v tree &> /dev/null; then
    # -I ignores patterns (node_modules, hidden files, assets)
    # --dirsfirst sorts directories before files
    tree -I "node_modules|.*" --dirsfirst >> "$OUTPUT_FILE"
else
    # Fallback using find + sed to simulate a tree structure
    find . -maxdepth 4 -not -path '*/.*' -not -path '*/node_modules*' | sed -e 's;[^/]*/;|____;g;s;____|; |;g' >> "$OUTPUT_FILE"
fi

echo -e "\n\n" >> "$OUTPUT_FILE"


# ================================================================
# 2. GENERATE CODE CONTENT
# ================================================================

# Find relevant files
# Adjusted to ensure we catch files properly while respecting exclusions
find . -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" \) \
    -not -path "*/.*" \
    -not -path "*/node_modules/*" \
    -not -path "*/assets/*" | sort | while read -r file; do

    # Print a distinct separator and the filename
    echo "================================================================" >> "$OUTPUT_FILE"
    echo "FILE: $file" >> "$OUTPUT_FILE"
    echo "================================================================" >> "$OUTPUT_FILE"
    
    # Print the file content
    cat "$file" >> "$OUTPUT_FILE"
    
    # Add a couple of newlines for readability
    echo -e "\n\n" >> "$OUTPUT_FILE"

done


# ================================================================
# 3. CALCULATE STATS & COPY TO CLIPBOARD
# ================================================================

# Calculate Stats from the generated file
# Count occurrences of "FILE: " to get the number of files processed
TOTAL_FILES=$(grep -c "FILE: " "$OUTPUT_FILE")

# Calculate Size and Estimate Tokens
TOTAL_SIZE_BYTES=$(wc -c < "$OUTPUT_FILE" | xargs)
EST_TOKENS=$((TOTAL_SIZE_BYTES / 4))

# Copy to Clipboard using xclip
# if command -v xclip &> /dev/null; then
#     cat "$OUTPUT_FILE" | wl-copy
#     CLIPBOARD_STATUS="Copied to clipboard!"
# else
    CLIPBOARD_STATUS="xclip not found. Content not copied automatically."
# fi
#
# ================================================================
# 4. CONSOLE OUTPUT
# ================================================================

echo "------------------------------------------------"
echo "Build Complete."
echo "------------------------------------------------"
echo "Files Processed : $TOTAL_FILES"
echo "Context Length  : $TOTAL_SIZE_BYTES bytes (~$EST_TOKENS tokens)"
echo "Output File     : $OUTPUT_FILE"
echo "Status          : $CLIPBOARD_STATUS"
echo "------------------------------------------------"
