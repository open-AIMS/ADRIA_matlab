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

The end goal with these is to allow a relatively informed user to be able 
to cobble together a new script by taking snippets from one, some, or all 
of the above examples (perhaps referring back to the manual a little bit) 
to conduct new runs/analyses with ADRIA.