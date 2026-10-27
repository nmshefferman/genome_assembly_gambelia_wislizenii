#!/bin/bash
#SBATCH --job-name=gambelia_fastqc
#SBATCH --cpus-per-task=1
#SBATCH --mem=48g
#SBATCH --time=12:00:00
#SBATCH --output=sbatch_files/gambelia_fastqc_%j.out
#SBATCH --error=sbatch_files/gambelia_fastqc_%j.err
#SBATCH --mail-type=ALL

set -euo pipefail

# Define variables
PROJECT="/data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii"
OUTDIR="${PROJECT}/fastqc_results"

# Activate hifi_env environment
source /data/sheffermannm/conda/etc/profile.d/conda.sh
conda activate hifi_env

mkdir -p "$OUTDIR"

echo "Job started: $(date)"
echo "Running on: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Output directory: $OUTDIR"
echo "FastQC version:"
fastqc --version

# Go to project directory
cd "$PROJECT"

# Allow each fastqc java process to use up to 24 GB of heap memory
## To solve the problem of crashing due to lack of memory
export _JAVA_OPTIONS="-Xmx24g"

# Run fastqc
fastqc \
    --outdir "$OUTDIR" \
    "${PROJECT}"/raw_reads/SRR*.fastq.gz

# Check results
echo
echo "Final files:"
ls -lh "$OUTDIR"

echo
echo "Job finished: $(date)"