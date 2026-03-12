# 🧬 Day 2: From Raw Data to Complete Genomes — The Assembly Quest

> **Workshop Date:** 17th March  
> **Level:** Beginner-Friendly | Bioinformatics Training Module  
> **Estimated Time:** Full Day (~8 hours hands-on)

---

## 📋 Table of Contents

1. [What You Will Learn Today](#what-you-will-learn-today)
2. [Prerequisites](#prerequisites)
3. [Environment Setup](#environment-setup)
4. [Day Schedule at a Glance](#day-schedule-at-a-glance)
5. [Session 2A — Quality Control](#-session-2a-quality-control-of-raw-sequencing-data)
6. [Session 2B-i — Genome Assembly](#-session-2b-i-genome-assembly)
7. [Session 2B-ii — Assembly Quality Assessment](#-session-2b-ii-assembly-quality-assessment)
8. [Glossary](#-glossary)
9. [Further Reading](#-further-reading)

---

## 🎯 What You Will Learn Today

By the end of today, you will be able to:

- ✅ Understand what raw sequencing data looks like and why quality control matters
- ✅ Run **FastQC**, **Fastp**, and **MultiQC** to assess and clean sequencing reads
- ✅ Assemble a viral genome using **Setu** and **SPAdes**
- ✅ Evaluate your assembly using **QUAST**, **BUSCO**, and **RagTag**
- ✅ Understand what a "good" genome assembly looks like

---

## 🧰 Prerequisites

You don't need to be an expert, but it helps to know:
- Basic Linux command line (navigating directories, running commands)
- What DNA sequencing is (conceptually)

> 💡 **New to Linux?** Check out [this 10-minute crash course](https://ubuntu.com/tutorials/command-line-for-beginners) before you start.

---

## ⚙️ Environment Setup

### Option A: Conda (Recommended)

```bash
# Install Miniconda if you haven't already
# https://docs.conda.io/en/latest/miniconda.html

# Create a dedicated environment for today
conda create -n genome-assembly python=3.9 -y
conda activate genome-assembly

# Install all tools at once
conda install -c bioconda -c conda-forge \
    fastqc fastp multiqc spades quast busco ragtag -y
```

### Option B: Install Individually (see each session for instructions)

### Verify your installation
```bash
fastqc --version
fastp --version
multiqc --version
spades.py --version
quast.py --version
busco --version
ragtag.py --version
```

---

## 📅 Day Schedule at a Glance

| Time | Activity |
|------|----------|
| 09:30 – 11:15 | 🎤 Talks: Genome Assembly Concepts |
| 11:45 – 13:00 | 🖥️ [Session 2A: QC with FastQC, Fastp, MultiQC](sessions/session-2A/README.md) |
| 14:00 – 15:30 | 🖥️ [Session 2B-i: Assembly with Setu + SPAdes](sessions/session-2B-i/README.md) |
| 16:00 – 18:00 | 🖥️ [Session 2B-ii: Quality Assessment with QUAST, BUSCO, RagTag](sessions/session-2B-ii/README.md) |

---

## 🔬 The Big Picture: What Are We Doing Today?

```
Raw Reads (.fastq)
      │
      ▼
[Quality Control]  ← FastQC, Fastp, MultiQC
      │
      ▼
Clean Reads (.fastq)
      │
      ▼
[Genome Assembly]  ← Setu, SPAdes
      │
      ▼
Assembled Contigs (.fasta)
      │
      ▼
[Quality Assessment] ← QUAST, BUSCO, RagTag
      │
      ▼
Final Genome Assembly ✅
```

> This pipeline takes you from millions of short DNA fragments to a reconstructed genome. Think of it like piecing together a shredded document — except the document has 3 billion letters!

---

## 📂 Repository Structure

```
day2-genome-assembly/
├── README.md                    ← You are here
├── sessions/
│   ├── session-2A/
│   │   └── README.md            ← QC Session Guide
│   ├── session-2B-i/
│   │   └── README.md            ← Assembly Session Guide
│   └── session-2B-ii/
│       └── README.md            ← Assessment Session Guide
├── data/
│   └── sample/                  ← Sample data for practice
├── scripts/
│   ├── run_qc.sh               ← Automated QC script
│   ├── run_assembly.sh         ← Automated assembly script
│   └── run_assessment.sh       ← Automated assessment script
└── GLOSSARY.md                 ← Key terms explained
```

---

## 📖 Glossary

See the full [GLOSSARY.md](GLOSSARY.md) for all key terms.

| Term | One-liner |
|------|-----------|
| **Read** | A short DNA sequence (~150-300 bp) produced by a sequencer |
| **Contig** | A contiguous assembled DNA sequence |
| **Scaffold** | Contigs ordered and oriented using additional information |
| **N50** | Length at which 50% of the assembly is in contigs of this size or longer |
| **BUSCO** | Benchmark of Universal Single-Copy Orthologs — measures genome completeness |

---

## 🆘 Getting Help

- Open an **Issue** on this repo if something doesn't work
- Tag your question with the session name (e.g., `[Session 2A]`)
- Check the [Troubleshooting](TROUBLESHOOTING.md) guide first

---

## 📚 Further Reading

- [Bioinformatics Algorithms (Compeau & Pevzner)](https://www.bioinformaticsalgorithms.org/)
- [The Sequence Read Archive (SRA)](https://www.ncbi.nlm.nih.gov/sra)
- [Galaxy Training Network — Genome Assembly](https://training.galaxyproject.org/training-material/topics/assembly/)

---

*Made with ❤️ for the next generation of bioinformaticians*
