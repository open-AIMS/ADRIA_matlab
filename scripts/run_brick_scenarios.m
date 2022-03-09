rng(101) % set seed for reproducibility

ai = ADRIA();

param_table = ai.raw_defaults;

%% parameter combos as per deliv specifications
Guided = [0, 1];
Seed1 = [0, 200, 400];
Seed2 = [0, 200, 400];
fogging = 0;
Aadpt = [0, 4, 8];
Natad = [0, 0.05];
Seedyrs = [5, 10];
Shadeyrs = [5, 10];
Seedfreq = [0, 3, 5];
Shadefreq = [1, 5];
Seedyr_start = [2, 6, 11, 16];
Shadeyr_start = [2, 6, 11, 16];


target_inputs = table(Guided, Seed1, Seed2, fogging, Aadpt, Natad, Seedyrs, Shadeyrs, Seedfreq, ...
    Shadefreq, Seedyr_start, Shadeyr_start);

perm_table = createPermutationTable(target_inputs);

% Get column names
col_names = param_table.Properties.VariableNames;
cols_to_include = ["Guided", "Seed1", "Seed2", "fogging", "Aadpt", "Natad", ...
    "Seedyrs", "Shadeyrs", "Seedfreq", "Shadefreq", "Seedyr_start", "Shadeyr_start"];
ignore_cols = string(col_names(~ismember(col_names,cols_to_include)));
input_table = ai.setParameterValues(perm_table, ignore = ignore_cols', partial = false);

% debug
input_table = input_table(1:4, :);
N = 4;

%% Run ADRIA

% Load site specific data
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/2015/');
ai.loadCoralCovers("./Inputs/Brick/site_data/coralCoverBrickTruncated.mat")
ai.loadDHWData('./Inputs/Brick/DHWs/dhwRCP45.mat', 20)


bsize = 2;
n_reps = 20;

desired_metrics = {@(x, p) coralTaxaCover(x, p).total_cover, ...
    @(x, p) coralTaxaCover(x, p).juveniles, ...
    @coralEvenness, ...
    @shelterVolume, ...
    };

tic
ai.runToDisk(input_table, sampled_values = false, nreps = n_reps, ...
    file_prefix = './Outputs/brick_trial', batch_size = bsize, metrics = desired_metrics, summarize=true);
tmp = toc;
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N * n_reps)), " seconds per run)"))

% Get summary stats for all metrics
Y = ai.gatherSummary('./Outputs/brick_trial');

% mean_rci = ReefConditionIndex(Y.coralTaxaCover_x_p_total_cover.mean, Y.coralEvenness.mean, Y.shelterVolume.mean, Y.coralTaxaCover_x_p_juveniles.mean);
% plotTrajectory(summarizeMetrics(struct('RCI_mean', mean_rci)).RCI_mean);
