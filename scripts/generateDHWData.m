num_sims = 50;
num_sites = 244;

RCP = "60";
ai = ADRIA();
sim_constants = ai.constants;
sim_constants.RCP = RCP;


filename = strcat('Inputs/example_wave_DHWs_RCP_expanded_', RCP, '.nc');
generateWaveDHWs(num_sims, params, num_sites, filename)