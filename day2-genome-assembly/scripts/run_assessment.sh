#!/usr/bin/env bash
# ============================================================
# run_assessment.sh — Session 2B-ii: Assembly Quality Assessment
# Usage: bash scripts/run_assessment.sh <assembly.fasta> [reference.fasta]
# ============================================================

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[$(date +%H:%M:%S)] ✅ $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)] ⚠️  $1${NC}"; }
err()  { echo -e "${RED}[$(date +%H:%M:%S)] ❌ $1${NC}"; exit 1; }

[ $# -lt 1 ] && err "Usage: bash run_assessment.sh <assembly.fasta> [reference.fasta] [lineage]"

ASSEMBLY="$1"
REFERENCE="${2:-}"
LINEAGE="${3:-bacteria_odb10}"
THREADS=4; OUTDIR="results"

[ -f "$ASSEMBLY" ] || err "Assembly file not found: $ASSEMBLY"

echo "============================================"
echo "  🧬 Day 2 Session 2B-ii: Quality Assessment"
echo "  Assembly:  $ASSEMBLY"
echo "  Reference: ${REFERENCE:-none}"
echo "  BUSCO lineage: $LINEAGE"
echo "============================================"

# ── Step 1: QUAST ─────────────────────────────────────────
log "Step 1/3: Running QUAST contiguity assessment..."
mkdir -p "$OUTDIR/quast"

if [ -n "$REFERENCE" ] && [ -f "$REFERENCE" ]; then
    quast.py "$ASSEMBLY" \
        --reference "$REFERENCE" \
        --output-dir "$OUTDIR/quast" \
        --threads "$THREADS" \
        --min-contig 500
else
    warn "No reference provided — running QUAST without reference"
    quast.py "$ASSEMBLY" \
        --output-dir "$OUTDIR/quast" \
        --threads "$THREADS" \
        --min-contig 500
fi
log "QUAST complete → $OUTDIR/quast/report.html"

# Print key metrics
if [ -f "$OUTDIR/quast/report.txt" ]; then
    echo "--- QUAST Summary ---"
    grep -E "N50|# contigs|Total length|Genome fraction" \
         "$OUTDIR/quast/report.txt" || true
    echo "---------------------"
fi

# ── Step 2: BUSCO ─────────────────────────────────────────
log "Step 2/3: Running BUSCO completeness check..."
mkdir -p "$OUTDIR/busco"

busco \
    --in "$ASSEMBLY" \
    --out busco_run \
    --out_path "$OUTDIR/busco" \
    --mode genome \
    --lineage_dataset "$LINEAGE" \
    --cpu "$THREADS" \
    --download_path "./busco_downloads" \
    --force

log "BUSCO complete → $OUTDIR/busco/busco_run/"

# Print BUSCO summary
SUMMARY=$(find "$OUTDIR/busco" -name "short_summary*.txt" | head -1)
if [ -f "$SUMMARY" ]; then
    echo "--- BUSCO Summary ---"
    grep -A 8 "Results:" "$SUMMARY" || cat "$SUMMARY"
    echo "---------------------"
fi

# ── Step 3: RagTag scaffolding ────────────────────────────
if [ -n "$REFERENCE" ] && [ -f "$REFERENCE" ]; then
    log "Step 3/3: Running RagTag scaffolding..."
    mkdir -p "$OUTDIR/ragtag"
    ragtag.py scaffold \
        "$REFERENCE" \
        "$ASSEMBLY" \
        -o "$OUTDIR/ragtag" \
        -t "$THREADS" \
        -u
    log "RagTag complete → $OUTDIR/ragtag/ragtag.scaffold.fasta"

    # Re-run QUAST on scaffolded assembly
    log "Bonus: Running QUAST on scaffolded assembly for comparison..."
    quast.py \
        "$OUTDIR/ragtag/ragtag.scaffold.fasta" \
        "$ASSEMBLY" \
        --reference "$REFERENCE" \
        --output-dir "$OUTDIR/quast_comparison" \
        --threads "$THREADS" \
        --labels "Scaffolded,Original"
    log "Comparison QUAST complete → $OUTDIR/quast_comparison/report.html"
else
    warn "Step 3/3: Skipping RagTag (no reference provided)"
fi

echo ""
echo "============================================"
echo "  ✅ Assessment Pipeline Complete!"
echo "  📊 QUAST report:  $OUTDIR/quast/report.html"
echo "  📊 BUSCO summary: $(find $OUTDIR/busco -name 'short_summary*.txt' | head -1)"
[ -n "$REFERENCE" ] && echo "  📊 Scaffolded:    $OUTDIR/ragtag/ragtag.scaffold.fasta"
echo "  Open the HTML files in your browser!"
echo "============================================"
