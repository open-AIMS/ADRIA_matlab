%% Loading counterfactual and intervention data
out_45 = load('./Outputs/RCP45_redux.mat');
out_45_RCI = load('./Outputs/brick_runs_RCP45_RCI_no_evenness.mat');
out_45_fog = load('./Outputs/RCP45_protective_fog.mat');
% out_26 = load('./Outputs/brick_runs_RCP26.mat');
% out_26_RCI = load('./Outputs/brick_runs_RCP26_RCI.mat');
% out_60 = load('./Outputs/brick_runs_RCP60.mat');
% out_60_RCI = load('./Outputs/brick_runs_RCP26_RCI.mat');

cols = parula(10);
cols = cols([6,8],:);
cols = [cols(2,:);cols(1,:)];

% load extra runs for fogging
just_fog_runs = load("./Outputs/reruns_justfog_all_metrics.mat");

%% Violin plots: comparison of 4 metrics, counterfactual and intervention Seed 500, Aadpt 4, Natad 0.05
% vector of the years in the data set
yr = linspace(2026,2099,74);

tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
tgt_ind_int = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));

selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_cf);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_cf);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_cf);
% selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int);
% selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_cf);
selected_int_RCI = filterSummary(out_45_RCI, tgt_ind_int);
selected_cf_RCI = filterSummary(out_45_RCI, tgt_ind_cf);

%% plot 2*2 panel time series every 5 yrs
seed_site_rankings = out_45.site_rankings(:,:,:,tgt_ind_int);
struct_seed = struct('site_rankings',seed_site_rankings,'int',"seed");

figure(1)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_int_TC,selected_cf_TC,yr,5,'mean' ,...
    {'Coral Cover','Interv.','Counterf.'},struct_seed,cols,[],"Legend")
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI,selected_cf_RCI,yr,5,'mean' ,...
    {'RCI','Interv.','Counterf.'},struct_seed, cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_SV,selected_cf_SV,yr,5,'mean' , ...
    {'Relative Shelter Volume','Interv.','Counterf.'},struct_seed, ...
    cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_Ju,selected_cf_Ju,yr,5,'mean' , ...
    {'Juveniles','Interv.','Counterf.'},struct_seed,cols)
hold off

%% intervention Seed 500, Aadpt 4, Natad, Guided vs. unguided
yr = linspace(2026,2099,74);
tgt_ind_int1 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.0)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
tgt_ind_int2 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.0)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==0));
selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int1);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int2);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int1);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int2);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int1);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_int2);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int1);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int2);
selected_int_RCI = filterSummary(out_45_RCI, tgt_ind_int1);
selected_cf_RCI = filterSummary(out_45_RCI, tgt_ind_int2);

%% plot every 5 yrs
seed_site_rankings = out_45.site_rankings(:,:,:,tgt_ind_int1);
seed_struct = struct('site_rankings',seed_site_rankings,'int',"seed")

figure(3)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_int_TC,selected_cf_TC,yr,5,'mean' ,...
    {'Coral Cover','Guided','Unguided'},seed_struct,cols,[],"Legend")
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI,selected_cf_RCI,yr,5,'mean' ,...
    {'RCI','Guided','Unguided'},seed_struct,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_SV,selected_cf_SV,yr,5,'mean' ,...
    {'Relative Shelter Volume','Guided','Unguided'},seed_struct,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_Ju,selected_cf_Ju,yr,5,'mean' ,...
    {'Juveniles','Guided','Unguided'},seed_struct,cols)
hold off


%% Violin plots: RCI for 6 interventions, RCP 45
yr = linspace(2026,2099,74);

% find index for each scenario
% counterfactual
tgt_ind_cf_45 = find((out_45.inputs.Seedyr_start==2)& ...
                    (out_45.inputs.Shadeyr_start==2)& ...
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Shadeyrs==20)& ...
                    (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Seedfreq==0)& ...
                    (out_45.inputs.Seed1==0)& ...
                    (out_45.inputs.Seed2==0)& ...
                    (out_45.inputs.fogging==0)& ...
                    (out_45.inputs.Natad==0)& ...
                    (out_45.inputs.Aadpt==0)& ...
                    (out_45.inputs.Guided==0));
% 0 DHW but seeded 
tgt_ind_int_45_seedOnly = find((out_45.inputs.Seedyr_start==2)& ...
                                (out_45.inputs.Shadeyr_start==2)& ...
                                (out_45.inputs.Shadefreq==1)& ...
                                (out_45.inputs.Seedfreq==0)& ...
                                (out_45.inputs.Shadeyrs==20)& ...
                                (out_45.inputs.Seedyrs==5)& ...
                                (out_45.inputs.Seed1==500000)& ...
                                (out_45.inputs.Seed2==500000)& ...
                                (out_45.inputs.fogging==0)& ...
                                (out_45.inputs.Natad==0)& ...
                                (out_45.inputs.Aadpt==0)& ...
                                (out_45.inputs.Guided==1));
% Fogging only
%tgt_ind_int_45_fogOnly = find((out_45_fog.inputs.Seedyr_start==2)&(out_45_fog.inputs.Shadeyr_start==2)&(out_45_fog.inputs.Shadefreq==1)&(out_45_fog.inputs.Seedfreq==0)&(out_45_fog.inputs.Shadeyrs==74)&(out_45_fog.inputs.Seedyrs==5)&(out_45_fog.inputs.Seed1==0)&(out_45_fog.inputs.Seed2==0)&(out_45_fog.inputs.fogging==0.2)&(out_45_fog.inputs.Natad==0)&(out_45_fog.inputs.Aadpt==0)&(out_45_fog.inputs.Guided==1));
% 4 DHW seed 
tgt_ind_int_45_seed4dhw = find((out_45.inputs.Seedyr_start==2)& ...
                                (out_45.inputs.Shadeyr_start==2)& ...
                                (out_45.inputs.Shadefreq==1)& ...
                                (out_45.inputs.Seedfreq==0)& ...
                                (out_45.inputs.Shadeyrs==20)& ...
                                (out_45.inputs.Seedyrs==5)& ...
                                (out_45.inputs.Seed1==500000)& ...
                                (out_45.inputs.Seed2==500000)& ...
                                (out_45.inputs.fogging==0)& ...
                                (out_45.inputs.Natad==0)& ...
                                (out_45.inputs.Aadpt==4)& ...
                                (out_45.inputs.Guided==1));
% 8 DHW seed
tgt_ind_int_45_seed8dhw = find((out_45.inputs.Seedyr_start==2)& ...
                                (out_45.inputs.Shadeyr_start==2)& ...
                                (out_45.inputs.Shadefreq==1)& ...
                                (out_45.inputs.Seedfreq==0)& ...
                                (out_45.inputs.Shadeyrs==20)& ...
                                (out_45.inputs.Seedyrs==5)& ...
                                (out_45.inputs.Seed1==500000)& ...
                                (out_45.inputs.Seed2==500000)& ...
                                (out_45.inputs.fogging==0)& ...
                                (out_45.inputs.Natad==0)& ...
                                (out_45.inputs.Aadpt==8)& ...
                                (out_45.inputs.Guided==1));
% 8 DHW and fogging
tgt_ind_int_45_fog8dhw = find((out_45_fog.inputs.Seedyr_start==2)& ...
                                (out_45_fog.inputs.Shadeyr_start==2)& ...
                                (out_45_fog.inputs.Shadefreq==1)& ...
                                (out_45_fog.inputs.Seedfreq==0)& ...
                                (out_45_fog.inputs.Shadeyrs==74)& ...
                                (out_45_fog.inputs.Seedyrs==5)& ...
                                (out_45_fog.inputs.Seed1==500000)& ...
                                (out_45_fog.inputs.Seed2==500000)& ...
                                (out_45_fog.inputs.fogging==0.2)& ...
                                (out_45_fog.inputs.Natad==0)& ...
                                (out_45_fog.inputs.Aadpt==8)& ...
                                (out_45_fog.inputs.Guided==1));
% 4 DHW and fogging
tgt_ind_int_45_fog4dhw = find((out_45_fog.inputs.Seedyr_start==2)& ...
                                (out_45_fog.inputs.Shadeyr_start==2)& ...
                                (out_45_fog.inputs.Shadefreq==1)& ...
                                (out_45_fog.inputs.Seedfreq==0)& ...
                                (out_45_fog.inputs.Shadeyrs==74)& ...
                                (out_45_fog.inputs.Seedyrs==5)& ...
                                (out_45_fog.inputs.Seed1==500000)& ...
                                (out_45_fog.inputs.Seed2==500000)& ...
                                (out_45_fog.inputs.fogging==0.2)& ...
                                (out_45_fog.inputs.Natad==0)& ...
                                (out_45_fog.inputs.Aadpt==4)& ...
                                (out_45_fog.inputs.Guided==1));

% retrieve indices for each scenario
% counterfactual
selected_cf_RCI_45 = filterSummary(out_45_RCI, tgt_ind_cf_45);
% only seeded 
selected_int_RCI_seedOnly = filterSummary(out_45_RCI, tgt_ind_int_45_seedOnly);
% Fogging only
selected_int_RCI_45_fogOnly = struct('mean',just_fog_runs.reruns_justfog.RCI_mean);
% 4 DHW seed 
selected_int_RCI_45_seed4dhw = filterSummary(out_45_RCI, tgt_ind_int_45_seed4dhw);
% 8 DHW seed 
selected_int_RCI_45_seed8dhw = filterSummary(out_45_RCI, tgt_ind_int_45_seed8dhw);
% 8 DHW and fogging
selected_int_RCI_45_fog8dhw = filterSummary(out_45_fog.RCI, tgt_ind_int_45_fog8dhw);
% 4 DHW and fogging
selected_int_RCI_45_fog4dhw = filterSummary(out_45_fog.RCI, tgt_ind_int_45_fog4dhw);

%% plot 2*3 panel time series every 10 yrs
rerun_seed_ranks = load("./Outputs/reruns_seed_ranks.mat");

% set up site ranks structs for each scenario
seed_site_rankings_45_seedOnly = rerun_seed_ranks.site_ranks_reruns.just_seed;
%out_45.site_rankings(:,:,:,tgt_ind_int_45_seedOnly);
intv_struct_seedOnly = struct('site_rankings',seed_site_rankings_45_seedOnly,'int',"seed");

% seed_site_rankings_45_fogOnly = out_45_fog.site_rankings(:,:,:,tgt_ind_int_45_fogOnly);
seed_site_rankings_45_fogOnly = just_fog_runs.reruns_justfog.site_rankings;
intv_struct_fogOnly = struct('site_rankings',seed_site_rankings_45_fogOnly,'int',"shade");

seed_site_rankings_45_seed4dhw = rerun_seed_ranks.site_ranks_reruns.seed4dhw;
%out_45.site_rankings(:,:,:,tgt_ind_int_45_seed4dhw);
intv_struct_seed4dhw = struct('site_rankings',seed_site_rankings_45_seed4dhw,'int',"seed");

seed_site_rankings_45_seed8dhw = rerun_seed_ranks.site_ranks_reruns.seed8dhw;
%out_45.site_rankings(:,:,:,tgt_ind_int_45_seed8dhw);
intv_struct_seed8dhw = struct('site_rankings',seed_site_rankings_45_seed8dhw,'int',"seed");

seed_site_rankings_45_fog8dhw = out_45_fog.site_rankings(:,:,:,tgt_ind_int_45_fog8dhw);
intv_struct_fog8dhw = struct('site_rankings',seed_site_rankings_45_fog8dhw,'int',"both");

seed_site_rankings_45_fog4dhw = out_45_fog.site_rankings(:,:,:,tgt_ind_int_45_fog4dhw);
intv_struct_fog4dhw = struct('site_rankings',seed_site_rankings_45_fog4dhw,'int',"both");

%% Plotting 6 scenarios

tstep = 10;
ylims = [0,0.6];

figure(4)
t = tiledlayout(3,2)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_int_RCI_seedOnly,selected_cf_RCI_45,yr,tstep,'mean' ,...
    {'RCI','Interv.','Counterf.'},intv_struct_seedOnly, cols,ylims,"Legend")
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_fogOnly,selected_cf_RCI_45,yr,tstep,'mean' ,...
    {'RCI','Interv.','Counterf.'},intv_struct_fogOnly,cols,ylims)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_seed4dhw,selected_cf_RCI_45,yr,tstep,'mean' , ...
    {'RCI','Interv.','Counterf.'},intv_struct_seed4dhw, ...
    cols,ylims)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_fog4dhw,selected_cf_RCI_45,yr,tstep,'mean' , ...
    {'RCI','Interv.','Counterf.'},intv_struct_fog4dhw, ...
    cols,ylims)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_seed8dhw,selected_cf_RCI_45,yr,tstep,'mean' , ...
    {'RCI','Interv.','Counterf.'},intv_struct_seed8dhw, ...
    cols,ylims)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_fog8dhw,selected_cf_RCI_45,yr,tstep,'mean' , ...
    {'RCI','Interv.','Counterf.'},intv_struct_fog8dhw, ...
    cols,ylims)
hold off

%% Violin plots: 3 RCPs for RCI, 500000 seeding, 4 DHW 

% yr = linspace(2026,2099,74);
% 
% tgt_ind_cf_45 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
% tgt_ind_int_45 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
% tgt_ind_cf_26 = find((out_26.inputs.Seedyr_start==2)&(out_26.inputs.Shadeyr_start==2)&(out_26.inputs.Seedyrs==5)&(out_26.inputs.Shadeyrs==20)&(out_26.inputs.Shadefreq==1)&(out_26.inputs.Seedfreq==0)&(out_26.inputs.Seed1==0)&(out_26.inputs.Seed2==0)&(out_26.inputs.SRM==0)&(out_26.inputs.fogging==0)&(out_26.inputs.Natad==0)&(out_26.inputs.Aadpt==0)&(out_26.inputs.Guided==0));
% tgt_ind_int_26 = find((out_26.inputs.Seedyr_start==2)&(out_26.inputs.Shadeyr_start==2)&(out_26.inputs.Shadefreq==1)&(out_26.inputs.Seedfreq==3)&(out_26.inputs.Shadeyrs==20)&(out_26.inputs.Seedyrs==5)&(out_26.inputs.Seed1==500000)&(out_26.inputs.Seed2==500000)&(out_26.inputs.SRM==0)&(out_26.inputs.fogging==0)&(out_26.inputs.Natad==0)&(out_26.inputs.Aadpt==4)&(out_26.inputs.Guided==1));
% tgt_ind_cf_60 = find((out_60.inputs.Seedyr_start==2)&(out_60.inputs.Shadeyr_start==2)&(out_60.inputs.Seedyrs==5)&(out_60.inputs.Shadeyrs==20)&(out_60.inputs.Shadefreq==1)&(out_60.inputs.Seedfreq==0)&(out_60.inputs.Seed1==0)&(out_60.inputs.Seed2==0)&(out_60.inputs.SRM==0)&(out_60.inputs.fogging==0)&(out_60.inputs.Natad==0)&(out_60.inputs.Aadpt==0)&(out_60.inputs.Guided==0));
% tgt_ind_int_60 = find((out_60.inputs.Seedyr_start==2)&(out_60.inputs.Shadeyr_start==2)&(out_60.inputs.Shadefreq==1)&(out_60.inputs.Seedfreq==3)&(out_60.inputs.Shadeyrs==20)&(out_60.inputs.Seedyrs==5)&(out_60.inputs.Seed1==500000)&(out_60.inputs.Seed2==500000)&(out_60.inputs.SRM==0)&(out_60.inputs.fogging==0)&(out_60.inputs.Natad==0)&(out_60.inputs.Aadpt==4)&(out_60.inputs.Guided==1));
% 
% selected_int_RCI_45 = filterSummary(out_45_RCI, tgt_ind_int_45);
% selected_cf_RCI_45 = filterSummary(out_45_RCI, tgt_ind_cf_45);
% selected_int_RCI_26 = filterSummary(out_26_RCI, tgt_ind_int_26);
% selected_cf_RCI_26 = filterSummary(out_26_RCI, tgt_ind_cf_26);
% selected_int_RCI_60 = filterSummary(out_60_RCI, tgt_ind_int_60);
% selected_cf_RCI_60 = filterSummary(out_60_RCI, tgt_ind_cf_60);

% %% plot 2*2 panel time series every 5 yrs
% seed_site_rankings_45 = out_45.site_rankings(:,:,:,tgt_ind_int_45);
% seed_site_rankings_26 = out_26.site_rankings(:,:,:,tgt_ind_int_26);
% seed_site_rankings_60 = out_60.site_rankings(:,:,:,tgt_ind_int_60);
% 
% tstep = 10;
% 
% figure(3)
% t = tiledlayout(1,3)
% t.TileSpacing = 'compact';
% 
% nexttile
% hold on
% plotCompareViolin(selected_int_RCI_26,selected_cf_RCI_26,yr,10,'mean' ,...
%     {'RCP 2.6 : RCI','Interv.','Counterf.'},[], cols)
% hold off
% 
% nexttile
% hold on
% plotCompareViolin(selected_int_RCI_45,selected_cf_RCI_45,yr,10,'mean' ,...
%     {'RCP 4.5 : RCI','Interv.','Counterf.'},[],cols)
% hold off
% 
% nexttile
% hold on
% plotCompareViolin(selected_int_RCI_60,selected_cf_RCI_60,yr,10,'mean' , ...
%     {'RCP 6.0 : RCI','Interv.','Counterf.'},[], ...
%     cols)
% hold off