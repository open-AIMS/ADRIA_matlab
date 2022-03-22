rng(101) % set seed for reproducibility

ai = ADRIA();

param_table = ai.raw_defaults;
[~,~,coral_params] = ai.splitParameterTable(param_table);
%% set specific parameter values
% no. 2
param_table.Guided = 1;
param_table.Seed1 = 0;
param_table.Seed2 = 0;
param_table.SRM = 0;
param_table.fogging = 0.2;
param_table.Aadpt = 0;
param_table.Natad = 0;
param_table.Seedyrs = 5;
param_table.Shadeyrs = 72;
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
site_rankings_2 = Y.site_rankings;
metric_2 = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
summarized_2 = ReefConditionIndex(metric_2.coralTaxaCover.total_cover, metric_2.coralEvenness, metric_2.shelterVolume, metric_2.coralTaxaCover.juveniles)
summarized_2 = squeeze(mean(summarized_2,3));

%% no. 3
param_table.Guided = 1;
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.fogging = 0.2;
param_table.Aadpt = 4;
param_table.Natad = 0;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_3 = Y.site_rankings;
metric_3 = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
summarized_3 = ReefConditionIndex(metric_3.coralTaxaCover.total_cover, metric_3.coralEvenness, metric_3.shelterVolume, metric_3.coralTaxaCover.juveniles)
summarized_3 = squeeze(mean(summarized_3,3));

%% no. 5
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.fogging = 0.2;
param_table.Aadpt = 8;
param_table.Natad =0;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_5 = Y.site_rankings;
metric_5 = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
summarized_5 = ReefConditionIndex(metric_5.coralTaxaCover.total_cover, metric_5.coralEvenness, metric_5.shelterVolume, metric_5.coralTaxaCover.juveniles)
summarized_5 = squeeze(mean(summarized_5,3));

%% no. 6
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.fogging = 0.2;
param_table.Aadpt = 8;
param_table.Natad =0.05;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_6 = Y.site_rankings;
metric_6 = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
summarized_6 = ReefConditionIndex(metric_6.coralTaxaCover.total_cover, metric_6.coralEvenness, metric_6.shelterVolume, metric_6.coralTaxaCover.juveniles)
summarized_6 = squeeze(mean(summarized_6,3));

%%
reruns_2 = struct("site_rankings",site_rankings_2,"mean",summarized_2);
reruns_3 = struct("site_rankings",site_rankings_3,"mean",summarized_3);
reruns_5 = struct("site_rankings",site_rankings_5,"mean",summarized_5);
reruns_6 = struct("site_rankings",site_rankings_6,"mean",summarized_6);
save("./Outputs/reruns_long_fog_brick_scens.mat","reruns_2","reruns_3","reruns_5","reruns_6");
