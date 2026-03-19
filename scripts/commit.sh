#!/usr/bin/env bash
set -euo pipefail

FORCE="${FORCE:-0}"
MSG="${1-}"

if [ "$FORCE" = "1" ]; then
  # Mismo comportamiento que el "push force": usar mensaje fijo y no pedir input.
  if ! git diff-index --quiet HEAD --; then
    git add .
    git commit -m "makefile: add - commit - push"
    echo ""
    echo "=================================================="
    echo "🔄  Cambios detectados. Comiteados con mensaje: makefile: add - commit - push."
    echo "=================================================="
    echo ""
  else
    echo ""
    echo "------------------------------------------"
    echo "✅  No hay cambios para commitear."
    echo "------------------------------------------"
    echo ""
  fi
  exit 0
fi

if [ -z "$MSG" ]; then
  MSG="commit"
fi

git add .
git commit -m "$MSG"
