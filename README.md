# *Gambelia wislizenii* Genome Assembly

This repository documents the genome assembly workflow for *Gambelia wislizenii* (long-nosed leopard lizard) using:

- PacBio HiFi long reads for de novo genome assembly
- Dovetail Omni-C paired-end reads for scaffolding
- NIH Biowulf for data storage and analysis
- GitHub for scripts and documentation

> **Note:** Raw sequencing data and other large analysis files are stored on Biowulf and are not committed to this repository.

Analyses are performed on the NIH Biowulf computing cluster.

This project uses publicly available sequencing data generated as part of the Vertebrate Genomes Project (VGP) and associated California conservation genetics work.

## Project information

**Species:** *Gambelia wislizenii*  
**Common name:** Long-nosed leopard lizard  
**NCBI Taxonomy ID:** 43593  
**BioProject:** [PRJNA1126708](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1126708)  
**GitHub repository:** [genome_assembly_gambelia_wislizenii](https://github.com/nmshefferman/genome_assembly_gambelia_wislizenii)

Project directory:

```text
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/
```

## Project workflow

The overall genome assembly workflow includes:

1. Retrieve publicly available sequencing data
2. Perform quality control of PacBio HiFi and Omni-C reads
3. Estimate genome size and heterozygosity from k-mer distributions
4. Assemble PacBio HiFi long reads
5. Evaluate the initial genome assembly
6. Scaffold the assembly using Dovetail Omni-C data
7. Evaluate the scaffolded assembly
8. Document software, parameters, and outputs for each stage

---

## Sequencing data

Sequencing data were identified through the NCBI BioProject and Sequence Read Archive (SRA).

Three SRA runs are used for this project:

| SRA run | Sequencing data | Download size | Bases | Purpose |
|---|---|---:|---:|---|
| SRR29647190 | PacBio HiFi | 59.6 GB | 101.2 Gb | De novo genome assembly |
| SRR29647188 | Dovetail Omni-C | 20.1 GB | 60.9 Gb | Genome scaffolding |
| SRR29647189 | Dovetail Omni-C | 29.4 GB | 89.0 Gb | Genome scaffolding |

The two Dovetail Omni-C runs represent the same library and sample and are combined for downstream scaffolding.

---

## Downloading the sequencing data

Raw sequencing reads were downloaded from the NCBI Sequence Read Archive.

The download was performed on Biowulf using the script:

```text
download_read_data.sh
```

The script is included in this repository and is also located on Biowulf at:

```text
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/download_read_data.sh
```

Because downloading and processing the sequencing data takes several hours, the download was submitted as a Slurm job:

```bash
sbatch download_read_data.sh
```

The download job ran on October 8, 2026:

```text
Start:    14:52:06
Finish:   21:26:52
Runtime:  06:34:46
```

Raw reads are stored on Biowulf at:

```text
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/raw_reads/
```

### Downloaded FASTQ files

The resulting compressed FASTQ files are:

```text
SRR29647188_R1.fastq.gz
SRR29647188_R2.fastq.gz
SRR29647189_R1.fastq.gz
SRR29647189_R2.fastq.gz
SRR29647190.fastq.gz
```

Approximate compressed file sizes:

| File | Size |
|---|---:|
| SRR29647188_R1.fastq.gz | 16 GB |
| SRR29647188_R2.fastq.gz | 16 GB |
| SRR29647189_R1.fastq.gz | 23 GB |
| SRR29647189_R2.fastq.gz | 24 GB |
| SRR29647190.fastq.gz | 70 GB |

---

## Read-count validation

After downloading the sequencing data, the FASTQ files were checked to confirm that they existed and contained the expected number of reads.

Read counts were calculated from the number of lines in each FASTQ file:

```bash
for f in raw_reads/*.fastq.gz; do
    echo -n "$(basename "$f"): "
    echo $(( $(zcat "$f" | wc -l) / 4 ))
done
```

### Omni-C read counts

| SRA run | R1 reads | R2 reads |
|---|---:|---:|
| SRR29647188 | 201,515,272 | 201,515,272 |
| SRR29647189 | 294,852,162 | 294,852,162 |

Total number of Omni-C read pairs across both runs:

```text
496,367,434
```

### PacBio HiFi read count

| SRA run | Reads |
|---|---:|
| SRR29647190 | 7,750,914 |

---

## Combining Dovetail Omni-C runs

`SRR29647188` and `SRR29647189` are two sequencing runs from the same Omni-C library and sample. They were combined so that downstream scaffolding can be performed using a single R1 file and a single R2 file.

Because gzip-compressed FASTQ files can be concatenated directly, the two R1 files were combined with:

```bash
cat \
    SRR29647188_R1.fastq.gz \
    SRR29647189_R1.fastq.gz \
    > Gambelia_combined_R1.fastq.gz
```

The R2 files were combined with:

```bash
cat \
    SRR29647188_R2.fastq.gz \
    SRR29647189_R2.fastq.gz \
    > Gambelia_combined_R2.fastq.gz
```

The resulting files are:

```text
Gambelia_combined_R1.fastq.gz
Gambelia_combined_R2.fastq.gz
```

Each combined FASTQ file contains:

```text
496,367,434 reads
```

The original SRA-specific FASTQ files are retained on Biowulf.

---

## Data summary

| Data | Source | Purpose |
|---|---|---|
| SRR29647190 | NCBI SRA | PacBio HiFi reads for de novo genome assembly |
| SRR29647188 | NCBI SRA | Dovetail Omni-C reads for scaffolding |
| SRR29647189 | NCBI SRA | Dovetail Omni-C reads for scaffolding |

Raw sequencing data and large intermediate/output files are maintained on Biowulf rather than tracked with Git.