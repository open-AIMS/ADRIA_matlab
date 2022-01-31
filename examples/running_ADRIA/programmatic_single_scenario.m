%% Script showcasing how to define and run a single scenario.

rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values

% Resulting table consists of N rows and D columns, where N is the
% number of scenarios (here, N=1 of default values), and
% D is the number of parameters.
param_table = ai.raw_defaults;

% See the "Parameter Interface" section in the documentation for
% details on how these two differ.
% sample_value_table = ai.sample_defaults;

%% 3. Modify table as desired...
param_table.Guided = 4;
param_table.Seed1 = 9000;
param_table.Seed2 = 5000;

%% Run ADRIA

% Load site specific data
ai.loadConnectivity('Inputs/Moore/connectivity/2015/');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

tic
% Run a single simulation with 1 replicate
Y = ai.run(param_table, sampled_values=false, nreps=1);
Y = Y.Y;  % get raw results, ignoring seed/shade logs
toc
