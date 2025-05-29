#!/bin/bash

# You know that moment when you've built your content type, exported configs,
# committed everything, tested and just before the deploy, you realize
# you forgot a prefix on almost all your fields? This script is here to help.
# It will skip hidden files and folders, so you don’t accidentally mess up your
# .git index.

# Check for at least 3 arguments.
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 [--dry-run] <input_folder> <old_string> <new_string>"
  exit 1
fi

# Dry-run flag detection.
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
  shift
fi

INPUT_FOLDER="$1"
OLD_STRING="$2"
NEW_STRING="$3"

# Check if input folder exists.
if [ ! -d "$INPUT_FOLDER" ]; then
  echo "Error: $INPUT_FOLDER is not a directory."
  exit 1
fi

# Find and process files recursively, skipping hidden files and folders.
find "$INPUT_FOLDER" -type d -name '.*' -prune -o -type f -print | while read -r FILE; do
  BASENAME=$(basename "$FILE")
  DIRNAME=$(dirname "$FILE")
  NEW_FILENAME="$BASENAME"

  # 1. Rename file if it contains old string
  if [[ "$BASENAME" == *"$OLD_STRING"* ]]; then
    NEW_FILENAME="${BASENAME//$OLD_STRING/$NEW_STRING}"
    if [ "$DRY_RUN" == true ]; then
      echo "[Dry-run] Would rename: $FILE -> $DIRNAME/$NEW_FILENAME"
    else
      mv "$FILE" "$DIRNAME/$NEW_FILENAME"
      echo "Renamed: $FILE -> $DIRNAME/$NEW_FILENAME"
      FILE="$DIRNAME/$NEW_FILENAME"  # Update file path after rename
    fi
  fi

  # 2. Replace content inside file
  if grep -q "$OLD_STRING" "$FILE"; then
    if [ "$DRY_RUN" == true ]; then
      echo "[Dry-run] Would replace content in: $FILE"
    else
      sed -i "s/$OLD_STRING/$NEW_STRING/g" "$FILE"
      echo "Updated content in: $FILE"
    fi
  fi
done

echo "Done."
