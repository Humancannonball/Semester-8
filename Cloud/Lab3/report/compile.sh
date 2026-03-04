#!/bin/bash
# OpenTofu Lab Report Compiler
# Uses md-to-pdf (Chromium-based) as primary engine
# Falls back to Pandoc + Tectonic if available

set -e

echo "========================================"
echo "  Lab Report Compiler"
echo "========================================"
echo ""

cd "$(dirname "$0")"

# ── Method 1: md-to-pdf (recommended, Chromium-based) ──
if command -v npx &> /dev/null; then
    echo "→ Compiling with md-to-pdf ..."
    echo ""

    npx -y md-to-pdf report.md \
        --pdf-options '{"margin": {"top": "20mm", "bottom": "20mm", "left": "25mm", "right": "25mm"}, "printBackground": true}'

    if [ -f "report.pdf" ]; then
        echo ""
        echo "========================================"
        echo "  ✓ SUCCESS! report.pdf is ready"
        echo "========================================"
        FILE_SIZE=$(du -h report.pdf | cut -f1)
        echo ""
        echo "  Size: $FILE_SIZE"
        echo ""
        xdg-open report.pdf 2>/dev/null || echo "  Open report.pdf manually"
        exit 0
    fi
fi

# ── Method 2: Pandoc + Tectonic (fallback) ──
echo "→ Trying Pandoc + Tectonic ..."

if ! command -v pandoc &> /dev/null; then
    echo "✗ Pandoc not found! Install: sudo pacman -S pandoc"
    exit 1
fi

if command -v tectonic &> /dev/null; then
    PDF_ENGINE="tectonic"
elif command -v xelatex &> /dev/null; then
    PDF_ENGINE="xelatex"
else
    echo "✗ No PDF engine found! Install: sudo pacman -S tectonic"
    exit 1
fi

pandoc report.md \
    -o report.pdf \
    --pdf-engine=$PDF_ENGINE \
    --number-sections \
    --highlight-style=tango \
    -V geometry:margin=2.5cm \
    -V mainfont="Noto Sans" \
    -V monofont="Liberation Mono" \
    -V fontsize=11pt \
    -V colorlinks=true \
    --resource-path=.

if [ -f "report.pdf" ]; then
    echo ""
    echo "========================================"
    echo "  ✓ SUCCESS! report.pdf is ready"
    echo "========================================"
    FILE_SIZE=$(du -h report.pdf | cut -f1)
    echo ""
    echo "  Size: $FILE_SIZE"
    echo ""
    xdg-open report.pdf 2>/dev/null || echo "  Open report.pdf manually"
else
    echo "✗ Compilation failed!"
    exit 1
fi
