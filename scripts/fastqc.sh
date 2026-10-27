#!/bin/bash
#SBATCH --job-name=gambelia_fastqc
#SBATCH --cpus-per-task=1
#SBATCH --mem=48g
#SBATCH --time=12:00:00
#SBATCH --output=sbatch_files/gambelia_fastqc_%j.out
#SBATCH --error=sbatch_files/gambelia_fastqc_%j.err
#SBATCH --mail-type=ALL

# Go to Gambelia directory
cd /data/Wilson_Lab/projects/Group_Genome_Assembly/Gambelia_wislizenii

# Activate hifi_env environment
source /data/sheffermannm/conda/etc/profile.d/conda.sh
conda activate hifi_env

# Make directory for fastqc results
mkdir -p fastqc_results

# Allow each fastqc java process to use up to 24 GB of heap memory
## To solve the problem of crashing due to lack of memory
export _JAVA_OPTIONS="-Xmx24g"

# Run fastqc
fastqc \
    --outdir fastqc_results \
    raw_reads/SRR29647188_R1.fastq.gz \
    raw_reads/SRR29647188_R2.fastq.gz \
    raw_reads/SRR29647189_R1.fastq.gz \
    raw_reads/SRR29647189_R2.fastq.gz \
    raw_reads/SRR29647190.fastq.gz



    

