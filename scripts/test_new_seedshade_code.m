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
param_table.fogging = 0.2;
param_table.Aadpt = 4;
param_table.Natad = 0.0;
param_table.Seedyrs = 10;
param_table.Shadeyrs = 74;
param_table.Seedfreq = 10;
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
param_table.Guided = 0;

Y = ai.run(param_table, sampled_values=false,nreps=n_reps,collect_logs=["site_rankings"]);
site_rankings_3 = Y.site_rankings;
metric_3 = collectMetrics(Y.Y,coral_params,{@coralTaxaCover,@shelterVolume,@coralEvenness,@coralSpeciesCover});
RCI_3 = ReefConditionIndex(metric_3.coralTaxaCover.total_cover, metric_3.coralEvenness, metric_3.shelterVolume, metric_3.coralTaxaCover.juveniles)
RCI_3 = squeeze(mean(RCI_3,3));
TC_3 = squeeze(mean(metric_3.coralTaxaCover.total_cover,3));
SV_3 = squeeze(mean(metric_3.shelterVolume,3));
Ev_3 = squeeze(mean(metric_3.coralEvenness,3));
Ju_3 = squeeze(mean(metric_3.coralTaxaCover.juveniles,3));

%%
reruns_2 = struct("site_rankings",site_rankings_2,"RCI_mean",RCI_2,"TC_mean",TC_2,"Ev_mean",Ev_2,"SV_mean",SV_2,"Ju_mean",Ju_2);
reruns_3 = struct("site_rankings",site_rankings_3,"RCI_mean",RCI_3,"TC_mean",TC_3,"Ev_mean",Ev_3,"SV_mean",SV_3,"Ju_mean",Ju_3);
save("./Outputs/reruns_bugfix_metrics.mat","reruns_2","reruns_3");
%%
cols = parula(10);
cols = cols([6,8],:);
cols = [cols(2,:);cols(1,:)];
yr = linspace(2026,2099,74);
seed_site_rankings2 = reruns_2.site_rankings;
seed_struct2 = struct('site_rankings',seed_site_rankings2,'int',"seed");
seed_site_rankings3 = reruns_3.site_rankings;
seed_site_rankings = seed_site_rankings3(:,:,1);
% store_shade_seed = zeros(length(yr),5);
% for yy = 1:length(yr)
%     seed_ranks = sortrows([(1:561)',seed_site_rankings(yy,:)'],2,'ascend');
%     seed_ranks_sites = seed_ranks(:,1);
%     
%     ind_nsites = min(length(seed_ranks_sites),5);
%     seed_ranks_sites = seed_ranks_sites(1:ind_nsites);
%     store_shade_seed(yy,:) = seed_ranks_sites;
% end
Guided_RCI = struct('mean',reruns_2.RCI_mean);
Unguided_RCI = struct('mean',reruns_3.RCI_mean);
Guided_CoralCover = struct('mean',reruns_2.RCI_mean);
Unguided_CoralCover = struct('mean',reruns_3.RCI_mean);

tstep = 5;
ylims = [0,0.6];

figure(1)
t = tiledlayout(1,2)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(Guided_RCI,Unguided_RCI,yr,tstep,'mean' ,...
    {'RCI','Guided','Unguided'},seed_struct2, cols,ylims,"Legend")
hold off

nexttile
hold on
plotCompareViolin(Guided_CoralCover,Unguided_CoralCover,yr,tstep,'mean' ,...
     {'Coral Cover','Guided','Unguided'},seed_struct2,cols,ylims)
 hold off