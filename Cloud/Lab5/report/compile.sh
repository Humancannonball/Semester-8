#!/bin/bash
set -e

cd "$(dirname "$0")"

if command -v npx >/dev/null 2>&1; then
  npx -y md-to-pdf report.md \
    --pdf-options '{"margin": {"top": "20mm", "bottom": "20mm", "left": "25mm", "right": "25mm"}, "printBackground": true}'
  exit 0
fi

if command -v pandoc >/dev/null 2>&1; then
  if command -v tectonic >/dev/null 2>&1; then
    PDF_ENGINE="tectonic"
  else
    PDF_ENGINE="xelatex"
  fi

  pandoc report.md -o report.pdf --pdf-engine="$PDF_ENGINE" --number-sections -V geometry:margin=2.5cm
fi
