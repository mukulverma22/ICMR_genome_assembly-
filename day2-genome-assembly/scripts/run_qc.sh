#!/usr/bin/env bash
# ============================================================
# run_qc.sh — Session 2A: Quality Control Pipeline
# Usage: bash scripts/run_qc.sh <R1.fastq.gz> <R2.fastq.gz>
# ============================================================

set -euo pipefail  # Exit on error, unset vars, pipe failures

# ── Colors for pretty output ──────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log()  { echo -e "${GREEN}[$(date +%H:%M:%S)] ✅ $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)] ⚠️  $1${NC}"; }
err()  { echo -e "${RED}[$(date +%H:%M:%S)] ❌ $1${NC}"; exit 1; }

# ── Input validation ──────────────────────────────────────
[ $# -ne 2 ] && err "Usage: bash run_qc.sh <R1.fastq.gz> <R2.fastq.gz>"
R1="$1"
R2="$2"
[ -f "$R1" ] || err "R1 file not found: $R1"
[ -f "$R2" ] || err "R2 file not found: $R2"

THREADS=4
OUTDIR="results"

echo "============================================"
echo "  🧬 Day 2 Session 2A: Quality Control"
echo "  R1: $R1"
echo "  R2: $R2"
echo "============================================"

# ── Step 1: FastQC on raw reads ───────────────────────────
log "Step 1/3: Running FastQC on raw reads..."
mkdir -p "$OUTDIR/fastqc_raw"
fastqc "$R1" "$R2" \
    --outdir "$OUTDIR/fastqc_raw" \
    --threads "$THREADS" \
    --quiet
log "FastQC complete → $OUTDIR/fastqc_raw/"

# ── Step 2: Fastp trimming & cleaning ─────────────────────
log "Step 2/3: Running Fastp for adapter trimming & QC..."
mkdir -p "$OUTDIR/fastp"
fastp \
    --in1 "$R1" \
    --in2 "$R2" \
    --out1 "$OUTDIR/fastp/clean_R1.fastq.gz" \
    --out2 "$OUTDIR/fastp/clean_R2.fastq.gz" \
    --html "$OUTDIR/fastp/fastp_report.html" \
    --json "$OUTDIR/fastp/fastp_report.json" \
    --qualified_quality_phred 20 \
    --unqualified_percent_limit 40 \
    --length_required 50 \
    --detect_adapter_for_pe \
    --correction \
    --thread "$THREADS"
log "Fastp complete → $OUTDIR/fastp/"

# ── Step 3: MultiQC aggregation ───────────────────────────
log "Step 3/3: Running MultiQC to aggregate reports..."
mkdir -p "$OUTDIR/multiqc"
multiqc \
    "$OUTDIR/fastqc_raw/" \
    "$OUTDIR/fastp/" \
    --outdir "$OUTDIR/multiqc" \
    --filename multiqc_report.html \
    --title "Day 2 QC Report" \
    --quiet
log "MultiQC complete → $OUTDIR/multiqc/multiqc_report.html"

echo ""
echo "============================================"
echo "  ✅ QC Pipeline Complete!"
echo "  Clean reads: $OUTDIR/fastp/clean_R1.fastq.gz"
echo "  Clean reads: $OUTDIR/fastp/clean_R2.fastq.gz"
echo "  Open in browser: $OUTDIR/multiqc/multiqc_report.html"
echo "============================================"
