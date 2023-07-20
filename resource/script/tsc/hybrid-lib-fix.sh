#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Error: At least one project name is required."
  exit 1
fi

for PROJECT_NAME in "$@"; do
  mkdir -p "./packages/$PROJECT_NAME/dist/cjs"
  cat >"./packages/$PROJECT_NAME/dist/cjs/package.json" <<!EOF
{
    "type": "commonjs"
}
!EOF

  mkdir -p "./packages/$PROJECT_NAME/dist/esm"
  cat >"./packages/$PROJECT_NAME/dist/esm/package.json" <<!EOF
{
    "type": "module"
}
!EOF
done
