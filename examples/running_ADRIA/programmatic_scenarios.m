%% Example showcasing how to define and run specific scenarios

rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values

% Resulting table consists of N rows and D columns, where N is the
% number of scenarios (here, N=1 of default values), and
% D is the number of parameters.
param_table = ai.raw_defaults;


% If multiple scenarios are to be run, extend the parameter table
% up to the N runs required, and adjust each row as desired
% For example, if 5 runs are desired, we would repeat the single row
% 5 times:
% param_table = repmat(param_table, 5, 1);


%% 3. Modify table as desired...
param_table.Guided = 1;
param_table.Seed1 = 9000;
param_table.Seed2 = 5000;
param_table.SRM = 2;
param_table.SeedTimes = 0;
% If running multiple scenarios, specify the values for each run
% param_table.Seed1 = [600; 700; 800; 900; 1000];

%% Run ADRIA

% Load site specific data
ai.loadConnectivity('Inputs/Moore/connectivity/2015/');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

n_reps = 2;

tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps);
Y = res.Y;  % get raw results
tmp = toc;

N = size(Y, 4);
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))
