# 🖥️ Session 2A: Quality Control of Raw Sequencing Data

**🎯 Goal:** Assess the quality of raw sequencing data and clean it before assembly  
**🛠️ Tools:** FastQC · Fastp · MultiQC

---

## 🧠 Concept: Why Do We Need Quality Control?

When a DNA sequencer produces reads, it isn't perfect. Think of it like OCR scanning a blurry photograph — some letters will be misread. In sequencing, these errors show up as:

- **Low-quality base calls** at the ends of reads
- **Adapter contamination** — synthetic sequences from the library prep that got sequenced accidentally
- **Overrepresented sequences** — potential contamination or artefacts
- **GC bias** — uneven representation of certain nucleotides

> 🔑 **Key Insight:** Feeding garbage data into an assembler produces a garbage genome. QC is your first line of defense.

### What is a FASTQ file?

Each sequencing read is stored in **FASTQ format** — 4 lines per read:

```
@SRR123456.1 read description
ATCGATCGATCGATCGATCG         ← DNA sequence
+
IIIIIIIIIIIIIIIIIIIII         ← Quality scores (ASCII-encoded Phred scores)
```

**Phred Quality Score** tells you how confident the sequencer is about each base call:

| Phred Score | Accuracy | Error Rate |
|-------------|----------|------------|
| 10 | 90% | 1 in 10 |
| 20 | 99% | 1 in 100 |
| 30 | 99.9% | 1 in 1,000 |
| 40 | 99.99% | 1 in 10,000 |

> ✅ **Rule of thumb:** You want most bases to have Phred score ≥ 20 (Q20), ideally ≥ 30 (Q30).

---


## 📁 Required Input Files

| File | Format | Description |
|------|--------|-------------|
| `sample_R1.fastq` | FASTQ | Forward reads (Read 1) |
| `sample_R2.fastq` | FASTQ | Reverse reads (Read 2) — for paired-end data |

> 📥 **Get sample data:**
> # Download from SRA (requires sra-tools)
> ```bash
> fasterq-dump --split-files --progress SRR11945456
> ```

## Rename the Files :

 ```bash
mv SRR11945456_1.fastq sample_R1.fastq
mv SRR11945456_2.fastq sample_R2.fastq
 ```

---

## 🔧 Tool : FastQC

### What is FastQC?
FastQC is a quality control tool that scans your FASTQ files and generates an **HTML report** with visual plots showing the quality of your data across multiple metrics.

### Install FastQC
```bash
# Via conda
conda install -c bioconda fastqc -y

# Verify
fastqc --version
```

### Run FastQC

```bash
# Create output directory
mkdir fastqc

# Run FastQC on both reads
fastqc \
    sample_R1.fastq \
    sample_R2.fastq \
    --outdir fastqc

# What each flag means:
# --outdir    : Where to save the HTML reports
# --threads   : Number of CPU cores to use (speeds things up)

```


### Understanding FastQC Output

After running, you'll find:
- `sample_R1_fastqc.html` — Open this in your browser!
- `sample_R1_fastqc.zip` — Raw data (used by MultiQC later)

  

**Key plots to look at:**

| Plot | What it shows | 🟢 Good | 🔴 Bad |
|------|---------------|---------|--------|
| Per Base Sequence Quality | Quality across read length | All green (Q>28) | Red/orange at ends |
| Per Sequence Quality Scores | Distribution of average quality | Peak at Q>30 | Peak at Q<20 |
| Adapter Content | Adapter contamination | Flat lines near 0% | Rising curves |
| Per Base N Content | Unknown bases | Near 0% | Any significant % |

> 💡 **Don't panic at red marks!** FastQC uses general thresholds. Low quality at 3' ends is normal and will be trimmed by Fastp.

---

## 🔧 Tool : MultiQC

### What is MultiQC?
MultiQC aggregates QC results from **multiple samples and tools** into a single beautiful HTML report. Instead of opening 10 individual FastQC reports, you get one interactive dashboard.

### Install MultiQC
```bash
conda install -c bioconda multiqc -y
# OR
pip install multiqc
```

### Run MultiQC

```bash
mkdir -p multiqc

# Run MultiQC on ALL results directories
# It will find FastQC, Fastp, and other compatible outputs automatically
multiqc \
    fastqc \
    --outdir multiqc

# Flag explanations:
# (input dirs)    : MultiQC searches these for recognized output files
# --outdir        : Where to save the report


```

> 💡 **Pro tip:** You can simply run `multiqc .` from your project directory and it will find everything automatically!

### Reading the MultiQC Report

Open `results/multiqc/multiqc_report.html` in your browser.

---

## 🔧 Tool : Fastp

### What is Fastp?
Fastp is an **all-in-one** FASTQ preprocessor that:
1. Trims low-quality bases from read ends
2. Removes adapter sequences
3. Filters out reads that are too short after trimming
4. Generates its own QC report

> 🚀 **Why Fastp over Trimmomatic?** Fastp is faster, has automatic adapter detection, and gives you a combined HTML report.

### Install Fastp
```bash
conda install -c bioconda fastp -y

# Verify
fastp --version
```

### Run Fastp

```bash
mkdir -p fastp
cd fastp

fastp \
    --in1 ../sample_R1.fastq \
    --in2 ../sample_R2.fastq \
    --out1 clean_R1.fastq \
    --out2 clean_R2.fastq \
    --html fastp_report.html \
    --json fastp_report.json \
    --qualified_quality_phred 20 \
    --length_required 50 \
    --detect_adapter_for_pe \
    --correction \
    --thread 2

# Flag explanations:
# --in1/--in2              : Input files (R1 and R2)
# --out1/--out2            : Clean output files
# --html/--json            : Report formats
# --qualified_quality_phred: Min quality score to keep a base (Q20)
# --length_required        : Drop reads shorter than 50 bp after trimming
# --detect_adapter_for_pe  : Auto-detect adapters for paired-end data
# --correction             : Correct mismatched bases in overlapping regions
# --thread                 : CPU threads


```

### What does Fastp output?

```
results/fastp/
├── clean_R1.fastq.gz   ← Your cleaned reads (USE THESE GOING FORWARD)
├── clean_R2.fastq.gz   ← Your cleaned reads
├── fastp_report.html   ← Visual report
└── fastp_report.json   ← Machine-readable stats (used by MultiQC)
```

**Check the summary statistics in the HTML report:**

| Metric | What it means | Target |
|--------|---------------|--------|
| Reads passed filter | % reads kept after QC | >80% |
| Q20 rate | % bases with quality ≥ 20 | >95% |
| Q30 rate | % bases with quality ≥ 30 | >85% |
| GC content | Should match expected for organism | Species-specific |

---


## 📊 Expected Output After Session 2A

```
├── fastp/
│   ├── clean_R1.fastq.gz       ← ✅ Clean reads for assembly
│   ├── clean_R2.fastq.gz       ← ✅ Clean reads for assembly
│   └── fastp_report.html
└── multiqc/
    └── multiqc_report.html     ← ✅ Combined report
```

---

## ✅ QC Checklist Before Moving to Assembly

- [ ] FastQC shows no adapter contamination in clean reads
- [ ] Per Base Sequence Quality shows green/yellow (no red)
- [ ] >80% reads passed Fastp filtering
- [ ] Q30 rate >85%
- [ ] You have `clean_R1.fastq.gz` and `clean_R2.fastq.gz` ready

---

## 🚨 Common Errors & Fixes

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| `java.lang.OutOfMemoryError` in FastQC | Not enough RAM | Add `--memory 4096` flag |
| `Failed to open file` | Wrong file path | Use `ls` to check file exists |
| Very few reads passing Fastp | QC settings too strict | Lower `--qualified_quality_phred` to 15 |
| MultiQC report is empty | Wrong input directory | Check paths with `ls results/` |

---

## ➡️ Next Step

Proceed to **[Session 2B-i: Genome Assembly](../session-2B-i/README.md)**

You'll be using your clean reads (`clean_R1.fastq.gz` and `clean_R2.fastq.gz`) to assemble a genome!
