#!/bin/bash

for RCP in 26 45 60 85
do 
	for PrSites in 1 2 3
	do
		export RCP
		export PrSites
		sh /export/home/q-z/rcrocker/examples/runfile_ADRIA_optimisation.sh
	done
done	
