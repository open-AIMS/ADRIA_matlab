rng(101) % set seed for reproducibility

ai = ADRIA();

param_table = ai.raw_defaults;
[~,~,coral_params] = ai.splitParameterTable(param_table);
%% set specific parameter values
% nranks run :seed 4dhw, seed 8dhw, just seed
param_table.Guided = 1;
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.SRM = 0;
param_table.fogging = 0;
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
RCI_2 = ReefConditionIndex(metric_2.coralTaxaCover.total_cover, metric_2.coralEvenness, metric_2.shelterVolume, metric_2.coralTaxaCover.juveniles)
RCI_2 = squeeze(mean(RCI_2,3));
TC_2 = squeeze(mean(metric_2.coralTaxaCover.total_cover,3));
SV_2 = squeeze(mean(metric_2.shelterVolume,3));
Ev_2 = squeeze(mean(metric_2.coralEvenness,3));
Ju_2 = squeeze(mean(metric_2.coralTaxaCover.juveniles,3));

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
RCI_3 = ReefConditionIndex(metric_3.coralTaxaCover.total_cover, metric_3.coralEvenness, metric_3.shelterVolume, metric_3.coralTaxaCover.juveniles)
RCI_3 = squeeze(mean(RCI_3,3));
TC_3 = squeeze(mean(metric_3.coralTaxaCover.total_cover,3));
SV_3 = squeeze(mean(metric_3.shelterVolume,3));
Ev_3 = squeeze(mean(metric_3.coralEvenness,3));
Ju_3 = squeeze(mean(metric_3.coralTaxaCover.juveniles,3));

%% no. 5
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.fogging = 0.2;
param_table.Aadpt = 8;
param_table.Natad =0;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_5 = Y.site_rankings;
metric_5 = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
RCI_5 = ReefConditionIndex(metric_5.coralTaxaCover.total_cover, metric_5.coralEvenness, metric_5.shelterVolume, metric_5.coralTaxaCover.juveniles)
RCI_5 = squeeze(mean(RCI_5,3));
TC_5 = squeeze(mean(metric_5.coralTaxaCover.total_cover,3));
SV_5 = squeeze(mean(metric_5.shelterVolume,3));
Ev_5 = squeeze(mean(metric_5.coralEvenness,3));
Ju_5 = squeeze(mean(metric_5.coralTaxaCover.juveniles,3));

%% no. 6
param_table.Seed1 = 500000;
param_table.Seed2 = 500000;
param_table.fogging = 0.2;
param_table.Aadpt = 8;
param_table.Natad =0.05;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_6 = Y.site_rankings;
metric_6 = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
RCI_6 = ReefConditionIndex(metric_6.coralTaxaCover.total_cover, metric_6.coralEvenness, metric_6.shelterVolume, metric_6.coralTaxaCover.juveniles)
RCI_6 = squeeze(mean(RCI_6,3));
TC_6 = squeeze(mean(metric_6.coralTaxaCover.total_cover,3));
SV_6 = squeeze(mean(metric_6.shelterVolume,3));
Ev_6 = squeeze(mean(metric_6.coralEvenness,3));
Ju_6 = squeeze(mean(metric_6.coralTaxaCover.juveniles,3));

%%
reruns_2 = struct("site_rankings",site_rankings_2,"RCI_mean",RCI_2,"TC_mean",TC_2,"Ev_mean",Ev_2,"SV_mean",SV_2,"Ju_mean",Ju_2);
reruns_3 = struct("site_rankings",site_rankings_3,"RCI_mean",RCI_3,"TC_mean",TC_3,"Ev_mean",Ev_3,"SV_mean",SV_3,"Ju_mean",Ju_3);
reruns_5 = struct("site_rankings",site_rankings_5,"RCI_mean",RCI_5,"TC_mean",TC_5,"Ev_mean",Ev_5,"SV_mean",SV_5,"Ju_mean",Ju_5);
reruns_6 = struct("site_rankings",site_rankings_6,"RCI_mean",RCI_6,"TC_mean",TC_6,"Ev_mean",Ev_6,"SV_mean",SV_6,"Ju_mean",Ju_6);
save("./Outputs/reruns_long_fog_brick_scens_all_metrics.mat","reruns_2","reruns_3","reruns_5","reruns_6");
