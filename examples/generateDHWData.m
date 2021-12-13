num_sims = 50;
num_sites = 26;
[params, ecol_params] = ADRIAparms();
params.RCP = 26;
filename = 'Inputs/example_wave_DHWs_RCP26.nc';
generateWaveDHWs(num_sims, params, num_sites, filename)