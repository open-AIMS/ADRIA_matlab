#!/bin/bash
#PBS -l walltime=48:00:00
#PBS -l ncpus=12
#PBS -M r.crocker@aims.gov.au
#PBS -m bae
#PBS -e error_ADRIA_opt.log
#PBS -S /bin/bash

echo $RCP
echo $PrSites

module load MATLAB/R2019a

cd $PBS_O_WORKDIR

matlab -nodisplay -r "ADRIASetup" 
matlab -nodisplay -r "run_ADRIA_opt_hpc" > ADRIA_opt_output_RCP"$RCP"_PrSites"$PrSites".log
