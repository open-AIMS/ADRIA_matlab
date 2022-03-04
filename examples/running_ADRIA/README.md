# Contents of example folder

`single_scenario` shows an example of how a user of ADRIA can run a 
specific single scenario, inputting values into dialog boxes.

`sampled_runs` showcases how multiple runs can be constructed, sampling 
(with monte carlo) from the parameter bounds as defined by ADRIA.

`batch_runs` shows how to set up ADRIA to do multiple runs as with 
`sampled_runs`, except it writes the results to netCDF files instead of 
storing everything in memory. This allows a laptop/desktop to do many runs 
which would otherwise crash due to an "out-of-memory" error.

`programmatic_scenarios` indicates how to do single or multiple runs with 
*specific parameter values*.

'example_using_priority_sites` shows how to change the priority sites variable in ADRIA to prioritise key site/reef sources for a subset of reefs or sites.

`example_runs_data_HPC` shows how to retrieve shell variables to run ADRIA over a range of parameters using a HPC.

The end goal with these is to allow a relatively informed user to be able 
to cobble together a new script by taking snippets from one, some, or all 
of the above examples (with some reference to the user manual) to conduct 
new runs/analyses with ADRIA.
