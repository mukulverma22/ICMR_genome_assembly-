# 🔧 Troubleshooting Guide

> Can't figure out what went wrong? You're in the right place.

---

## General Debugging Tips

1. **Always read the error message** — it usually tells you exactly what's wrong
2. **Check that your input files exist:** `ls -lh *.fastq.gz`
3. **Check you have enough disk space:** `df -h .`
4. **Check you have enough RAM:** `free -h`
5. **Look at the log file** — most tools write a `.log` file

---

## FastQC

| Error | Fix |
|-------|-----|
| `java.lang.OutOfMemoryError` | Run `fastqc --memory 4096 ...` |
| `Skipping ... not a valid BAM/SAM file` | Make sure input is FASTQ not BAM |
| Empty HTML report | File may be corrupted; re-download reads |

---

## Fastp

| Error | Fix |
|-------|-----|
| `[error] failed to open ...` | Check file paths with `ls` |
| Output has <50% reads | Lower `--qualified_quality_phred` to 15 |
| Adapter not detected | Add `--adapter_sequence AGATCGGAAGAGC` manually |

---

## SPAdes

| Error | Fix |
|-------|-----|
| `== Error ==  system call failed` | Out of memory; increase `--memory` or reduce reads |
| Very long runtime | Normal for large genomes; use `--careful` only for small genomes |
| `scaffolds.fasta` is empty | Assembly failed; check `spades.log` |
| All contigs < 500 bp | Low coverage; check with `cat fastp_report.json | grep total_reads` |

---

## BUSCO

| Error | Fix |
|-------|-----|
| `Database not found` | First run; wait for auto-download or use `--offline` with cached db |
| Very low BUSCO score for virus | Normal! Viruses aren't in standard BUSCO databases |
| `augustus not found` | Install: `conda install -c bioconda augustus` |

---

## RagTag

| Error | Fix |
|-------|-----|
| `No valid alignments` | Query and reference may be too different species |
| All contigs unplaced | Check reference matches your organism |
| `minimap2 not found` | Install: `conda install -c bioconda minimap2` |

---

## Getting More Help

1. Check the tool's official documentation (links in each session README)
2. Search [Bioinformatics Stack Exchange](https://bioinformatics.stackexchange.com/)
3. Open an issue on this repository with the error message
