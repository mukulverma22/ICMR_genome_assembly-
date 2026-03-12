#!/usr/bin/env bash
# ============================================================
# run_assembly.sh — Session 2B-i: Genome Assembly
# Usage: bash scripts/run_assembly.sh <clean_R1.fastq.gz> <clean_R2.fastq.gz>
# ============================================================

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[$(date +%H:%M:%S)] ✅ $1${NC}"; }
err()  { echo -e "${RED}[$(date +%H:%M:%S)] ❌ $1${NC}"; exit 1; }

[ $# -lt 2 ] && err "Usage: bash run_assembly.sh <clean_R1.fastq.gz> <clean_R2.fastq.gz> [reference.fasta]"

R1="$1"; R2="$2"
REFERENCE="${3:-}"  # Optional reference genome
THREADS=4; MEMORY=8; OUTDIR="results"

[ -f "$R1" ] || err "R1 not found: $R1"
[ -f "$R2" ] || err "R2 not found: $R2"

echo "============================================"
echo "  🧬 Day 2 Session 2B-i: Genome Assembly"
echo "  R1: $R1  |  R2: $R2"
echo "  Reference: ${REFERENCE:-none (de novo)}"
echo "============================================"

# ── Step 1: SPAdes Assembly ───────────────────────────────
log "Step 1/2: Running SPAdes genome assembler..."
mkdir -p "$OUTDIR/spades_assembly"
spades.py \
    -1 "$R1" \
    -2 "$R2" \
    -o "$OUTDIR/spades_assembly" \
    --threads "$THREADS" \
    --memory "$MEMORY" \
    --careful \
    --cov-cutoff auto

[ -f "$OUTDIR/spades_assembly/scaffolds.fasta" ] || \
    err "SPAdes failed — check $OUTDIR/spades_assembly/spades.log"
log "SPAdes complete → $OUTDIR/spades_assembly/scaffolds.fasta"

# Print quick stats
CONTIG_COUNT=$(grep -c ">" "$OUTDIR/spades_assembly/scaffolds.fasta" || true)
log "Number of scaffolds: $CONTIG_COUNT"

# ── Step 2: Setu (if reference provided) ─────────────────
if [ -n "$REFERENCE" ] && [ -f "$REFERENCE" ]; then
    log "Step 2/2: Running Setu viral assembly pipeline..."
    mkdir -p "$OUTDIR/setu_assembly"
    setu \
        --read1 "$R1" \
        --read2 "$R2" \
        --reference "$REFERENCE" \
        --outdir "$OUTDIR/setu_assembly" \
        --threads "$THREADS"
    log "Setu complete → $OUTDIR/setu_assembly/"
else
    log "Step 2/2: Skipping Setu (no reference provided)"
fi

echo ""
echo "============================================"
echo "  ✅ Assembly Pipeline Complete!"
echo "  SPAdes assembly: $OUTDIR/spades_assembly/scaffolds.fasta"
echo "  Use this file in Session 2B-ii for QA"
echo "============================================"
