# 🖥️ Session 2B-i: Genome Assembly

**🎯 Goal:** Assemble a viral genome from clean sequencing reads  
**🛠️ Tools:** Setu · SPAdes

---

## 🧠 Concept: What Is Genome Assembly?

Imagine you take a book, shred it into millions of tiny paper strips (each 150–300 characters long), and then try to **reconstruct the original text** by finding overlapping strips.

That's essentially what genome assembly does!

A DNA sequencer produces millions of short reads. The assembler's job is to:
1. Find overlapping reads
2. Merge them into longer sequences called **contigs**
3. Optionally order and orient contigs into **scaffolds**

### Two Main Assembly Approaches

| Approach | How it works | Best for |
|----------|--------------|----------|
| **Overlap-Layout-Consensus (OLC)** | Finds all pairwise overlaps between reads | Long reads (PacBio, Nanopore) |
| **De Bruijn Graph (DBG)** | Breaks reads into k-mers, builds a graph | Short reads (Illumina) ← Today's method |

### What is a De Bruijn Graph?

SPAdes uses this approach. Here's the core idea:

1. Every read is broken into **k-mers** (substrings of length k)
2. These k-mers are nodes in a graph
3. Edges connect k-mers that overlap by k-1 bases
4. Finding a path through this graph = reconstructing the genome

```
Read: ATCGATCG
k=4 → ATCG → TCGA → CGAT → GATC → ATCG

Graph path:
ATCG → TCGA → CGAT → GATC → ATCG
          ↓
    Contig: ATCGATCG ✅
```

> 🔑 **Key Insight:** Choosing the right k-mer size (k) is critical. Too small = too many connections (tangled graph). Too large = gaps where coverage is low.

### Key Terminology

| Term | Definition |
|------|------------|
| **k-mer** | A substring of length k (e.g., ATCG is a 4-mer) |
| **Contig** | A contiguous assembled sequence with no gaps |
| **Scaffold** | Contigs joined with estimated gaps (Ns) using paired-end info |
| **Coverage/Depth** | Average number of reads covering each base of the genome |
| **N50** | The length L such that 50% of the assembly is in contigs ≥ L |

### What Makes a Good Assembly?

```
Poor Assembly:          Good Assembly:
████ ██ █ ██ ████       ████████████████████
(many short contigs)    (few long contigs)

Contigs = 5,000         Contigs = 10
```

---

## 📁 Required Input Files

| File | Format | Description |
|------|--------|-------------|
| `setu_R1.fastq` | FASTQ | Clean forward reads from Session 2A |
| `setu_R2.fastq` | FASTQ | Clean reverse reads from Session 2A |

---

## 🔧 Tool : Setu (Viral Genome Assembly Pipeline)

### What is Setu?
**Setu** is a pipeline specifically designed for **viral genome assembly**. It wraps multiple tools into a streamlined workflow optimized for:
- High mutation rate viral genomes
- Mixed infection (quasi-species)
- Reference-guided and de novo assembly

> 🦠 **Why a special pipeline for viruses?** Viral genomes are small (few kb to a few hundred kb) but can have very high mutation rates. Standard assembly pipelines may miss low-frequency variants.

### Install Setu and its dependencies 
```bash
# Setu can be installed using git-clone
git clone https://github.com/jnarayan81/setu.git
# install the Dependencies:
cd setu
```

> 📥 **Get sample data:**
> # Download from SRA (requires sra-tools)
> ```bash
> fasterq-dump --split-files --progress SRR11945456
> ```

## Rename the Files :

 ```bash
mv SRR11945456_1.fastq setu_R1.fastq
mv SRR11945456_2.fastq setu_R2.fastq
 ```

### Run Setu (Reference-Guided Viral Assembly)

```bash
conda activate setu 
mkdir -p ../setu_output
./setu.sh -k yes -m pe -t 2 -r setu_R1.fastq,setu_R2.fastq -f on -o ../setu_output
```

```
# Flag explanations:
# -r  : Input clean reads
# -o  : Output directory
# -t  : CPU threads
# -m  : mode (single/paired-end)
```

---

## 🔧 Tool : SPAdes

### What is SPAdes?
**SPAdes** (St. Petersburg genome assembler) is one of the most popular genome assemblers for:
- Bacterial genomes
- Viral genomes
- Metagenomes
- Single-cell sequencing data

It uses a **multi-k-mer De Bruijn Graph** approach — running the assembly at multiple k-mer sizes and combining results.

### Install SPAdes
```bash
# Verify
spades.py --version
```
## Get back to 

### Run SPAdes — Basic Assembly

```bash

spades.py \
    -1 setu/sequence_PR1_trimmed.fq  \
    -2 setu/sequence_PR2_trimmed.fq  \
    -o spades_viral \
    --threads 2 \
    --memory 8 \
    --cov-cutoff auto
```

```
# Flag explanations:
# -1 / -2         : Paired-end read files (R1 and R2)
# -o              : Output directory
# --threads       : Number of CPU cores
# --memory        : Max RAM in gigabytes
# Additional flags:
# --careful       : Reduce mismatches (slower but more accurate for viruses)
# --cov-cutoff auto : Automatically remove low-coverage (likely error) contigs
```

### SPAdes Output Files

```
spades_viral
├── scaffolds.fasta          ← ✅ Primary output — use this!
├── contigs.fasta            ← Contigs before scaffolding
├── assembly_graph.gfa       ← Assembly graph (view in Bandage)
├── spades.log               ← Full log (check here if errors occur)
└── K21/ K33/ K55/ K77/      ← Per k-mer assembly results
```

> 🔑 **Use `scaffolds.fasta` as your final assembly for downstream analysis.**

### Understanding SPAdes Contig Names

Each sequence in the output has a name like:
```
>NODE_1_length_45231_cov_85.3
       │         │          └─ Average coverage depth
       │         └─ Length in base pairs
       └─ Node number (1 = longest contig)
```

### 🎯 Tips for Better SPAdes Assemblies

| Situation | Recommendation |
|-----------|----------------|
| Viral genome (<1 Mb) | Use `--careful` mode |
| High coverage (>100x) | Try `--cov-cutoff auto` |
| Poor assembly (many contigs) | Check read quality; try different k values with `-k 21,33,55,77` |
| Metagenomic sample | Replace `spades.py` with `metaspades.py` |

---

## 📊 Quick Assembly Stats Check

Before moving on, do a quick sanity check:

```bash
cd setu

# Count number of contigs/scaffolds
grep -c ">" ragout/setu_scaffolds.fasta
```
```
# Check total assembly size
grep -v ">" ragout/setu_scaffolds.fasta | tr -d '\n' | wc -c
```
```
# View the longest contigs
grep ">" ragout/setu_scaffolds.fasta | head -20
```
```
# Get back to parent directory
cd ..
```

**What to look for (viral genome example):**
- Viral genomes are typically **5 kb – 200 kb**
- Good viral assembly: **1–5 contigs** covering most of the genome
- If you have 1000+ tiny contigs, something went wrong in QC or assembly

---

## 📊 Expected Output After Session 2B-i

```
results/
├── setu/ragout/
│   └── setu_scaffolds.fasta         ← Setu viral assembly
└── spades_viral/
    └── scaffolds.fasta         ← ✅ SPAdes assembly (use this)
```

---

## 🚨 Common Errors & Fixes

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| `== Error ==  system call failed` | Not enough memory | Reduce `--memory` or use a machine with more RAM |
| Assembly takes forever | Large genome + many reads | Subsample reads: `seqtk sample -s 42 R1.fq.gz 1000000` |
| Only tiny contigs (<500 bp) | Low coverage or poor QC | Check coverage depth; revisit Fastp settings |
| SPAdes crashes at k=127 | Read length too short | Omit large k values: `-k 21,33,55,77` |

---

---

## ➡️ Next Step

Proceed to **[Session 2B-ii: Assembly Quality Assessment](../session-2B-ii/README.md)**

You'll be evaluating how good your assembly is using QUAST, BUSCO, and RagTag!
