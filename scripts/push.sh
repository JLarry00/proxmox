#!/usr/bin/env bash
set -euo pipefail

FORCE="${FORCE:-0}"
MENSAJE=""

chmod +x ./scripts/commit.sh
./scripts/commit.sh

echo ""
echo "======================================"
echo "⬆️  Pusheando cambios al repositorio..."
echo "======================================"
echo ""
git push
echo ""
echo "======================================"
echo "✅  Cambios pusheados al repositorio."
echo "======================================"
echo ""

