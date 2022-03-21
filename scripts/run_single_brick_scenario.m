rng(101) % set seed for reproducibility

ai = ADRIA();

param_table = ai.raw_defaults;
[~,~,coral_params] = ai.splitParameterTable(param_table);
%% set specific parameter values

param_table.Guided = 1;
param_table.Seed1 = 0;
param_table.Seed2 = 0;
param_table.SRM = 0;
param_table.fogging = 0.2;
param_table.Aadpt = 0;
param_table.Natad = 0;
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
metric_fog = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
% summarized_fog = summarizeMetrics(metric_fog);
% RCI_fog = RCISummary(summarized_fog);
summarized_fog = ReefConditionIndex(metric_fog.coralTaxaCover.total_cover, metric_fog.coralEvenness, metric_fog.shelterVolume, metric_fog.coralTaxaCover.juveniles)
summarized_fog = squeeze(mean(summarized_fog,3));
%%
param_table.Guided = 1;
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.SRM = 0;
param_table.fogging = 0.2;
param_table.Aadpt = 4;
param_table.Natad = 0;
param_table.Seedyrs = 5;
param_table.Shadeyrs = 20;
param_table.Seedfreq = 0;
param_table.Shadefreq = 1;
param_table.Seedyr_start = 2;
param_table.Shadeyr_start = 2;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_3 = Y.site_rankings;
metric_seedfog = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
summarized_seedfog = ReefConditionIndex(metric_seedfog.coralTaxaCover.total_cover, metric_seedfog.coralEvenness, metric_seedfog.shelterVolume, metric_seedfog.coralTaxaCover.juveniles);
summarized_seedfog = squeeze(mean(summarized_seedfog,3));
%% plot comparison
yr = linspace(2026,2099,74);
tstep = 2;
cols = parula(10);
cols = cols([6,8],:);
cols = [cols(2,:);cols(1,:)];
hold on
al_goodplot(summarized_seedfog(1:tstep:end,:)', yr(1:tstep:end), 0.5, cols(2,:), 'right')
al_goodplot(summarized_fog(1:tstep:end,:)', yr(1:tstep:end), 0.5, cols(1,:), 'left')

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