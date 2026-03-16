# 🖥️ Session 2B-ii: Assembly Quality Assessment

**🎯 Goal:** Evaluate your assembled genome for quality, completeness, and contamination  
**🛠️ Tools:** QUAST · BUSCO · RagTag

---

## 🧠 Concept: Why Assess Assembly Quality?

Assembling reads into contigs doesn't mean you're done. Your assembly could have:

- ❌ **Fragmentation** — the genome is broken into thousands of tiny pieces
- ❌ **Misassemblies** — contigs that join regions that shouldn't be joined
- ❌ **Incompleteness** — large parts of the genome are missing
- ❌ **Contamination** — sequences from other organisms (bacteria, human, etc.)

**Quality Assessment (QA)** checks all of these problems before you trust your assembly for downstream analyses like gene prediction or variant calling.

### The Pillars of Assembly QA

```
Assembly Quality

        Contiguity ──── QUAST  (how fragmented is it?)
        Completeness ── BUSCO  (are expected genes present?)
```
```
## Activate conda environment
conda activate work
 
```

---

## 📁 Required Input Files

| File | Format | Description | From | Download command |
|------|--------|-------------|------|------------------|
| `contigs.fasta` | FASTA | Assembled genome | Download or Provided |```wget https://raw.githubusercontent.com/mukulverma22/ICMR_genome_assembly-/refs/heads/main/day2-genome-assembly/contigs.fasta``` |
| `MTB.fna` | FASTA | Reference genome (optional but recommended) | Download or provided | ```wget https://raw.githubusercontent.com/mukulverma22/ICMR_genome_assembly-/refs/heads/main/day2-genome-assembly/MTB.fna``` |
| BUSCO lineage | Auto-downloaded | Gene database for completeness check | BUSCO downloads automatically |



---

## 🔧 Tool 1: QUAST

### What is QUAST?
**QUAST** (Quality Assessment Tool for Genome Assemblies) measures the **contiguity** of your assembly. It answers:
- How fragmented is the assembly? (fewer contigs = better)
- How long are the contigs? (longer = better)
- If given a reference: Where are the misassemblies?

### Verify installation of QUAST
```bash
# Verify
quast.py --version
```

### Understanding Key QUAST Metrics

#### N50 — The Most Important Metric

Imagine laying all your contigs end-to-end from longest to shortest. **N50 is the length of the contig where you've covered 50% of the total assembly.**

```
Contig lengths: [50000, 30000, 20000, 15000, 10000, 5000, 3000...]
Total assembly = 200,000 bp
50% of total  = 100,000 bp

Cumulative:
50000 bp ──── (25%)
50000 + 30000 = 80000 bp ──── (40%)
80000 + 20000 = 100000 bp ──── (50%) ← N50 = 20,000 bp ✅
```

| N50 Interpretation | Meaning |
|-------------------|---------|
| N50 = genome size | Perfect single contig assembly |

### Run QUAST

```bash
mkdir -p quast

quast.py \
    contigs.fasta \
    --output-dir quast \
    --threads 2
```

```
# Flag explanations:
# assembly.fasta      : Your assembled genome (from SPAdes)
# --output-dir        : Where to save results
# --threads           : CPU threads
```

### QUAST Output Files

```
quast/
├── report.html         ← ✅ Open this in your browser!
├── report.txt          ← Plain text summary
├── report.tsv          ← Tab-separated (import to Excel)
└── icarus.html         ← Interactive contig browser
```

### Reading the QUAST Report

Key metrics to check in `report.txt`:

```
# contigs (>= 0 bp)          ← Total contigs (lower = better)
# contigs (>= 1000 bp)       ← Contigs >1kb (more meaningful)
Total length                  ← Should match expected genome size
Largest contig                ← Longest single contig
N50                           ← Most important! (higher = better)
```
---


## 🔧 Tool 2: BUSCO

### What is BUSCO?
**BUSCO** (Benchmarking Universal Single-Copy Orthologs) assesses **genome completeness** by checking for the presence of genes that are expected to be present in **every species of a given lineage**.

The logic: If your genome assembly is complete, it should contain nearly all the genes that evolution has conserved across that group of organisms.

> 🔑 **Key Insight:** BUSCO doesn't just count how much sequence is assembled — it checks if biologically important genes are present and intact.

### BUSCO Categories

For each universal single-copy gene, BUSCO classifies it as:

| Category | Symbol | Meaning |
|----------|--------|---------|
| **Complete Single-Copy** | `C:S` | Present once ✅ |
| **Complete Duplicated** | `C:D` | Present, but duplicated (possible contamination or polyploidy) ⚠️ |
| **Fragmented** | `F` | Partially present (assembly gaps?) ⚠️ |
| **Missing** | `M` | Not found (incomplete assembly) ❌ |

**A good BUSCO result looks like:**
```
C:98.2% [S:97.8%, D:0.4%], F:0.5%, M:1.3%
```

**A poor BUSCO result looks like:**
```
C:45.3% [S:44.9%, D:0.4%], F:8.2%, M:46.5%
← Only 45% of expected genes found! Very incomplete assembly.
```

### Verify the installation of BUSCO
```bash
# Verify
busco --version
```

### Choose the Right BUSCO Lineage Database

BUSCO has different gene databases for different organism groups:

```bash
# List available lineages
busco --list-datasets

```
```
# Common lineages:
# bacteria_odb10    ← Bacterial genomes
# fungi_odb10       ← Fungal genomes
# metazoa_odb10     ← Animals (broad)
# viridiplantae_odb10 ← Plants
# eukaryota_odb10   ← All eukaryotes (broadest)
# NOTE: Viruses don't have a standard BUSCO lineage
#       BUSCO is mainly used for larger genomes
```

> ⚠️ **Note for today's viral assembly:** BUSCO is less applicable for viral genomes (too small, too variable). We're running it for training purposes. For viral completeness, QUAST's genome fraction metric is more meaningful.

### Run BUSCO

```bash
busco \
    --in contigs.fasta \
    --out busco_results \
    --mode genome \
    --lineage_dataset bacteria_odb10 \
    --cpu 2 \
    --download_path ./busco_downloads
```

```

# Flag explanations:
# --in              : Input assembly (FASTA)
# --out             : Output folder name (created inside --out_path)
# --out_path        : Parent directory for output
# --mode            : genome (assembly), transcriptome, or proteins
# --lineage_dataset : Which BUSCO database to use
# --cpu             : Number of CPU threads
# --download_path   : Where to cache downloaded databases
```

### BUSCO Output

```
busco_results/
├── short_summary.specific.bacteria_odb10.busco_results.txt  ← ✅ Key results
├── run_bacteria_odb10/
│   ├── full_table.tsv       ← Status of each individual BUSCO gene
│   └── missing_busco_list.tsv ← List of missing genes
└── logs/
    └── busco.log
```

### Visualize BUSCO Results
```
## Download the required script:
cd busco_results/
wget https://raw.githubusercontent.com/mukulverma22/ICMR_genome_assembly-/refs/heads/main/day2-genome-assembly/Busco_plot.py

```

```bash

# Generate a summary plot (requires matplotlib)
 python Busco_plot.py short_summary.specific.bacteria_odb10.busco_results.txt

```

---

## 🔧 Tool 3: RagTag

### What is RagTag?
**RagTag** performs **contig scaffolding** — it uses a reference genome to order, orient, and join your contigs into longer scaffolds (chromosome-level assemblies).

Think of it like: You've assembled puzzle pieces (contigs), but they're all randomly scattered. RagTag uses a "solved puzzle picture" (reference genome) to figure out where each piece goes.

```
Before RagTag (unordered contigs):
[Contig_5]  [Contig_1]  [Contig_8]  [Contig_3]  [Contig_2]

After RagTag (ordered scaffolds based on reference):
[Contig_1]----[Contig_3]--------[Contig_5]
                     ↑ gaps filled with Ns
```

### RagTag Modules

| Module | What it does |
|--------|--------------|
| `scaffold` | Orders/orients contigs using a reference |
| `patch` | Fills gaps in an assembly using another assembly |
| `merge` | Merges two assemblies |
| `correct` | Corrects misassemblies using a reference |

### Install RagTag
```bash
cd ..
# Verify
ragtag.py --version
```

### Run RagTag Scaffold

```bash
mkdir -p ragtag

ragtag.py scaffold \
    MTB.fna \
    contigs.fasta \
    -o ragtag \
    -t 2 \
```
    
```
# Flag explanations:
# scaffold          : Module to use
# reference.fasta   : Reference genome to scaffold against
# assembly.fasta    : Your query assembly (from SPAdes)
# -o                : Output directory
# -t                : CPU threads
# -u                : Add unplaced contigs to output (don't discard them)
```

### RagTag Output Files

```
results/ragtag/
├── ragtag.scaffold.fasta       ← ✅ Scaffolded assembly
├── ragtag.scaffold.stats       ← Scaffolding statistics
├── ragtag.scaffold.agp         ← Assembly coordinates (AGP format)
└── ragtag.scaffold.confidence.txt ← Confidence scores per scaffold
```

### Reading RagTag Stats

```bash
cat ragtag/ragtag.scaffold.stats
```

```
# Example output:
placed_sequences = 245         ← Contigs successfully placed
unplaced_sequences = 12        ← Contigs couldn't be placed (might be contamination or novel)
gap_between_placed_seqs = 89   ← Number of gaps (Ns) inserted
```

### Re-run QUAST on Scaffolded Assembly

After RagTag, compare the scaffolded assembly to your original:

```bash
quast.py \
    ragtag/ragtag.scaffold.fasta \
    contigs.fasta \
    --output-dir quast_comparison \
    --threads 2
```
```
# This runs QUAST on BOTH assemblies simultaneously for comparison!
```

---

## 📊 Complete Assessment Workflow Summary

```bash
# Quick one-liner to run everything in sequence
# (run from sessions/session-2B-ii/ directory)

# 1. QUAST
quast.py assembly.fasta -o results/quast -t 2

# 2. BUSCO
busco --in assembly.fasta --out busco_results \
      --mode genome --lineage_dataset bacteria_odb10 --cpu 2

# 3. RagTag scaffolding
ragtag.py scaffold reference.fasta assembly.fasta -o results/ragtag -t 2 -u

```

---

## 📊 Interpreting Your Final Results

### Assembly Quality Scorecard

| Metric | Tool | Poor | Acceptable | Good | Excellent |
|--------|------|------|-----------|------|-----------|
| N50 | QUAST | <10 kb | 10-100 kb | 100 kb-1 Mb | >1 Mb |
| Genome fraction | QUAST | <80% | 80-90% | 90-98% | >98% |
| Misassemblies | QUAST | >100 | 10-100 | 1-10 | 0 |
| BUSCO complete | BUSCO | <50% | 50-80% | 80-95% | >95% |
| Contigs placed | RagTag | <50% | 50-80% | 80-95% | >95% |

---

## 📊 Expected Final Output Structure

```
results/
├── quast/
│   ├── report.html             ← ✅ Assembly contiguity report
│   └── report.txt
├── busco_results/
│       └── short_summary*.txt  ← ✅ Completeness summary
├── ragtag/
│   └── ragtag.scaffold.fasta   ← ✅ Improved scaffolded assembly
└── quast_scaffolded/
    └── report.html             ← ✅ Comparison: before vs after scaffolding
```

---

## 🚨 Common Errors & Fixes

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| QUAST: `No contigs > min length` | Assembly is very fragmented | Lower `--min-contig` to 200 |
| BUSCO: Database not found | First run, downloading | Wait for download; check internet |
| BUSCO: Very low completeness for virus | Viral genomes not in BUSCO | This is expected; use QUAST genome fraction instead |
| RagTag: `No valid alignments` | Query and reference too different | Check you're using the right reference species |
| RagTag: All contigs unplaced | Reference genome mismatch | Verify reference is the same organism |

---

---

## 🎉 Congratulations!

You've completed the full genome assembly pipeline:

```
Raw Reads (.fastq)
    ↓ FastQC → Fastp → MultiQC
Clean Reads
    ↓ SPAdes / Setu
Draft Assembly
    ↓ QUAST → BUSCO
Assembly Assessment
    ↓ RagTag
Scaffolded Genome Assembly ✅
```

---

*See you at dinner! 🍽️*
