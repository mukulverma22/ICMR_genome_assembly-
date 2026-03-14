# 🖥️ Session 3B(i): Sequence Alignment & Phylogenetic Tree Construction

**⏰ Time:** 14:00 – 14:30  
**👨‍🏫 Instructor:** Mukul  
**🎯 Goal:** Align multiple sequences, build a maximum likelihood phylogenetic tree, and visualize it  
**🛠️ Tools:** MUSCLE · MAFFT · RAxML · IQ-TREE · FigTree / iTOL

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
| `outgroup.fasta` | FASTA | Optional: outgroup sequence to root the tree |

### What Should My Input Sequences Be?

- **Minimum:** 4 sequences (trees with fewer are trivial)
- **Recommended:** 10–100 sequences for a meaningful tree
- **Format:** All sequences in one FASTA file, **unaligned** (different lengths are fine)

```bash
# Check your input file
grep -c ">" sequences.fasta    # Count sequences
grep ">" sequences.fasta        # See all sequence names

# Example of what unaligned sequences look like:
# >Virus_A_2020
# ATCGATCGATCGATCG
# >Virus_B_2021
# ATCGATCGATCGTTCGAT      ← different length, that's OK
# >Virus_C_2022
# AGCGATCGATCGATCGATCG
```

> 📥 **Get sample data:**
> ```bash
> # Download SARS-CoV-2 spike gene sequences from NCBI
> # Or use the provided sample in data/sample/sequences.fasta
> cp ../../data/sample/sequences.fasta .
> ```

---

## 🔧 Step 1: Multiple Sequence Alignment (MSA)

You have two excellent tools for MSA: **MUSCLE** and **MAFFT**. Both produce similar results; MAFFT is generally faster for large datasets.

---

### Tool 1A: MUSCLE

**MUSCLE** (Multiple Sequence Comparison by Log-Expectation) is a classic, reliable MSA tool known for accuracy on protein and DNA sequences.

#### Install MUSCLE
```bash
conda install -c bioconda muscle -y

# Verify
muscle -version
# Expected: MUSCLE v5.x
```

#### Run MUSCLE

```bash
mkdir -p results/alignment

# MUSCLE v5 syntax
muscle \
    -align sequences.fasta \
    -output results/alignment/aligned_muscle.fasta \
    -threads 4

# Older MUSCLE v3 syntax (if v5 not available)
muscle \
    -in sequences.fasta \
    -out results/alignment/aligned_muscle.fasta \
    -maxiters 16

# Flag explanations:
# -align / -in     : Input unaligned FASTA
# -output / -out   : Output aligned FASTA
# -threads         : CPU threads (v5 only)
# -maxiters        : Max refinement iterations (more = slower but better)
```

---

### Tool 1B: MAFFT

**MAFFT** (Multiple Alignment using Fast Fourier Transform) is faster than MUSCLE for large datasets and has several alignment strategies to choose from.

#### Install MAFFT
```bash
conda install -c bioconda mafft -y

# Verify
mafft --version
```

#### Run MAFFT

```bash
# Auto mode (MAFFT picks the best strategy for your data)
mafft \
    --auto \
    --thread 4 \
    --reorder \
    sequences.fasta > results/alignment/aligned_mafft.fasta

# For larger datasets (>200 sequences) — faster
mafft \
    --retree 2 \
    --maxiterate 0 \
    --thread 4 \
    sequences.fasta > results/alignment/aligned_mafft.fasta

# For high accuracy (small datasets <20 sequences)
mafft \
    --localpair \
    --maxiterate 1000 \
    --thread 4 \
    sequences.fasta > results/alignment/aligned_mafft.fasta

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
# All sequences should now be the same length
awk '/^>/{if(seq) print length(seq); seq=""} !/^>/{seq=seq$0} END{print length(seq)}' \
    results/alignment/aligned_mafft.fasta | sort -u

# Visualize the alignment (terminal)
head -40 results/alignment/aligned_mafft.fasta

# Count alignment columns (= length of any sequence)
awk 'NR==2{print length($0); exit}' results/alignment/aligned_mafft.fasta
```

> 💡 **Visualize your alignment properly** using [AliView](https://ormbunkar.se/aliview/) (free desktop app) or upload to [Wasabi](http://wasabi2.biocsc.fi/) (online). Look for:
> - Long runs of gaps (may indicate poor alignment or outlier sequences)
> - Highly variable regions vs. conserved regions
> - Obvious misalignments (sequence in completely wrong position)

---

## 🔧 Step 2: Phylogenetic Tree Construction

You have two powerful ML tree-building tools: **IQ-TREE** (recommended for beginners) and **RAxML**.

---

### Tool 2A: IQ-TREE ⭐ (Recommended)

**IQ-TREE** is the modern, user-friendly ML tree builder. It:
- **Automatically selects the best substitution model** (ModelFinder)
- Runs ultrafast bootstrap in one command
- Is faster and often more accurate than RAxML for most datasets

#### Install IQ-TREE
```bash
conda install -c bioconda iqtree -y

# Verify
iqtree2 --version
# Expected: IQ-TREE multicore version 2.x
```

#### Run IQ-TREE — Standard Analysis

```bash
mkdir -p results/iqtree

iqtree2 \
    -s results/alignment/aligned_mafft.fasta \
    -m TEST \
    -bb 1000 \
    -nt AUTO \
    --prefix results/iqtree/mytree

# Flag explanations:
# -s        : Input aligned FASTA
# -m TEST   : Run ModelFinder to auto-select best substitution model
# -bb 1000  : Ultrafast bootstrap with 1000 replicates (adds support values)
# -nt AUTO  : Auto-detect number of CPU threads
# --prefix  : Prefix for all output files
```

#### Run IQ-TREE — With Outgroup (to root the tree)

```bash
iqtree2 \
    -s results/alignment/aligned_mafft.fasta \
    -m TEST \
    -bb 1000 \
    -nt AUTO \
    -o "OutgroupSequenceName" \
    --prefix results/iqtree/mytree_rooted

# -o "Name" : Outgroup sequence name (must exactly match FASTA header)
```

#### IQ-TREE Output Files

```
results/iqtree/
├── mytree.treefile         ← ✅ Your phylogenetic tree (Newick format)
├── mytree.iqtree           ← Full analysis report (model, log-likelihood, etc.)
├── mytree.log              ← Log file
├── mytree.contree          ← Consensus tree (from bootstrap replicates)
└── mytree.model.gz         ← ModelFinder results
```

#### Reading the IQ-TREE Report

```bash
# See which model was chosen
grep "Best-fit model" results/iqtree/mytree.iqtree

# See log-likelihood score
grep "Log-likelihood" results/iqtree/mytree.iqtree

# See tree in Newick format
cat results/iqtree/mytree.treefile
```

---

### Tool 2B: RAxML

**RAxML** (Randomized Axelerated Maximum Likelihood) is a battle-tested, high-performance ML tree builder. Preferred for very large datasets (hundreds to thousands of sequences).

#### Install RAxML
```bash
conda install -c bioconda raxml -y
# OR install the newer RAxML-NG
conda install -c bioconda raxml-ng -y

# Verify
raxmlHPC --version
# OR
raxml-ng --version
```

#### Run RAxML (Classic)

```bash
mkdir -p results/raxml

# Standard ML search with bootstrap
raxmlHPC \
    -s results/alignment/aligned_mafft.fasta \
    -n mytree \
    -m GTRGAMMA \
    -p 12345 \
    -x 12345 \
    -# 100 \
    -w $(pwd)/results/raxml \
    -T 4

# Flag explanations:
# -s         : Input aligned FASTA
# -n         : Run name (prefix for output files)
# -m GTRGAMMA: Substitution model (GTR + Gamma rate variation)
# -p 12345   : Random seed for reproducibility
# -x 12345   : Bootstrap random seed
# -# 100     : Number of bootstrap replicates (100 is standard)
# -w         : Output directory (MUST be absolute path!)
# -T 4       : CPU threads
```

#### Run RAxML-NG (Modern version)

```bash
raxml-ng \
    --all \
    --msa results/alignment/aligned_mafft.fasta \
    --model GTR+G \
    --prefix results/raxml/mytree \
    --bs-trees 100 \
    --threads 4 \
    --seed 12345

# --all      : Run ML search + bootstrap in one step
# --msa      : Input aligned FASTA
# --model    : Substitution model
# --bs-trees : Number of bootstrap replicates
```

#### RAxML Output Files

```
results/raxml/
├── RAxML_bestTree.mytree         ← ✅ Best ML tree
├── RAxML_bipartitions.mytree     ← ✅ Best tree WITH bootstrap values
├── RAxML_bootstrap.mytree        ← All 100 bootstrap trees
├── RAxML_info.mytree             ← Run statistics and model parameters
└── RAxML_log.mytree              ← Log-likelihood per iteration
```

> ✅ **Use `RAxML_bipartitions.mytree` for visualization** — it has the bootstrap support values on the nodes.

### IQ-TREE vs RAxML — When to Use Which?

| Situation | Recommendation |
|-----------|---------------|
| General use / teaching | **IQ-TREE** — easier, auto model selection |
| <500 sequences | **IQ-TREE** |
| >500 sequences | **RAxML** — better parallelization |
| Need model testing | **IQ-TREE** (built-in ModelFinder) |
| Need fast bootstrap | **IQ-TREE** (UFBoot is much faster) |
| Publication (large phylogenomics) | **RAxML-NG** or **IQ-TREE** |

---

## 🔧 Step 3: Tree Visualization & Annotation

Your tree is currently in **Newick format** — a text representation using brackets:

```
((Species_A:0.1,Species_B:0.2):0.3,(Species_C:0.05,Species_D:0.15):0.2);
```

This is not human-readable. You need a visualization tool.

---

### Option A: FigTree (Desktop — Recommended for Beginners)

**FigTree** is a free desktop app for viewing and annotating Newick/Nexus trees.

#### Install FigTree
```bash
# Download from: http://tree.bio.ed.ac.uk/software/figtree/
# OR via conda
conda install -c bioconda figtree -y
```

#### Open Your Tree
```bash
figtree results/iqtree/mytree.treefile
```

#### Key FigTree Options

| Feature | Where to find it | What it does |
|---------|-----------------|--------------|
| Bootstrap values | Node Labels → Label → "label" | Show support values on nodes |
| Branch lengths | Trees → Scale bar | Toggle branch length display |
| Root tree | Trees → Root tree → midpoint | Root using midpoint method |
| Colour branches | Appearance → Colour by | Colour-code by metadata |
| Export | File → Export PDF/SVG | Save publication-quality image |

---

### Option B: iTOL (Online — Best for Publication Figures)

**iTOL** (Interactive Tree of Life) is a powerful web-based tool at [itol.embl.de](https://itol.embl.de).

```bash
# Just upload your tree file to https://itol.embl.de
# Supports: annotation, colouring, circular/rectangular layouts, export

# Your tree file to upload:
cat results/iqtree/mytree.treefile
```

**iTOL features:**
- 🎨 Colour clades, branches, and labels
- 📊 Add metadata (e.g., geographic location, year, host)
- 🔄 Circular, rectangular, and unrooted layouts
- 📄 Export as SVG, PDF, PNG

---

### Option C: Command-Line Quick View

```bash
# Install ETE toolkit for command-line tree viewing
pip install ete3

python3 -c "
from ete3 import Tree
t = Tree('results/iqtree/mytree.treefile')
print(t.get_ascii(show_internal=True))
"
```

---

## 📊 Full Pipeline — All Commands in One Place

```bash
# ── 0. Setup ──────────────────────────────────────────────
mkdir -p results/{alignment,iqtree,raxml}
cp ../../data/sample/sequences.fasta .

# ── 1. Align with MAFFT ───────────────────────────────────
mafft --auto --thread 4 --reorder \
    sequences.fasta > results/alignment/aligned.fasta

# Verify alignment (all lengths should be equal)
awk '/^>/{if(seq)print length(seq); seq=""} !/^>/{seq=seq$0} END{print length(seq)}' \
    results/alignment/aligned.fasta | sort -u

# ── 2. Build ML tree with IQ-TREE ─────────────────────────
iqtree2 \
    -s results/alignment/aligned.fasta \
    -m TEST \
    -bb 1000 \
    -nt AUTO \
    --prefix results/iqtree/mytree

# ── 3. Check results ──────────────────────────────────────
grep "Best-fit model" results/iqtree/mytree.iqtree
cat results/iqtree/mytree.treefile

# ── 4. Visualize ──────────────────────────────────────────
figtree results/iqtree/mytree.treefile
# OR upload mytree.treefile to https://itol.embl.de
```

---

## 📊 Expected Output Structure

```
results/
├── alignment/
│   ├── aligned_muscle.fasta     ← MUSCLE alignment
│   └── aligned_mafft.fasta      ← MAFFT alignment (use this)
├── iqtree/
│   ├── mytree.treefile          ← ✅ Your ML tree
│   └── mytree.iqtree            ← Model and stats report
└── raxml/
    └── RAxML_bipartitions.mytree ← ✅ RAxML tree with bootstrap
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

## ✅ Checklist

- [ ] Input sequences are in a single FASTA file
- [ ] Alignment completed — all sequences same length
- [ ] Alignment visually inspected in AliView or similar
- [ ] IQ-TREE tree file generated (`mytree.treefile`)
- [ ] Bootstrap support values present
- [ ] Tree visualized in FigTree or iTOL
- [ ] Suspicious long branches investigated

---

## 🚨 Common Errors & Fixes

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| `Sequence not the same length` | Alignment step was skipped | Run MAFFT/MUSCLE first |
| IQ-TREE: `Identical sequences found` | Duplicate sequences | Remove duplicates with `seqkit rmdup -s` |
| RAxML: `ERROR: Alignment file does not exist` | Wrong path | Use absolute path with `-w $(pwd)/...` |
| Bootstrap values all 0 or 100 | Very short/identical sequences | Check alignment quality |
| Tree has polytomies (star topology) | Sequences too divergent or too similar | Check if sequences are appropriate for comparison |
| Long runtime | Large alignment | Use `--fast` in IQ-TREE or reduce sequences |

---

## 📚 Further Reading

- [IQ-TREE Tutorial](http://www.iqtree.org/doc/Tutorial)
- [MAFFT Manual](https://mafft.cbrc.jp/alignment/software/manual/manual.html)
- [Phylogenetics — a practical introduction (Baum & Smith)](https://www.sinauer.com/tree-thinking.html)
- [iTOL Documentation](https://itol.embl.de/help.cgi)

---

*← Back to [Day 2 Main README](../../README.md)*
