rng(101) % set seed for reproducibility

ai = ADRIA();

param_table = ai.raw_defaults;

% set specific parameter values
Guided = [0, 1];
Seed1 = [0, 500000];
Seed2 = [0, 500000];
fogging = [0.0, 0.2];
Aadpt = [0, 4, 8];
Natad = [0.0, 0.05];
Seedyrs = 5;
Shadeyrs = 20;
Seedfreq = [0, 3];
Shadefreq = [1, 5];
Seedyr_start = [2, 6, 11, 16];
Shadeyr_start = [2, 6, 11, 16];

% Create combinations of above target values
target_inputs = table(Guided, Seed1, Seed2, fogging, Aadpt, Natad, ...
                      Seedyrs, Shadeyrs, Seedfreq, Shadefreq, ...
                      Seedyr_start, Shadeyr_start);
perm_table = createPermutationTable(target_inputs);

% Get column names
col_names = param_table.Properties.VariableNames;
cols_to_include = ["Guided", "Seed1", "Seed2", "fogging", "Aadpt", "Natad", ...
    "Seedyrs", "Shadeyrs", "Seedfreq", "Shadefreq", "Seedyr_start", "Shadeyr_start"];
ignore_cols = string(col_names(~ismember(col_names,cols_to_include)));
input_table = ai.setParameterValues(perm_table, ignore = ignore_cols', partial = false);

N = height(input_table);
n_reps = 20;

% Run all years
ai.constants.tf = 74;

% Load site specific data
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/2015/');
ai.loadCoralCovers("./Inputs/Brick/site_data/coralCoverBrickTruncated.mat");
ai.loadDHWData('./Inputs/Brick/DHWs/dhwRCP45.mat', n_reps);

desired_metrics = {@(x, p) coralTaxaCover(x, p).total_cover, ...
    @(x, p) coralTaxaCover(x, p).juveniles, ...
    @coralEvenness, ...
    @shelterVolume, ...
    };

% Get summary stats for all metrics
tic
% target_scens = find((input_table.fogging == 0.0) & (input_table.Seed1 == 0) & (input_table.Seed2 == 0));
% target_scens = find((input_table.Seed1 > 0) | (input_table.Seed2 > 0) | (input_table.fogging > 0.0));
target_scens = [];
Y = ai.gatherSummary('D:/ADRIA_results/Brick_Mar_deliv_RCP45/Brick_Mar_deliv_runs', summarize=false);
tmp = toc;
disp(strcat("Took ", num2str(tmp), " seconds to collect all scenarios"))

tic;
Y.inputs = input_table;
Y.sim_constants = ai.constants;
Y.collected_scenarios = target_scens;
save("D:/ADRIA_results/Brick_Mar_deliv_RCP45/brick_runs_RCP45.mat", "-struct", "Y", "-v7.3")
tmp = toc;
disp(strcat("Took ", num2str(tmp), " seconds to package data"))