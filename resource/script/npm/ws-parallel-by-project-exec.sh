#!/bin/sh

. "$(dirname "$0")/../PROJECT_LIST.sh"

# Function to display the usage of the script
display_usage() {
  echo "Usage: $0 [-c <command>] [-n <name>] [-i|--if-present] project_name1 [project_name2 ...]"
  echo "Options:"
  echo "  -c, --command <command>   Specify the command to execute."
  echo "  -n, --name <name>         Specify the label name (defaults to command)."
  echo "  -i, --if-present          Add --if-present flag to npm run command."
}

# Initialize IF_PRESENT flag
IF_PRESENT=""

# Parse command-line options using getopts
while getopts ":c:n:ih" opt; do
  case ${opt} in
    c)
      COMMAND="$OPTARG"
      ;;
    n)
      NAME="$OPTARG"
      ;;
    i)
      IF_PRESENT="--if-present"
      ;;
    \?)
      echo "Error: Invalid option -$OPTARG" >&2
      display_usage
      exit 1
      ;;
  esac
done

# Check if command is provided
if [ -z "$COMMAND" ]; then
    display_usage
    exit 1
fi

if [ -z "$NAME" ]; then
    NAME="$COMMAND"
fi

# Shift the option arguments so that "$@" only contains project names
shift $(($OPTIND - 1))

# Use default projects if no projects are provided
if [ $# -eq 0 ]; then
  echo "No projects specified. Using default projects: $PROJECT_LIST"
  set -- $PROJECT_LIST
fi

# Initialize variables
LABELS=""
EXEC_PATHS=""

# Construct labels and exec paths
for PROJECT_NAME in "$@"; do
  LABELS="${LABELS:+$LABELS,}$NAME:$PROJECT_NAME"
  EXEC_PATHS="$EXEC_PATHS${EXEC_PATHS:+ }'npm run $IF_PRESENT --workspace=packages/${PROJECT_NAME} $COMMAND'"
done

# Execute concurrently with npx concurrently
sh -c "npx concurrently -c auto -n $LABELS $EXEC_PATHS"
