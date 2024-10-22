%% Example showcasing how to define and run specific scenarios

rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values

% Resulting table consists of N rows and D columns, where N is the
% number of scenarios (here, N=1 of default values), and
% D is the number of parameters.
param_table = ai.raw_defaults;

%% parameter combos as per deliv specifications
guided = [0,1];
srm = 0;
fogging = [0,0.2];
natad = [0,0.05];
aadt = [0,4,8];
seed1 = [0,200,400];
seed2 = [0,200,400];
seedfreq = [0,3,5];
shadefreq = [1,5];
seedstartyr = [2,6,11,16];
shadestartyr = [2,6,11,16];
seedyrs = [5,10];
shadeyrs = [5,10];

params_table = table(guided,seed1,seed2,srm,fogging,natad,aadt,seedyrs,shadeyrs, seedfreq,...
    shadefreq,seedstartyr,shadestartyr);

perm_table = createPermutationTable(params_table);

% Get column names
col_names = param_table.Properties.VariableNames;
ignore_cols = convertCharsToStrings(col_names(find(~ismember(col_names,["Guided","Seed1","Seed2","SRM","fogging","Aadpt","Natad","Seedyrs","Shadeyrs","Seedfreq","Shadefreq","Seedyr_start","Shadeyr_start"]))))

perm_table_new = ai.setParameterValues(perm_table, ignore=ignore_cols', partial=true);
perm_table_filtered = filterPermutationTable(perm_table_new);

%% Run ADRIA
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

% Load site specific data
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

ai.loadConnectivity('./Inputs/Brick/Brick_oversized_2019_636_d1_transfer_probability_matrix_wide.csv',cutoff=0.1);

bsize = 128;
n_reps = 50;

tic
ai.runToDisk(perm_table_filtered, sampled_values=false, nreps=n_reps, ...
    file_prefix='./Outputs/Moore_example_multirun', batch_size=bsize, collect_logs=["site_rankings"]);

% Gather results, applying a metric to each result set.
% The last entry is an example of how one might create a custom aggregator
% In this case, it collects the average of Total Coral Cover across all
% simulations.
desired_metrics = {@coralTaxaCover, ...
                   @coralEvenness, ...
                   @coralSpeciesCover, ...
                   @shelterVolume, ...
                   @(x, p) mean(coralTaxaCover(x, p).total_cover, bsize)};
Y = ai.gatherResults('./Outputs/Moore_example_multirun', desired_metrics);

% Collect logged values from raw result set
Y_rankings = ai.gatherResults('./Outputs/Moore_example_multirun', {}, "site_rankings");

tmp = toc;
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))

%% Extract metric values from batched result set

% Get the mean total coral cover at end of simulation time across all
% simulations.
% Note the name of the custom function has been transformed from its 
% function name to a representative string (brackets/dots to underscores).
mean_TC = concatMetrics(Y, "mean_coralTaxaCover_x_p_total_cover_4");
mean_TC = squeeze(mean(mean_TC(end, :, :, :), bsize));

% Extract site rankings for shading
rankings = concatMetrics(Y_rankings, "site_rankings");

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

% tic
% % Run a single simulation with `n_reps` replicates
% res = ai.run(param_table, sampled_values=false, nreps=n_reps);
% Y = res.Y;  % get raw results
% tmp = toc;
% 
% N = size(Y, 4);
% disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))
