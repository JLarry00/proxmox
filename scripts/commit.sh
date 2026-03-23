#!/usr/bin/env bash
set -euo pipefail

FORCE="${FORCE:-0}"
MENSAJE="${1-}"

CHANGES=$(git status --porcelain)

if [ -n "$CHANGES" ]; then
  if [ "$FORCE" = "1" ]; then
    # Modo "force": mismo mensaje fijo que push-force.
    MENSAJE="makefile: add - commit - push"
  else
    # Modo normal: si no pasaron mensaje, pedirlo; si queda vacío, abortar.
    if [ -z "$MENSAJE" ]; then
      read -r -p "Ingrese un mensaje para el commit: " MENSAJE
    fi
    if [ -z "$MENSAJE" ]; then
      echo "⚠️  El mensaje de commit no puede estar vacío. Abortando..."
      exit 1
    fi
  fi

  git add .
  git commit -m "$MENSAJE"
  echo ""
  echo "==============================================="
  echo "🔄  Cambios detectados. Comiteados con mensaje: $MENSAJE."
  echo "==============================================="
  echo ""
else
  echo ""
  echo "------------------------------------------"
  echo "✅  No hay cambios para commitear."
  echo "------------------------------------------"
  echo ""
fi
