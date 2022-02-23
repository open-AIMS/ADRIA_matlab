#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l ncpus=12
#PBS -M R.Crocker@aims.gov.au
#PBS -m bae
#PBS -e error_ADRIA_opt.log
#PBS -S /bin/bash

echo $Guided
echo $alg_ind
echo $RCP
echo $Seed1
#echo $Seed2
#echo $SRM
#echo $Aadpt
#echo $Natad
echo $Count

module load MATLAB/R2019a

cd $PBS_O_WORKDIR

matlab -nodisplay -r "ADRIAsetup" 
matlab -nodisplay -r "example_runs_BBN_data_HPC" > ADRIA_multipar_output_job"$Count".log
