%% Script showcasing how to define and run a single scenario.

rng(101) % set seed for reproducibility

%% 1. Collate parameter details

% Collect details of parameters that can be varied
inter_opts = interventionDetails();
criteria_opts = criteriaDetails();

% Collect parameters that are treated as constants (for now)
coral_params = coralDetails();
sim_constants = simConstants();

% Create a single table of all parameters that can be perturbed
combined_opts = [inter_opts; criteria_opts];

%% 2. Build a parameter table using default values
% Extract the default values directly from the parameter tables
% Parameter definitions hold defaults for `sample` and `raw` values.
% Here we use `raw` values as the `sample` columns are only intended for 
% use with samplers and `convertScenarioSelection()`.
name_values = combined_opts(:, {'name', 'raw_defaults'});
names = name_values.name;
default_values = name_values.raw_defaults;

% Final list of name->value 
param_table = cell2table(default_values', 'VariableNames', cellstr(names));

% Resulting table consists of 1 row and `P` columns, where `P` is the 
% number of parameters, and "1" relates to the scenario (we only want 1).

%% 3. Modify table as desired...
param_table(1, 'Guided') = {1};
param_table(1, 'Seed1') = {15000};
param_table(1, 'Seed2') = {50000};

%% 4. Separate into components
% Separate parameters for the components
% (to be replaced with a better way of separating these...)
%
% `runADRIAScenario()` currently expects parameter tables/structs as its
% first four inputs.
% This could be replaced with a single input table holding all parameter
% values. The main consideration against this currently is that the 
% number of parameters, and their location in the table is not yet
% finalized. Extracting parameters by name is possible, but would incur
% a slight runtime cost.
interv_vals = param_table(:, 1:9);
criteria_vals = param_table(:, 10:end);

%% Prep other inputs

% Load site data
[TP_data, site_ranks, strongpred] = siteConnectivity('MooreTPmean.xlsx', sim_constants.con_cutoff);

% Load wave/DHW scenario data
% Generated with generateWaveDHWs.m
% TODO: Replace these with wave/DHW projection scenarios instead
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(sim_constants.RCP), ".nc");
wave_scens = ncread(fn, "wave");
dhw_scens = ncread(fn, "DHW");

% Select random subset of RCP conditions WITHOUT replacement
n_rep_scens = length(wave_scens);
rcp_scens = datasample(1:n_rep_scens, 1, 'Replace', false);
w_scens = wave_scens(:, :, rcp_scens);
d_scens = dhw_scens(:, :, rcp_scens);


%% Run ADRIA
alg_ind = 1;  % MCDA algorithm choice

% Run a single simulation
Y = coralScenario(interv_vals, criteria_vals, coral_params, sim_constants, ...
                  TP_data, site_ranks, strongpred, ...
                  w_scens, d_scens, alg_ind);