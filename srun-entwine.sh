#!/bin/bash
#SBATCH --mem=46000
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1

srun --exclusive entwine build -i ept-scan/ept-scan.json -o ept --subset $1 16

