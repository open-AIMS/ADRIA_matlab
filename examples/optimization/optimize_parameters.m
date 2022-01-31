% Example script showcasing how to optimize known ADRIA parameters for a
% specified objective function.

alg = 1; % Use Order Ranking

% get shell variables
prsites = 2; % PrSites
rcp = 60; % RCP

out_name = 'TC'; % optimize Total coral Cover

% Use default criteria weights
criteria_opts = criteriaDetails();
CrtWts = cell2mat(criteria_opts.defaults)';

% Perturb all available parameters
i_params = interventionDetails();
criteria_weights = criteriaDetails();
all_params = [i_params; criteria_weights];

% Get names of parameters (used for later display)
p_names = all_params.name;

% Initialise parameters (use the lower bounds to start with)
x0 = cell2mat(all_params.lower_bound);

% Upper/Lower bounds of x
lb = cell2mat(all_params.lower_bound);
ub = cell2mat(all_params.upper_bound);

[params, ecol_parms] = ADRIAparms();
params.RCP = rcp; % set target RCP scenario

[TP_data, site_ranks, strongpred] = siteConnectivity('Inputs/MooreTPmean.xlsx', 0.1);
nsites = 26;

% Wave/DHW scenarios
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(rcp), ".nc");
wave_scen = ncread(fn, "wave");
dhw_scen = ncread(fn, "DHW");

% Objective function for simulated annealing function is negative (as
% solves the minimisation) and must have a single vector input and scalar
% output
ObjectiveFunction = @(x) -1 * allParamObjectiveFunc(x, alg, out_name, ...
    all_params, ...
    nsites, wave_scen, ...
    dhw_scen, params, ...
    ecol_parms, ...
    TP_data, site_ranks, strongpred);

% Begin optimisation (only run for 30 seconds)
obj_opts = optimoptions('simulannealbnd', 'MaxTime', 30);
x = simulannealbnd(ObjectiveFunction, x0, lb, ub, obj_opts);

% label file with key parameters
filename = sprintf('ADRIA_opt_out_RCP%2.0f_PrSites%1.0d_Alg%1.0d.csv', rcp, prsites, alg);

% Save as CSV
saveData(x, filename)