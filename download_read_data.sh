#!/bin/bash
#SBATCH --job-name=gambelia_download_reads
#SBATCH --cpus-per-task=8
#SBATCH --mem=32g
#SBATCH --gres=lscratch:2000
#SBATCH --time=12:00:00
#SBATCH --output=gambelia_download_reads_%j.out
#SBATCH --error=gambelia_download_reads_%j.err
#SBATCH --mail-type=ALL

set -euo pipefail

module load sratoolkit/3.4.0
module load pigz

OUTDIR="/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii/raw_reads"
TMPDIR="/lscratch/$SLURM_JOBID"

mkdir -p "$OUTDIR"

echo "Job started: $(date)"
echo "Running on: $(hostname)"
echo "Job ID: $SLURM_JOBID"
echo "Output directory: $OUTDIR"
echo "Scratch directory: $TMPDIR"
echo "SRA Toolkit:"
fasterq-dump --version

# Download SRA runs
## Default max size is 20g, need to increase since all 3 files are larger than 20g)
prefetch --max-size 100g -O "$TMPDIR" SRR29647188
prefetch --max-size 100g -O "$TMPDIR" SRR29647189
prefetch --max-size 100g -O "$TMPDIR" SRR29647190

## SRR29647188
fasterq-dump SRR29647188 \
    --split-files \
    --threads "$SLURM_CPUS_PER_TASK" \
    --temp "$TMPDIR" \
    --outdir "$OUTDIR"

## SRR29647189
fasterq-dump SRR29647189 \
    --split-files \
    --threads "$SLURM_CPUS_PER_TASK" \
    --temp "$TMPDIR" \
    --outdir "$OUTDIR"

## SRR29647190
fasterq-dump SRR29647190 \
    --split-files \
    --threads "$SLURM_CPUS_PER_TASK" \
    --temp "$TMPDIR" \
    --outdir "$OUTDIR"

# Compress FASTQ files
pigz -p "$SLURM_CPUS_PER_TASK" \
    "$OUTDIR"/SRR29647188_1.fastq \
    "$OUTDIR"/SRR29647188_2.fastq \
    "$OUTDIR"/SRR29647189_1.fastq \
    "$OUTDIR"/SRR29647189_2.fastq \
    "$OUTDIR"/SRR29647190.fastq

# Rename to R1/R2 convention (only the Omni-C data since it is short read)
mv "$OUTDIR/SRR29647188_1.fastq.gz" "$OUTDIR/SRR29647188_R1.fastq.gz"
mv "$OUTDIR/SRR29647188_2.fastq.gz" "$OUTDIR/SRR29647188_R2.fastq.gz"

mv "$OUTDIR/SRR29647189_1.fastq.gz" "$OUTDIR/SRR29647189_R1.fastq.gz"
mv "$OUTDIR/SRR29647189_2.fastq.gz" "$OUTDIR/SRR29647189_R2.fastq.gz"

echo
echo "Final files:"
ls -lh "$OUTDIR"/SRR296471*.fastq.gz

echo
echo "Job finished: $(date)" 