#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
##SBATCH --mem=5750
##SBATCH --mem=11500
#SBATCH --mem=23000
#SBATCH --open-mode=append

# --mem instead of --mem-per-cpu because 
# we are getting 2 cpus allocated on nash/rambler which is doubling the memory
# allocated even though we only use 1 cpu

srun --exclusive ./run-chm.sh $*
