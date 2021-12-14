num_sims = 50;
num_sites = 26;
[params, ecol_params] = ADRIAparms();
params.RCP = 85;

filename = strcat('Inputs/example_wave_DHWs_RCP', num2str(params.RCP), '.nc');
generateWaveDHWs(num_sims, params, num_sites, filename)