%% ADRIA runs with identical setting to IPMF

n_reps = 50;  % Number of replicate RCP scenarios
ai = ADRIA();

%% Parameter prep
% Collect details of available parameters
param_defaults = ai.raw_defaults;
sim_constants = ai.criterias;

% Get the coral parameters, which are not modified for this example
[~, ~, coral_params] = ai.splitParameterTable(param_defaults);

%% Load site specific data
ai.loadConnectivity('./Inputs/Moore/connectivity/2015');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv',...
    ["Acropora2026", "Goniastrea2026"]);

%% counterfactual - no seeding no shading
param_defaults.Seed1 = 0;
param_defaults.Seed2 = 0;

Y_count = ai.run(param_defaults,sampled_values = false,nreps = n_reps);