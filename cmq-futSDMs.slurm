#! /bin/bash
#SBATCH --job-name=pred_futSDMs
#SBATCH --ntasks=1 --cpus-per-task=10 --mem-per-cpu=7000mb
#SBATCH --time=16:35:00

source $VSC_HOME/.bashrc

conda activate VoCC_R_new

cd $VSC_DATA/sdm_targets/
export OMP_NUM_THREADS=1

Rscript targets_run_cmq.R
