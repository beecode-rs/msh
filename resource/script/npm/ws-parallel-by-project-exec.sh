#!/bin/bash

# Default projects array
DEFAULT_PROJECTS=("error" "util" "logger" "node-session" "test-contractor" "env" "app-boot" "entity" "base-frame" "orm" "cli")

# Function to display the usage of the script
function display_usage {
  echo "Usage: $0 -c <command_name> project_name1 [project_name2 ...]"
  echo "Options:"
  echo "  -c, --command <command_name>   Specify the command to execute."
}

# Parse command-line options using getopts
while getopts ":c:h:" opt; do
  case ${opt} in
    c)
      COMMAND_NAME="$OPTARG"
      ;;
		\?)
			echo "Error: Invalid option -$OPTARG" >&2
			display_usage
			exit 1
			;;
  esac
done

# Check if command is provided
if [[ -z "$COMMAND_NAME" ]]; then
    display_usage
    exit 1
fi

# Shift the option arguments so that "$@" only contains project names
shift $((OPTIND - 1))

# Use default projects if no projects are provided
if [ $# -eq 0 ]; then
  echo "No projects specified. Using default projects: ${DEFAULT_PROJECTS[*]}"
  set -- "${DEFAULT_PROJECTS[@]}"
fi

# Initialize variables
LABELS=""
EXEC_PATHS=""

# Construct labels and exec paths
for PROJECT_NAME in "$@"; do
  LABELS="${LABELS:+$LABELS,}$COMMAND_NAME:$PROJECT_NAME"
  EXEC_PATHS="$EXEC_PATHS${EXEC_PATHS:+ }'npm run $COMMAND_NAME --workspace=packages/${PROJECT_NAME}'"
done

# Execute concurrently with npx concurrently
sh -c "npx concurrently -c auto -n $LABELS $EXEC_PATHS"
