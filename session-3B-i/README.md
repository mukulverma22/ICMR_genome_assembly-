# 🖥️ Session 3B(i): Sequence Alignment & Phylogenetic Tree Construction

**🎯 Goal:** Align multiple sequences, build a maximum likelihood phylogenetic tree, and visualize it  
**🛠️ Tools:** MAFFT · IQ-TREE · iTOL

---

## 🧠 Concept 1: Why Align Sequences First?

Before you can compare sequences or build a tree, you need to figure out **which positions across different sequences are evolutionarily equivalent** — i.e., descended from the same position in a common ancestor.

Imagine three sentences that all evolved from a common ancestor sentence:
```
Ancestor:   THE_CAT_SAT_ON_THE_MAT
Species A:  THE_BAT_SAT_ON_THE_MAT   (C→B mutation)
Species B:  THE_CAT_SA__ON_THE_MAT   (deletion of T)
Species C:  THE_CAT_SSAT_ON_THE_MAT  (insertion of S)
```

Without alignment, comparing position-by-position gives nonsense. **Alignment inserts gaps (`-`) so homologous positions line up:**

```
Unaligned:              Aligned (MSA):
THEBATSATONTHEMAT       THE-BAT-SAT-ON-THE-MAT
THECATSAONTHEMAT   →    THE-CAT-SA--ON-THE-MAT
THECATSSATONTHEMAT      THE-CAT-SSAT-ON-THE-MAT
```

> 🔑 **Key Insight:** A phylogenetic tree is only as good as the alignment it's built from. Garbage alignment = garbage tree.

---

## 🧠 Concept 2: What Is a Phylogenetic Tree?

A phylogenetic tree represents **evolutionary relationships** between sequences (or organisms). It is a hypothesis about who shares a more recent common ancestor with whom.

```
        ┌──── Species A
    ┌───┤
    │   └──── Species B
────┤
    │   ┌──── Species C
    └───┤
        └──── Species D
```

### Anatomy of a Tree

| Part | What it means |
|------|--------------|
| **Tip / Leaf** | Your input sequences (taxa) |
| **Node** | A hypothetical common ancestor |
| **Branch** | Evolutionary lineage connecting ancestors to descendants |
| **Branch length** | Amount of evolutionary change (substitutions per site) |
| **Root** | The common ancestor of all sequences in the tree |
| **Clade** | A group of sequences + their common ancestor |
| **Bootstrap value** | Statistical support for a node (0–100; >70 = well-supported) |

### Tree-Building Methods

| Method | How it works | Speed | Accuracy |
|--------|--------------|-------|----------|
| **Neighbor-Joining (NJ)** | Groups most similar sequences iteratively | Very fast | Low–Medium |
| **Maximum Parsimony (MP)** | Finds tree requiring fewest mutations | Medium | Medium |
| **Maximum Likelihood (ML)** | Finds tree most likely to produce observed data under a model | Slow | High ✅ |
| **Bayesian Inference (BI)** | Uses probability distributions over trees | Very slow | Highest |

> Today we use **Maximum Likelihood** — the gold standard for most phylogenetic analyses.

### What Is a Substitution Model?

DNA doesn't mutate randomly. Some substitutions happen more often than others (e.g., A↔G transitions are more common than A↔C transversions). A **substitution model** mathematically describes these rates.

| Model | What it accounts for |
|-------|---------------------|
| **JC69** | All substitutions equal (simplest) |
| **K2P / K80** | Transitions ≠ transversions |
| **HKY85** | Base frequencies + transitions ≠ transversions |
| **GTR** | All rates different (most general, most realistic) |
| **GTR+G** | GTR + rate variation across sites (gamma distribution) |
| **GTR+G+I** | GTR + rate variation + invariant sites |

> 🔑 **IQ-TREE will automatically find the best model for your data** using ModelTest — you don't need to choose manually.

---

## 📁 Required Input Files

| File | Format | Description |
|------|--------|-------------|
| `sequences.fasta` | FASTA | Unaligned input sequences (DNA or protein) |

> 📥 **Get sample data:**
> ```bash
> mkdir phylo
> cd phylo
> # Download the provided sample using command
> wget https://raw.githubusercontent.com/mukulverma22/ICMR_genome_assembly-/refs/heads/main/day2-genome-assembly/demo_phylo.fasta
> mv demo_phylo.fasta sequences.fasta
> ```

### What Should My Input Sequences Be?

- **Minimum:** 4 sequences (trees with fewer are trivial)
- **Format:** All sequences in one FASTA file, **unaligned** (different lengths are fine)

```bash
# Check your input file
grep -c ">" sequences.fasta    # Count sequences
grep ">" sequences.fasta        # See all sequence names

```

```
# Example of what unaligned sequences look like:
# >Virus_A_2020
# ATCGATCGATCGATCG
# >Virus_B_2021
# ATCGATCGATCGTTCGAT      ← different length, that's OK
# >Virus_C_2022
# AGCGATCGATCGATCGATCG
```

---

## 🔧 Step 1: Multiple Sequence Alignment (MSA)

You have two excellent tools for MSA: **MUSCLE** and **MAFFT**. Both produce similar results; MAFFT is generally faster for large datasets.

---
---

### Tool 1: MAFFT

**MAFFT** (Multiple Alignment using Fast Fourier Transform) is faster than MUSCLE for large datasets and has several alignment strategies to choose from.

#### Verify installation of MAFFT
```bash
# Verify
mafft --version
mkdir -p alignment
```

#### Run MAFFT

```bash
# Auto mode (MAFFT picks the best strategy for your data)
mafft \
    --auto \
    --thread 4 \
    --reorder \
    sequences.fasta > alignment/aligned_mafft.fasta
```
```
# For high accuracy (small datasets <20 sequences)
mafft \
    --localpair \
    --maxiterate 1000 \
    --thread 4 \
    sequences.fasta > alignment/aligned_mafft.fasta
```
```
# Flag explanations:
# --auto           : Automatically choose strategy based on dataset size
# --thread         : CPU threads
# --reorder        : Output sequences in aligned order (not input order)
# --retree 2       : Fast guide tree (FFT-NS-2 strategy)
# --localpair      : L-INS-i strategy — highest accuracy
# --maxiterate     : Number of iterative refinements (1000 = thorough)
```

### MAFFT Strategy Cheat Sheet

| Dataset Size | Recommended Strategy | Flag |
|-------------|---------------------|------|
| <20 sequences | L-INS-i (highest accuracy) | `--localpair --maxiterate 1000` |
| 20–200 sequences | G-INS-i | `--globalpair --maxiterate 1000` |
| 200–10,000 sequences | FFT-NS-2 | `--retree 2` |
| >10,000 sequences | FFT-NS-1 (fastest) | `--retree 1` |

---

### Checking Your Alignment

After aligning, all sequences should be the **same length** (gaps fill the differences):

```bash

# Visualize the alignment (terminal)
head -40 alignment/aligned_mafft.fasta

```

> 💡 **Visualize your alignment properly** using [AliView](https://ormbunkar.se/aliview/) (free desktop app) or upload to [Wasabi](http://wasabi2.biocsc.fi/) (online). Look for:
> - Long runs of gaps (may indicate poor alignment or outlier sequences)
> - Highly variable regions vs. conserved regions
> - Obvious misalignments (sequence in completely wrong position)

---

## 🔧 Step 2: Phylogenetic Tree Construction

You have two powerful ML tree-building tools: **IQ-TREE** (recommended for beginners).

---

### Tool 2: IQ-TREE ⭐ (Recommended)

**IQ-TREE** is the modern, user-friendly ML tree builder. It:
- **Automatically selects the best substitution model** (ModelFinder)
- Runs ultrafast bootstrap in one command
- Is faster and often more accurate than RAxML for most datasets

#### Verify the installation of  IQ-TREE
```bash
# Verify
iqtree --version
```

#### Run IQ-TREE — Standard Analysis

```bash
mkdir -p iqtree

iqtree -s alignment/aligned_mafft.fasta -m TEST -bb 1000 -o Seq6_Mus_musculus_OUTGROUP -nt 2 --prefix iqtree/mytree
```
```

# Flag explanations:
# -s        : Input aligned FASTA
# -m TEST   : Run ModelFinder to auto-select best substitution model
# -bb 1000  : Ultrafast bootstrap with 1000 replicates (adds support values)
# -o        : Outgroup for rooting 
# -nt AUTO  : Auto-detect number of CPU threads
# --prefix  : Prefix for all output files
```


#### IQ-TREE Output Files

```
iqtree/
├── mytree.treefile         ← ✅ Your phylogenetic tree (Newick format)
├── mytree.iqtree           ← Full analysis report (model, log-likelihood, etc.)
├── mytree.log              ← Log file
├── mytree.contree          ← Consensus tree (from bootstrap replicates)
└── mytree.model.gz         ← ModelFinder results
```

#### Reading the IQ-TREE Report

```bash
# See which model was chosen
grep "Best-fit model" iqtree/mytree.iqtree
```
```
# See log-likelihood score
grep "Log-likelihood" iqtree/mytree.iqtree
```
```
# See tree in Newick format
cat iqtree/mytree.treefile
```

---

## 🔧 Step 3: Tree Visualization & Annotation

Your tree is currently in **Newick format** — a text representation using brackets:

```
((Species_A:0.1,Species_B:0.2):0.3,(Species_C:0.05,Species_D:0.15):0.2);
```

This is not human-readable. You need a visualization tool.

---

### iTOL (Online — Best for Publication Figures)

**iTOL** (Interactive Tree of Life) is a powerful web-based tool at [itol.embl.de](https://itol.embl.de).

```bash
# Just upload your tree file to https://itol.embl.de
# Supports: annotation, colouring, circular/rectangular layouts, export

# Your tree file to upload:
cat iqtree/mytree.treefile
```

**iTOL features:**
- 🎨 Colour clades, branches, and labels
- 📊 Add metadata (e.g., geographic location, year, host)
- 🔄 Circular, rectangular, and unrooted layouts
- 📄 Export as SVG, PDF, PNG

---

---

## 📊 Expected Output Structure

```
phylo/
├── alignment/
│   └── aligned_mafft.fasta      ← MAFFT alignment (use this)
├── iqtree/
    ├── mytree.treefile          ← ✅ Your ML tree
    └── mytree.iqtree            ← Model and stats report

```

---

## 🔍 How to Interpret Your Tree

### Bootstrap Support Values

```
            100              ← Strong support (trust this clade)
        ┌────┤
        │   95               ← Good support
    ────┤  ┌─┤
        │  │ 45              ← Weak support (interpret with caution)
        └──┤
           └─ ...
```

| Bootstrap Value | Interpretation |
|----------------|----------------|
| ≥ 95 | Strong — highly reliable clade |
| 70–94 | Good — generally trustworthy |
| 50–69 | Moderate — treat with caution |
| < 50 | Weak — unreliable, may be an artifact |

### Reading Branch Lengths

- **Longer branch** = more evolutionary change (more mutations)
- **Short branches** = recently diverged / very similar sequences
- **Very long outlier branch** = possible contamination or sequencing error — investigate!

---

---

## 📚 Further Reading

- [IQ-TREE Tutorial](http://www.iqtree.org/doc/Tutorial)
- [MAFFT Manual](https://mafft.cbrc.jp/alignment/software/manual/manual.html)
- [iTOL Documentation](https://itol.embl.de/help.cgi)

---

*← Back to [Day 2 Main README](../../README.md)*
