# 📖 Glossary — Genome Assembly Key Terms

> A quick reference for all the jargon you'll encounter today.

---

## Sequencing & Reads

| Term | Definition |
|------|------------|
| **Read** | A short DNA sequence (~150–300 bp) produced by a sequencer. Think of it as one tiny piece of the genome puzzle. |
| **Paired-end reads** | Two reads (R1 and R2) sequenced from both ends of the same DNA fragment. Gives assembly software distance information. |
| **Coverage / Depth** | How many times each base in the genome is covered by reads. 30x coverage = each base has ~30 reads on average. More coverage = more accurate assembly. |
| **FASTQ** | File format storing reads + quality scores. 4 lines per read: name, sequence, separator (+), quality. |
| **Phred score** | A quality score for each base call. Q30 = 99.9% accuracy. Higher is better. |
| **Adapter** | Synthetic DNA sequence added during library preparation. Must be removed before assembly. |

---

## Assembly Concepts

| Term | Definition |
|------|------------|
| **Contig** | A **cont**iguous assembled sequence with no gaps. Produced directly by the assembler. |
| **Scaffold** | Contigs connected in order using paired-end distance information, with gaps represented as Ns. More complete than contigs. |
| **k-mer** | A substring of length k from a sequence. ATCG is a 4-mer. Used by De Bruijn graph assemblers. |
| **De Bruijn Graph** | A graph where nodes are k-mers and edges connect overlapping k-mers. Genome assembly = finding a path through this graph. |
| **Assembly graph** | A visual representation of how contigs are connected. Useful for identifying repeats and structural variants. |
| **Misassembly** | When the assembler incorrectly joins sequences that don't belong together in the real genome. |
| **Chimeric contig** | A contig containing sequences from two different genomic regions incorrectly merged together. |

---

## Quality Metrics

| Term | Definition |
|------|------------|
| **N50** | The length L where 50% of the total assembly is in contigs ≥ L. Higher = better. The gold standard assembly metric. |
| **L50** | The number of contigs needed to reach 50% of the assembly length. Lower = better. |
| **NG50** | Like N50, but uses the **reference genome size** instead of total assembly length. More meaningful for comparison. |
| **Genome fraction** | Percentage of the reference genome covered by your assembly. Higher = more complete. |
| **BUSCO score** | Percentage of expected universal genes found in your assembly. >90% = good completeness. |
| **GC content** | Percentage of bases that are G or C. Should match the expected value for your organism. |

---

## Tools Glossary

| Tool | Full Name | What it does |
|------|-----------|--------------|
| **FastQC** | Fast Quality Control | Generates QC plots from FASTQ files |
| **Fastp** | Fast Preprocessing | Trims adapters and low-quality bases |
| **MultiQC** | Multi-sample QC | Aggregates QC reports into one dashboard |
| **SPAdes** | St. Petersburg Assembler | De Bruijn graph genome assembler |
| **Setu** | — | Viral genome assembly pipeline |
| **QUAST** | Quality Assessment Tool | Measures assembly contiguity and accuracy |
| **BUSCO** | Benchmarking Universal Single-Copy Orthologs | Measures genome completeness |
| **RagTag** | — | Reference-guided contig scaffolding |

---

## File Formats

| Extension | Format | Used by |
|-----------|--------|---------|
| `.fastq` / `.fq` | Raw sequencing reads + quality | FastQC, Fastp, SPAdes |
| `.fastq.gz` | Compressed FASTQ | All tools (compressed saves ~75% disk space) |
| `.fasta` / `.fa` | DNA/protein sequences (no quality) | QUAST, BUSCO, RagTag |
| `.gfa` | Graphical Fragment Assembly | Assembly graph format |
| `.vcf` | Variant Call Format | Stores genetic variants |
| `.agp` | A Golden Path | Scaffold coordinate format |
| `.html` | Web page | All report outputs |
| `.tsv` / `.txt` | Tab/text delimited | Summary statistics |

---

## Common Abbreviations

| Abbreviation | Meaning |
|-------------|---------|
| bp | Base pairs |
| kb | Kilobases (1,000 bp) |
| Mb | Megabases (1,000,000 bp) |
| Gb | Gigabases (1,000,000,000 bp) |
| QC | Quality Control |
| SRA | Sequence Read Archive (NCBI database) |
| WGS | Whole Genome Sequencing |
| R1 / R2 | Read 1 / Read 2 (paired-end) |
| OLC | Overlap-Layout-Consensus (assembly method) |
| DBG | De Bruijn Graph (assembly method) |
