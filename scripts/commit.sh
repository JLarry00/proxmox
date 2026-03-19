#!/usr/bin/env bash
set -euo pipefail

MSG="${1-}"

if [ -z "$MSG" ]; then
  MSG="commit"
fi

git add .
git commit -m "$MSG"

