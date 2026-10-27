#!/bin/bash
#SBATCH --job-name=gambelia_seqkit
#SBATCH --cpus-per-task=2
#SBATCH --mem=8g
#SBATCH --time=04:00:00
#SBATCH --output=sbatch_files/gambelia_seqkit_%j.out
#SBATCH --error=sbatch_files/gambelia_seqkit_%j.err
#SBATCH --mail-type=ALL

set -euo pipefail

# Define variables
PROJECT="/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii"
OUTDIR="${PROJECT}/seqkit_results"

# Activate hifi_env environment
source /data/sheffermannm/conda/etc/profile.d/conda.sh
conda activate hifi_env

mkdir -p "$OUTDIR"

echo "Job started: $(date)"
echo "Running on: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Output directory: $OUTDIR"
echo "Seqkit version:"
seqkit --version

# Go to project directory
cd "$PROJECT"

# Run seqkit stats and combine results for each file in one output table
seqkit stats -a \
    -j "$SLURM_CPUS_PER_TASK" \
    "${PROJECT}"/raw_reads/SRR*.fastq.gz \
    > "${OUTDIR}/seqkit_stats.txt"

# Check results
echo
echo "SeqKit statistics:"
cat "${OUTDIR}/seqkit_stats.txt"

echo
echo "Job finished: $(date)"