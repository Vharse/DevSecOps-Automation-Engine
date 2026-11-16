#!/bin/bash

set -e

# Check if running in GitHub Actions
if [ "$GITHUB_ACTIONS" = "true" ]; then
  echo "Running in a GitHub Actions workflow; not running 'npm ci'"
  exit 0
fi

# Check if npm ci is likely needed before proceeding
if [ ! -d node_modules ]; then
  echo "Running 'npm ci' because 'node_modules' directory is missing."
  npm ci
elif [ package.json -nt package-lock.json ]; then
  echo "Running 'npm ci' because 'package-lock.json' appears to be outdated."
  npm ci
elif [ package-lock.json -nt node_modules/.package-lock.json ]; then
  echo "Running 'npm ci' because 'node_modules/.package-lock.json' appears to be outdated."
  npm ci
else
  echo "Skipping 'npm ci' because everything appears to be up-to-date."
fi
