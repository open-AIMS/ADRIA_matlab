% Example script illustrating running ADRIA scenarios in batches
rng(101)

%% Generate monte carlo samples

% Number of scenarios
N = 8;
n_reps = 3;  % Number of replicate RCP scenarios

ai = ADRIA();

%% Parameter prep
% Collect details of available parameters
combined_opts = ai.parameterDetails();
sim_constants = ai.constants;

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
sample_table = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound(p);
    b = combined_opts.upper_bound(p);
    
    selection = (b - a).*rand(N, 1) + a;
    
    sample_table.(combined_opts.name(p)) = selection;
end

% Set MCDA algorithm choice to `2` as we only want to use TOPSIS 
% for this example
sample_table.Guided(:) = 2;

%% Load site specific data
ai.loadConnectivity('MooreTPmean.xlsx');

%% Scenario runs

tic
ai.runToDisk(sample_table, sampled_values=true, nreps=n_reps, ...
    file_prefix='./example_multirun', batch_size=4);

% Gather results, applying a metric to each result set.
Y = ai.gatherResults('./example_multirun', {@coralTaxaCover});

tmp = toc;
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))
