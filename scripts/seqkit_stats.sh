#!/bin/bash
#SBATCH --job-name=gambelia_seqkit
#SBATCH --cpus-per-task=2
#SBATCH --mem=8g
#SBATCH --time=4:00:00
#SBATCH --output=sbatch_files/gambelia_seqkit_%j.out
#SBATCH --error=sbatch_files/gambelia_seqkit_%j.err
#SBATCH --mail-type=ALL

# Go to Gambelia directory
cd /data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii

# Activate hifi_env environment
source /data/sheffermannm/conda/etc/profile.d/conda.sh
conda activate hifi_env

# Run seqkit stats and combine results for each file in one output table
seqkit stats -a \
    raw_reads/SRR29647188_R1.fastq.gz \
    raw_reads/SRR29647188_R2.fastq.gz \
    raw_reads/SRR29647189_R1.fastq.gz \
    raw_reads/SRR29647189_R2.fastq.gz \
    raw_reads/SRR29647190.fastq.gz \
    > seqkit_stats.txt