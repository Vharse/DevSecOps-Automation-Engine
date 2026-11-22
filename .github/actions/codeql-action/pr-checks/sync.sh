#!/bin/bash
set -e

cd "$(dirname "$0")"

# Run `npm ci` to keep installs reproducible from the lockfile.
#
# `pr-checks` is an npm workspace of the repository root and the two share a single hoisted
# `node_modules` directory. Running npm from this directory puts it in workspace mode, where it
# ignores the root project's own dependencies by default. `npm ci` would then rebuild the shared
# `node_modules` with only this workspace's dependencies, removing the root's ones, which breaks
# anything that imports from `src` (such as `sync.ts` itself). `--include-workspace-root` keeps the
# root project's dependencies in the installed tree.
if [ "$GITHUB_ACTIONS" = "true" ]; then
  echo "In Actions, running 'npm ci' for 'sync.ts'..."
  npm ci --include-workspace-root
else
  echo "Running 'npm ci' for 'sync.ts'..."
  npm ci --no-audit --no-fund --include-workspace-root
fi

if [[ -x "./node_modules/.bin/tsx" ]]; then
  ./node_modules/.bin/tsx sync.ts
elif [ -x "../../../node_modules/.bin/tsx" ]; then
  ../../../node_modules/.bin/tsx sync.ts
else
  npx --no-install tsx sync.ts
fi
