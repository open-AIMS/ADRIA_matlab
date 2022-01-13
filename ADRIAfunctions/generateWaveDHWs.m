function generateWaveDHWs(num_sims, params, num_sites, filename)
% Generate wave damage and degree heating week scenarios.
% Saves generated scenarios to file.
% If no filename provided, saves to `waveDHWs_RCP[RCP number]_[datetime].nc`
%
% WARNING: This function produces preliminary datasets only.
%          
% Example:
%     [params, ecol_params] = ADRIAparms();
%
%     % Generate 50 sims for 26 sites
%     generateWaveDHWs(50, params, 26, 'Inputs/example_wave_DHWs_RCP60.nc')

    %% setup for the geographical setting including environmental input layers
    [wave_scen, dhw_scen] = setupADRIAsims(num_sims, params, num_sites);
    
    if ~exist('filename', 'var')
        right_now = datetime(now, 'ConvertFrom', 'datenum');
        right_now = replace(string(right_now), ' ', '_');
        right_now = replace(right_now, ':', '');
        
        filename = strcat('waveDHWs_RCP', string(params.RCP), '_', right_now, '.nc');
        
        fprintf('File name not provided. Saving results to %s \n', filename)
    end
    
    if ~endsWith(filename, ".nc")
        filename = strcat(filename, ".nc");
    end
    
    nccreate(filename, "wave", 'Dimensions', ...
             {'timesteps', params.tf, 'sites', num_sites, 'sims', num_sims});
    nccreate(filename, "DHW", 'Dimensions', ...
             {'timesteps', params.tf, 'sites', num_sites, 'sims', num_sims});
    
    ncwrite(filename, "wave", wave_scen)
    ncwrite(filename, "DHW", dhw_scen)
end