rng(101) % set seed for reproducibility

ai = ADRIA();

param_table = ai.raw_defaults;

%% set specific parameter values

param_table.Guided = 1;
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.SRM = 0;
param_table.fogging = 0;
param_table.Aadpt =0;
param_table.Natad =0;
param_table.Seedyrs = 5;
param_table.Shadeyrs = 20;
param_table.Seedfreq = 0;
param_table.Shadefreq = 1;
param_table.Seedyr_start = 2;
param_table.Shadeyr_start = 2;

n_reps = 20;

% Run all years
ai.constants.tf = 74;

% Load site specific data
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/2015/');
ai.loadCoralCovers("./Inputs/Brick/site_data/coralCoverBrickTruncated.mat");
ai.loadDHWData('./Inputs/Brick/DHWs/dhwRCP45.mat', n_reps);

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_1 = Y.site_rankings;

%%
param_table.Guided = 1;
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.SRM = 0;
param_table.fogging = 0.2;
param_table.Aadpt = 4;
param_table.Natad =0;
param_table.Seedyrs = 5;
param_table.Shadeyrs = 20;
param_table.Seedfreq = 0;
param_table.Shadefreq = 1;
param_table.Seedyr_start = 2;
param_table.Shadeyr_start = 2;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_3 = Y.site_rankings;

%%
param_table.Guided = 1;
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.SRM = 0;
param_table.fogging = 0.2;
param_table.Aadpt = 8;
param_table.Natad =0;
param_table.Seedyrs = 5;
param_table.Shadeyrs = 20;
param_table.Seedfreq = 0;
param_table.Shadefreq = 1;
param_table.Seedyr_start = 2;
param_table.Shadeyr_start = 2;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_5 = Y.site_rankings;

%%
param_table.Guided = 1;
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.SRM = 0;
param_table.fogging = 0.2;
param_table.Aadpt = 8;
param_table.Natad =0.05;
param_table.Seedyrs = 5;
param_table.Shadeyrs = 20;
param_table.Seedfreq = 0;
param_table.Shadefreq = 1;
param_table.Seedyr_start = 2;
param_table.Shadeyr_start = 2;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_6 = Y.site_rankings;

%%
left_out_ranks = struct("r_1",site_rankings_1,"r_3",site_rankings_3,"r_5",site_rankings_5,"r_6",site_rankings_6);
save("./Outputs/ranks_brick_scens.mat","left_out_ranks");