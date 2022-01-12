#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l ncpus=12
#PBS -M r.crocker@aims.gov.au
#PBS -m bae
#PBS -e error_ADRIA_opt.log
#PBS -S /bin/bash

echo $RCP
echo $Seed1
echo $Seed2
echo $SRM
echo $Aadpt
echo $Natad

module load MATLAB/R2019a

cd $PBS_O_WORKDIR

matlab -nodisplay -r "ADRIASetup" 
matlab -nodisplay -r "example_runs_BBN_data_HPC" > ADRIA_multipar_output_RCP"$RCP"_Seed1"$Seed1"_Seed2"$Seed2"_SRM"$SRM"_Aadpt"$Aadpt"_Natad"$Natad".log