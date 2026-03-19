#!/usr/bin/env bash
set -euo pipefail

FORCE="${FORCE:-0}"

MENSAJE=""

if [ "$FORCE" = "1" ]; then
  MENSAJE="makefile: add - commit - push"
else
  if ! git diff-index --quiet HEAD --; then
    read -r -p "Ingrese un mensaje para el commit: " MENSAJE
    if [ -z "$MENSAJE" ]; then
      echo "⚠️  El mensaje de commit no puede estar vacío. Abortando..."
      exit 1
    fi
  fi
fi

if ! git diff-index --quiet HEAD --; then
  git add .
  git commit -m "$MENSAJE"
  echo ""
  echo "=================================================="
  echo "🔄  Cambios detectados. Comiteados con mensaje: $MENSAJE."
  echo "=================================================="
  echo ""
else
  echo ""
  echo "------------------------------------------"
  echo "✅  No hay cambios para commitear."
  echo "------------------------------------------"
fi

echo ""
echo "=========================================="
echo "⬆️  Pusheando cambios al repositorio..."
echo "=========================================="
echo ""
git push
echo ""
echo "=========================================="
echo "✅  Cambios pusheados al repositorio."
echo "=========================================="
echo ""

