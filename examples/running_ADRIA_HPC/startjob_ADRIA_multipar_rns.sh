#!/bin/bash

for RCP in 26 45 60 85
do 
	for PrSites in 1 2 3
	do
		for ((Seed1=0; Seed1<0.001; Seed1+0.0002))
		do
			for ((Seed2=0; Seed2<0.001; Seed2+0.0002))
			do
				for ((SRM=0; SRM<8; SRM++))
				do
					for ((Aadpt=0; Aadpt<8; Aadpt++))
					do
						for ((Natad=0; Natad<0.1; Natad+0.02))
							export RCP
							export PrSites
							export Seed1
							export Seed2
							export SRM
							export Aadpt
							export Natad
							sh /export/home/q-z/rcrocker/examples/runfile_ADRIA_optimisation.sh
					done
				done
			done
		done
	done
done
