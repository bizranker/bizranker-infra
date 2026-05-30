#!/usr/bin/env bash
set -euo pipefail

ENTRY_FILE="${1:-}"

if [ -z "$ENTRY_FILE" ] || [ ! -f "$ENTRY_FILE" ]; then
  echo "Usage: $0 portfolio-inbox/some-entry.md"
  exit 1
fi

TARGET="docs/portfolio/bizranker-engineering-journal.md"
STAMP="$(date '+%Y-%m-%d %H:%M:%S %Z')"

{
  echo ""
  echo "---"
  echo ""
  echo "# Portfolio Entry - $STAMP"
  echo ""
  cat "$ENTRY_FILE"
  echo ""
} >> "$TARGET"

git add "$TARGET" "$ENTRY_FILE"
git commit -m "Append BizRanker portfolio entry"
git push origin main
