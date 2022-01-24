#!/bin/bash

Count = 0

for RCP in 26 45 60 85
do 
	for Guided in 0 1
	do
		for alg_ind in 1 2 3
		do
			for ((Seed1=0; Seed1<1000000; Seed1+200000))
			do
#				for ((Seed2=0; Seed2<1000000; Seed2+200000))
#				do
#					for ((SRM=0; SRM<12; SRM+2))
#					do
#						for ((Aadpt=0; Aadpt<12; Aadpt+2))
#						do
#							for ((Natad=0; Natad<0.1; Natad+0.02))
#							do
		export Guided
	    export alg_ind
		export RCP
		export Seed1
#								export Seed2
#								export SRM
#								export Aadpt
#								export Natad
		echo $RCP
		((Count++))
		export Count
		echo $Count
		qsub /export/home/q-z/rcrocker/ADRIAruns/runfile_ADRIA_multipar_rns.sh
#							done
#						done
#					done
#				done
			done
		done
	done
done
