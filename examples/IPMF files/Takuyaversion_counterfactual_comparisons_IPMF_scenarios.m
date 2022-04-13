%% Example showcasing how to define and run specific scenarios

rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values

% Getting the default values for all parameters
param_table = ai.raw_defaults;


%% 3. Modify table as desired...

% Desired parameter combinations
guided = [0; 1; 2; 3];
assistadapt = [0; 4; 8];
natadapt = [0.0; 0.2];

% Create a matrix of all the possible combinations of the values defined
% above.
[gg, ag, ng] = ndgrid(guided, assistadapt, natadapt);
all_combs = [gg(:), ag(:), ng(:)];

% Hard set the number of target corals (40K a year over 10 years)
% Two types of corals, so 20K each, per year.
param_table.Seed1(:) = 20000;
param_table.Seed2(:) = 20000;
param_table.Seedyrs(:) = 10;

% The `+1` is for the counterfactual
num_combinations = length(all_combs) + 1;

% Repeat the parameter table for the number of runs we want to do
param_table = repmat(param_table, num_combinations, 1);

% Set up the counterfactual
param_table{1, "Guided"} = 0;
param_table{1, "Aadpt"} = 0;
param_table{1, "Natad"} = 0;
param_table{1, "Seed1"} = 0;
param_table{1, "Seed2"} = 0;

% We start at 2 to keep the first simulation as the the counterfactual
% (all default values, except seeding/shading off)
for i = 2:num_combinations
    param_table{i, ["Guided", "Aadpt", "Natad"]} = all_combs(i-1, :);
end

%% Run ADRIA

% We want to run for 50 years
ai.constants.tf = 50;

n_reps = 50;  % num DHW/Wave/RCP replicates

% Load site specific data
ai.loadConnectivity('Inputs/Moore/connectivity/2015/');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

% Where result files will be written out to.
file_location_prefix = './Outputs/fri_deliv_2022-02-04';
n_batches = 5;

tic
% Run a single simulation with `n_reps` replicates
% saving to files in the above indicated location to save memory
ai.runToDisk(param_table, sampled_values=true, nreps=n_reps, ...
    file_prefix=file_location_prefix, batch_size=n_batches, collect_logs=["site_rankings"]);

% Collect the desired metrics from the result files
desired_metrics = {@coralTaxaCover, ...
                   @coralEvenness, ...
                   @coralSpeciesCover, ...
                   @shelterVolume, ...
                   @(x, p) mean(coralTaxaCover(x, p).total_cover, 4)};
Y = ai.gatherResults(file_location_prefix, desired_metrics);

% Get the logged site rankings as well
Y_rankings = ai.gatherResults(file_location_prefix, {}, "site_rankings");

tmp = toc;

N = length(Y) * n_batches * n_reps;
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N), " simulations (", num2str(tmp/(N)), " seconds per run)"))


%% Collect metrics

% Get the mean total coral cover at end of simulation time across all
% simulations.
% Note the name of the custom function has been transformed from its 
% function name to a representative string (brackets/dots to underscores).
mean_TC = concatMetrics(Y, "mean_coralTaxaCover_x_p_total_cover_4");
mean_TC = squeeze(mean(mean_TC(end, :, :, :), 4));


% Total coral cover
TC = concatMetrics(Y, "coralTaxaCover.total_cover");

% Coral cover per species
covs = concatMetrics(Y, "coralSpeciesCover");

% Evenness
E = concatMetrics(Y, "coralEvenness");

% Extract juvenile corals (< 5 cm diameter)
BC = concatMetrics(Y, "coralTaxaCover.juveniles");

% Calculate coral shelter volume per ha
SV_per_ha = concatMetrics(Y, "shelterVolume");

