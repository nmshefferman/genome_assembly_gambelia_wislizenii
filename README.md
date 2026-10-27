# *Gambelia wislizenii* Genome Assembly

This repository documents the genome assembly workflow for *Gambelia wislizenii* (long-nosed leopard lizard) using:

- PacBio HiFi long reads for de novo genome assembly
- Dovetail Omni-C paired-end reads for scaffolding
- NIH Biowulf for data storage and analysis
- GitHub for scripts and documentation

> **Note:** Raw sequencing data and other large analysis files are stored on Biowulf and are not committed to this repository.

Analyses are performed on the NIH Biowulf computing cluster.

This project uses publicly available sequencing data generated as part of the Vertebrate Genomes Project (VGP) and associated California conservation genetics work.

---

## Project information

**Species:** *Gambelia wislizenii*  
**Common name:** Long-nosed leopard lizard  
**NCBI Taxonomy ID:** 43593  
**BioProject:** [PRJNA1126708](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1126708)

Project directory on Biowulf:

```text id="5rwtzx"
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/
```

---

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

## Repository structure

Analysis scripts are maintained in the `scripts/` directory. Raw sequencing data and large analysis outputs are stored on NIH Biowulf and are not tracked with Git.

```text id="54mkbl"
Gambelia_wislizenii/
├── README.md
├── .gitignore
├── scripts/
│   ├── download_read_data.sh
│   ├── fastqc.sh
│   ├── seqkit_stats.sh
│   └── jellyfish.sh
├── raw_reads/
├── fastqc_results/
├── multiqc_results/
├── jellyfish_results/
├── sbatch_files/
└── seqkit_stats.txt
```

The `scripts/` directory is tracked in this repository. Large sequencing files and intermediate analysis outputs remain on Biowulf.

---

## Software environment

A custom Conda environment is used to manage software required for read quality control, genome characterization, HiFi genome assembly, assembly manipulation, and assembly quality assessment.

The environment was created on NIH Biowulf using Miniforge/Mamba.

**Environment name:** `hifi_env`

### Setting up Mamba on Biowulf

Mamba/Miniforge can be installed on Biowulf using:

```bash id="fj5v1e"
mamba_install
```

For this project, Miniforge is installed in:

```text id="4v2hzw"
/data/sheffermannm/conda
```

If `mamba_install` reports that this directory already exists, Miniforge has already been installed and does not need to be reinstalled.

The Conda installation can be loaded with:

```bash id="e4kwxa"
source /data/sheffermannm/conda/etc/profile.d/conda.sh
```

The initial environment setup used:

```text id="y9e9qr"
Conda 26.1.1
Mamba 2.5.0
```

### Creating the environment

The `hifi_env` environment can be created with:

```bash id="7bmhrz"
mamba create -n hifi_env \
    -c conda-forge \
    -c bioconda \
    hifiasm \
    fastqc \
    multiqc \
    gfatools \
    assembly-stats \
    seqkit \
    seqtk \
    tidk \
    samtools \
    bamtools \
    compleasm \
    ncbi-datasets-cli \
    snakemake
```

In subsequent Biowulf sessions, activate the environment with:

```bash id="l99egx"
source /data/sheffermannm/conda/etc/profile.d/conda.sh
conda activate hifi_env
```

### Software

| Software | Purpose |
|---|---|
| `hifiasm` | PacBio HiFi genome assembly |
| `fastqc` | Read quality control |
| `multiqc` | Aggregate QC reports |
| `gfatools` | Manipulate and inspect GFA assembly graphs |
| `assembly-stats` | Calculate genome assembly statistics |
| `seqkit` | FASTA/FASTQ manipulation and statistics |
| `seqtk` | FASTA/FASTQ sequence processing |
| `tidk` | Telomere identification and analysis |
| `samtools` | SAM/BAM/CRAM manipulation |
| `bamtools` | BAM file manipulation and statistics |
| `compleasm` | Genome assembly completeness assessment |
| `ncbi-datasets-cli` | Access NCBI Datasets from the command line |
| `snakemake` | Workflow management and automation for reproducible bioinformatics pipelines |

Jellyfish is run using the Biowulf module rather than the Conda environment:

```bash id="0ep0fr"
module load jellyfish/2.3.1
```

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

The download was performed on Biowulf using [`scripts/download_read_data.sh`](scripts/download_read_data.sh).

Because downloading and processing the sequencing data takes several hours, the script was submitted as a Slurm batch job:

```bash
sbatch scripts/download_read_data.sh
```

Raw reads are stored on Biowulf at:

```text id="3i1etf"
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/raw_reads/
```

### Downloaded FASTQ files

The resulting compressed FASTQ files are:

```text id="dhq3i1"
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

```bash id="3exx73"
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

```text id="gw0ig3"
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

```bash id="bvsuqk"
cat \
    raw_reads/SRR29647188_R1.fastq.gz \
    raw_reads/SRR29647189_R1.fastq.gz \
    > raw_reads/Gambelia_combined_R1.fastq.gz
```

The R2 files were combined with:

```bash id="shs7ue"
cat \
    raw_reads/SRR29647188_R2.fastq.gz \
    raw_reads/SRR29647189_R2.fastq.gz \
    > raw_reads/Gambelia_combined_R2.fastq.gz
```

The resulting files are:

```text id="m4q3qy"
Gambelia_combined_R1.fastq.gz
Gambelia_combined_R2.fastq.gz
```

Each combined FASTQ file contains:

```text id="mspc51"
496,367,434 reads
```

The original SRA-specific FASTQ files are retained on Biowulf.

---

## Read quality control

Quality control was performed on the five original FASTQ files prior to downstream analysis:

```text id="cd2v70"
SRR29647188_R1.fastq.gz
SRR29647188_R2.fastq.gz
SRR29647189_R1.fastq.gz
SRR29647189_R2.fastq.gz
SRR29647190.fastq.gz
```

The four `SRR29647188` and `SRR29647189` files contain paired-end Dovetail Omni-C reads, while `SRR29647190` contains PacBio HiFi reads.

### FastQC

Read quality was evaluated using FastQC.

Because of the size of the sequencing datasets, FastQC was run as a Slurm batch job using [`scripts/fastqc.sh`](scripts/fastqc.sh):

```bash id="o5a54n"
sbatch scripts/fastqc.sh
```

FastQC results are stored on Biowulf at:

```text id="00uy02"
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/fastqc_results/
```

FastQC was used to evaluate metrics including:

- per-base sequence quality
- per-sequence quality scores
- per-base sequence content
- per-sequence GC content
- per-base N content
- sequence length distribution
- sequence duplication levels
- overrepresented sequences
- adapter content

### MultiQC

FastQC results from all five FASTQ files were summarized using MultiQC:

```bash id="12rh2p"
multiqc fastqc_results/ -o multiqc_results/
```

The resulting MultiQC report is stored on Biowulf at:

```text id="9a8z0q"
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/multiqc_results/
```

Overall, the four Omni-C FASTQ files showed generally high sequence quality and passed most FastQC checks.

The PacBio HiFi reads also showed high sequence quality but received FastQC flags for per-sequence GC content, sequence length distribution, and adapter content. The variable sequence-length distribution is expected for long-read sequencing and does not by itself indicate poor read quality. The GC-content and adapter-content results require interpretation in the context of PacBio HiFi sequencing.

---

## Sequence statistics

Additional read statistics were calculated using SeqKit.

The analysis was run on Biowulf using [`scripts/seqkit_stats.sh`](scripts/seqkit_stats.sh):

```bash id="bx76pl"
sbatch scripts/seqkit_stats.sh
```

Statistics were calculated for all five original FASTQ files using `seqkit stats`.

Results are stored at:

```text id="ldw5pi"
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/seqkit_stats.txt
```

### SeqKit summary

| Dataset | Type | Reads | Total bases | Avg read length | N50 | Q20 | Q30 |
|---|---|---:|---:|---:|---:|---:|---:|
| SRR29647188 R1 | Omni-C | 201,515,272 | 30.43 Gb | 151 bp | 151 bp | 95.35% | 89.36% |
| SRR29647188 R2 | Omni-C | 201,515,272 | 30.43 Gb | 151 bp | 151 bp | 94.07% | 86.41% |
| SRR29647189 R1 | Omni-C | 294,852,162 | 44.52 Gb | 151 bp | 151 bp | 95.38% | 89.42% |
| SRR29647189 R2 | Omni-C | 294,852,162 | 44.52 Gb | 151 bp | 151 bp | 94.05% | 86.45% |
| SRR29647190 | PacBio HiFi | 7,750,914 | 101.22 Gb | 13,059.5 bp | 13,378 bp | 98.70% | 97.03% |

The PacBio HiFi dataset contains approximately 101.2 Gb of sequence. Reads have a mean length of approximately 13.1 kb and a read N50 of approximately 13.4 kb. Approximately 97% of bases have a Phred quality score of at least Q30.

---

## K-mer analysis and genome profiling

A 21-mer frequency distribution was generated from the PacBio HiFi reads using Jellyfish for genome characterization with GenomeScope 2.0.

### Jellyfish

The Biowulf installation of Jellyfish 2.3.1 was used:

```bash id="jqvzyj"
module load jellyfish/2.3.1
```

The analysis was run as a Slurm batch job using [`scripts/jellyfish.sh`](scripts/jellyfish.sh):

```bash id="8omxgs"
sbatch scripts/jellyfish.sh
```

Canonical 21-mers were counted from the PacBio HiFi reads. Canonical counting treats a k-mer and its reverse complement as the same k-mer.

The resulting Jellyfish database was converted to a k-mer frequency histogram using `jellyfish histo`.

Jellyfish outputs are stored on Biowulf at:

```text id="e6ty00"
/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/jellyfish_results/
```

### GenomeScope

The resulting k-mer histogram was analyzed using [GenomeScope 2.0](http://genomescope.org/genomescope2.0/).

[View the GenomeScope analysis results](http://genomescope.org/genomescope2.0/analysis.php?code=4t20BM7n1gnUtrzA7Bzr).

GenomeScope models the k-mer frequency distribution to estimate genomic characteristics such as genome size, heterozygosity, and repetitive sequence content.

### Genome size estimate

The current GenomeScope analysis estimated a genome size of approximately:

```text id="71bqtv"
2,435,945,215 bp
```

or approximately:

```text id="5r2d7j"
2.44 Gb
```

---

## Estimated PacBio HiFi sequencing coverage

PacBio HiFi sequencing coverage was estimated as:

```text id="vsx49e"
coverage = total HiFi sequence / estimated genome size
```

The PacBio HiFi dataset contains:

```text id="brw1bz"
101,223,029,042 bp
```

Using the GenomeScope genome-size estimate:

```text id="s9xqwo"
2,435,945,215 bp
```

the estimated sequencing coverage is:

```text id="d4od7p"
101,223,029,042 / 2,435,945,215 = 41.55
```

Therefore, the PacBio HiFi dataset provides approximately:

```text 
41.6× coverage
```

of the estimated genome.