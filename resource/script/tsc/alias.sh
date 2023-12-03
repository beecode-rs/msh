#!/bin/bash

# Initialize variables
WATCH_MODE=0 # 0 means disabled, 1 means enabled
PACKAGE_TYPE=esm
# Function to display the usage of the script
function display_usage {
  echo "Usage: $0 [-w] [-c] project_name1 [project_name2 ...]"
  echo "Options:"
  echo "  -w   Enable watch mode (recompile on file changes)."
  echo "  -c   Enable CommonJS alias paths."
}

# Parse command-line options using getopts
while getopts ":w:c" opt; do
  case $opt in
    w)
      WATCH_MODE=1
      ;;
    c)
      PACKAGE_TYPE=cjs
      ;;
    \?)
      echo "Error: Invalid option -$OPTARG" >&2
      display_usage
      exit 1
      ;;
  esac
done

# Shift the option arguments so that "$@" only contains project names
shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
  echo "Error: At least one project name is required."
  exit 1
fi

for PROJECT_NAME in "$@"; do
	echo "Register tsc-alias for $PROJECT_NAME (options: watch=$WATCH_MODE, package_type=$PACKAGE_TYPE)"
  npx tsc-alias -p "./packages/$PROJECT_NAME/tsconfig.$PACKAGE_TYPE.alias-paths.json" "$([ $WATCH_MODE -eq 1 ] && echo '-w')" &
done
