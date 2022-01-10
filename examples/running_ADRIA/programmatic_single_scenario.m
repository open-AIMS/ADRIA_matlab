%% Script showcasing how to define and run a single scenario.

rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values

% Resulting table consists of N rows and D columns, where N is the
% number of scenarios (here, just one), and D is the number of parameters.
param_table = ai.raw_defaults;

%% 3. Modify table as desired...
param_table(1, 'alg_ind') = {3};
param_table(1, 'Guided') = {1};
param_table(1, 'Seed1') = {15000};
param_table(1, 'Seed2') = {50000};


%% Run ADRIA

% Specify connectivity data
ai.loadConnectivity('MooreTPmean.xlsx');

% Run the single simulation
Y = ai.run(param_table, sampled_values=false, nreps=1);
