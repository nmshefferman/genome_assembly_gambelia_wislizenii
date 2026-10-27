#!/bin/bash
#SBATCH --job-name=gambelia_jellyfish
#SBATCH --cpus-per-task=32
#SBATCH --mem=96g
#SBATCH --time=48:00:00
#SBATCH --gres=lscratch:200
#SBATCH --output=sbatch_files/gambelia_jellyfish_%j.out
#SBATCH --error=sbatch_files/gambelia_jellyfish_%j.err
#SBATCH --mail-type=ALL

set -euo pipefail

# Load modules
module load jellyfish/2.3.1

# Define variables
PROJECT="/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii"
OUTDIR="${PROJECT}/jellyfish_results"
READS="${PROJECT}/raw_reads/SRR29647190.fastq.gz"
THREADS="$SLURM_CPUS_PER_TASK"
KMER=21
WORKDIR="/lscratch/${SLURM_JOB_ID}"     # Need to use lscratch because Jellyfish database is very large

mkdir -p "$OUTDIR"
mkdir -p "$WORKDIR" 

echo "Job started: $(date)"
echo "Node: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Output directory: $OUTDIR"
echo "Scratch directory: $WORKDIR"
echo "Threads: $THREADS"
echo "Input: $READS"
echo "k-mer size: $KMER"
echo "Jellyfish version:"
jellyfish --version 

# Go to project directory
cd "$PROJECT"

# Verify input FASTQ exists
if [[ ! -f "$READS" ]]; then
    echo "ERROR: FASTQ not found: $READS" >&2
    exit 1
fi

# Create generator file because Jellyfish cannot directly read .gz
GENERATOR_FILE="${WORKDIR}/generator.txt"
printf 'zcat %q\n' "$READS" > "$GENERATOR_FILE"
echo "Generator command:"
cat "$GENERATOR_FILE"

# Count 21-mers
echo "Starting k-mer counting: $(date)"
jellyfish count \
    -C \
    -m "$KMER" \
    -s 1000000000 \
    -t "$THREADS" \
    --generator="$GENERATOR_FILE" \
    --Generators=4 \
    -o "${WORKDIR}/gambelia_hifi_k21.jf"
echo "K-mer counting finished: $(date)"

# Generate histogram
echo "Generating histogram: $(date)"
jellyfish histo \
    -t "$THREADS" \
    -h 1000000 \
    "${WORKDIR}/gambelia_hifi_k21.jf" \
    > "${OUTDIR}/gambelia_hifi_k21.histo"
echo "Histogram finished: $(date)"

# Check results
echo
echo "Histogram:"
ls -lh "${OUTDIR}/gambelia_hifi_k21.histo"

echo
echo "First 20 histogram rows:"
head -20 "${OUTDIR}/gambelia_hifi_k21.histo"

echo
echo "Job finished: $(date)"