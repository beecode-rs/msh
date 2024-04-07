#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Error: At least one project name is required."
  exit 1
fi

for PROJECT_NAME in "$@"; do
	echo "Register ts-cleaner for $PROJECT_NAME"
  npx ts-cleaner -w -s "./packages/$PROJECT_NAME/src" -d "./packages/$PROJECT_NAME/dist" &
done
