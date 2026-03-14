# 🧬 Day 2: From Raw Data to Complete Genomes — The Assembly Quest


---

## 📋 Table of Contents

1. [What You Will Learn Today](#what-you-will-learn-today)
2. [Environment Setup](#environment-setup)
3. [Session 2A — Quality Control](# 🖥️ Session 2A: Quality Control of Raw Sequencing Data)
4. [Session 2B-i — Genome Assembly](#-session-2b-i-genome-assembly)
5. [Session 2B-ii — Assembly Quality Assessment](#-session-2b-ii-assembly-quality-assessment)
6. [Glossary](#-glossary)


---

## 🎯 What You Will Learn Today

By the end of today, you will be able to:

- ✅ Understand what raw sequencing data looks like and why quality control matters
- ✅ Run **FastQC**, **Fastp**, and **MultiQC** to assess and clean sequencing reads
- ✅ Assemble a viral genome using **Setu** and **SPAdes**
- ✅ Evaluate your assembly using **QUAST**, **BUSCO**, and **RagTag**
- ✅ Understand what a "good" genome assembly looks like.

---

## ⚙️ Environment Setup

### Option A: Conda (Recommended)

```

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


