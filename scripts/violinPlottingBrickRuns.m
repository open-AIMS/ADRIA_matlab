%% Loading counterfactual and intervention data
out_45 = load('./Outputs/brick_runs_RCP45.mat');
out_45_RCI = load('./Outputs/brick_runs_RCP45_RCI.mat');
out_26 = load('./Outputs/brick_runs_RCP26.mat');
out_26_RCI = load('./Outputs/brick_runs_RCP26_RCI.mat');
out_60 = load('./Outputs/brick_runs_RCP60.mat');
out_60_RCI = load('./Outputs/brick_runs_RCP26_RCI.mat');

cols = parula(10);
cols = cols([6,8],:);
cols = [cols(2,:);cols(1,:)];

%% Violin plots: comparison of 4 metrics, counterfactual and intervention Seed 500, Aadpt 4, Natad 0.05
yr = linspace(2026,2099,74);

tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
tgt_ind_int = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));

selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_cf);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_cf);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_cf);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_cf);
selected_int_RCI = filterSummary(out_45_RCI, tgt_ind_int);
selected_cf_RCI = filterSummary(out_45_RCI, tgt_ind_cf);

%% plot 2*2 panel time series every 5 yrs
seed_site_rankings = out_45.site_rankings(:,:,:,tgt_ind_int);

figure(1)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_int_TC,selected_cf_TC,yr,5,'mean' ,...
    {'Coral Cover','Interv.','Counterf.'},seed_site_rankings,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI,selected_cf_RCI,yr,5,'mean' ,...
    {'RCI','Interv.','Counterf.'},seed_site_rankings, cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_SV,selected_cf_SV,yr,5,'mean' , ...
    {'Relative Shelter Volume','Interv.','Counterf.'},seed_site_rankings, ...
    cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_Ju,selected_cf_Ju,yr,5,'mean' , ...
    {'Juveniles','Interv.','Counterf.'},seed_site_rankings, cols)
hold off

%% intervention Seed 500, Aadpt 4, Natad, Guided vs. unguided

tgt_ind_int1 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
tgt_ind_int2 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==0));
selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int1);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int2);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int1);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int2);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int1);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_int2);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int1);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int2);
selected_int_RCI = filterSummary(out_45_RCI, tgt_ind_int);
selected_cf_RCI = filterSummary(out_45_RCI, tgt_ind_cf);

%% plot every 5 yrs
seed_site_rankings = out_45.site_rankings(:,:,:,tgt_ind_int1);

figure(2)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_int_TC,selected_cf_TC,yr,5,'mean' ,{'Coral Cover','Guided','Unguided'},seed_site_rankings,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI,selected_cf_RCI,yr,5,'mean' ,{'RCI','Guided','Unguided'},seed_site_rankings,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_SV,selected_cf_SV,yr,5,'mean' ,{'Relative Shelter Volume','Guided','Unguided'},seed_site_rankings,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_Ju,selected_cf_Ju,yr,5,'mean' ,{'Juveniles','Guided','Unguided'},seed_site_rankings,cols)
hold off

%% Violin plots: 3 RCPs for RCI, 500000 seeding, no fogging, no assisted adaptation
yr = linspace(2026,2099,74);

tgt_ind_cf_45 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
tgt_ind_int_45 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==1));
tgt_ind_cf_26 = find((out_26.inputs.Seedyr_start==2)&(out_26.inputs.Shadeyr_start==2)&(out_26.inputs.Seedyrs==5)&(out_26.inputs.Shadeyrs==20)&(out_26.inputs.Shadefreq==1)&(out_26.inputs.Seedfreq==0)&(out_26.inputs.Seed1==0)&(out_26.inputs.Seed2==0)&(out_26.inputs.SRM==0)&(out_26.inputs.fogging==0)&(out_26.inputs.Natad==0)&(out_26.inputs.Aadpt==0)&(out_26.inputs.Guided==0));
tgt_ind_int_26 = find((out_26.inputs.Seedyr_start==2)&(out_26.inputs.Shadeyr_start==2)&(out_26.inputs.Shadefreq==1)&(out_26.inputs.Seedfreq==3)&(out_26.inputs.Shadeyrs==20)&(out_26.inputs.Seedyrs==5)&(out_26.inputs.Seed1==500000)&(out_26.inputs.Seed2==500000)&(out_26.inputs.SRM==0)&(out_26.inputs.fogging==0)&(out_26.inputs.Natad==0)&(out_26.inputs.Aadpt==0)&(out_26.inputs.Guided==1));
tgt_ind_cf_60 = find((out_60.inputs.Seedyr_start==2)&(out_60.inputs.Shadeyr_start==2)&(out_60.inputs.Seedyrs==5)&(out_60.inputs.Shadeyrs==20)&(out_60.inputs.Shadefreq==1)&(out_60.inputs.Seedfreq==0)&(out_60.inputs.Seed1==0)&(out_60.inputs.Seed2==0)&(out_60.inputs.SRM==0)&(out_60.inputs.fogging==0)&(out_60.inputs.Natad==0)&(out_60.inputs.Aadpt==0)&(out_60.inputs.Guided==0));
tgt_ind_int_60 = find((out_60.inputs.Seedyr_start==2)&(out_60.inputs.Shadeyr_start==2)&(out_60.inputs.Shadefreq==1)&(out_60.inputs.Seedfreq==3)&(out_60.inputs.Shadeyrs==20)&(out_60.inputs.Seedyrs==5)&(out_60.inputs.Seed1==500000)&(out_60.inputs.Seed2==500000)&(out_60.inputs.SRM==0)&(out_60.inputs.fogging==0)&(out_60.inputs.Natad==0)&(out_60.inputs.Aadpt==0)&(out_60.inputs.Guided==1));

selected_int_RCI_45 = filterSummary(out_45_RCI, tgt_ind_int_45);
selected_cf_RCI_45 = filterSummary(out_45_RCI, tgt_ind_cf_45);
selected_int_RCI_26 = filterSummary(out_26_RCI, tgt_ind_int_26);
selected_cf_RCI_26 = filterSummary(out_26_RCI, tgt_ind_cf_26);
selected_int_RCI_60 = filterSummary(out_60_RCI, tgt_ind_int_60);
selected_cf_RCI_60 = filterSummary(out_60_RCI, tgt_ind_cf_60);

%% plot 2*2 panel time series every 5 yrs
seed_site_rankings_45 = out_45.site_rankings(:,:,:,tgt_ind_int_45);
seed_site_rankings_26 = out_26.site_rankings(:,:,:,tgt_ind_int_26);
seed_site_rankings_60 = out_60.site_rankings(:,:,:,tgt_ind_int_60);

tstep = 10;

figure(3)
t = tiledlayout(1,3)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_int_RCI_26,selected_cf_RCI_26,yr,10,'mean' ,...
    {'RCP 2.6 : RCI','Interv.','Counterf.'},[], cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45,selected_cf_RCI_45,yr,10,'mean' ,...
    {'RCP 4.5 : RCI','Interv.','Counterf.'},[],cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_60,selected_cf_RCI_60,yr,10,'mean' , ...
    {'RCP 6.0 : RCI','Interv.','Counterf.'},[], ...
    cols)
hold off

%% Violin plots: RCI for 6 interventions, RCP 45
% 1: 0 DHW but seeded (= larval slick intervention) and no fogging
% 2: Fogging only
% 3: 4 DHW and fogging  (the first multi-panel set already shows 4DHW without fogging)
% 4: 8 DHW and no fogging
% 5: 8 DHW and fogging
% 6: 8 DHW, fogging and natural adaptation

yr = linspace(2026,2099,74);

tgt_ind_cf_45 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
tgt_ind_int_45_1 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==1));
tgt_ind_int_45_2 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0.2)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==1));
tgt_ind_int_45_3 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0.2)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
tgt_ind_int_45_4 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==8)&(out_45.inputs.Guided==1));
tgt_ind_int_45_5 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0.2)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==8)&(out_45.inputs.Guided==1));
tgt_ind_int_45_6 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0.2)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==8)&(out_45.inputs.Guided==1));

selected_cf_RCI_45 = filterSummary(out_45_RCI, tgt_ind_cf_45);
selected_int_RCI_45_1 = filterSummary(out_45_RCI, tgt_ind_int_45_1);
selected_int_RCI_45_2 = filterSummary(out_45_RCI, tgt_ind_int_45_2);
selected_int_RCI_45_3 = filterSummary(out_45_RCI, tgt_ind_int_45_3);
selected_int_RCI_45_4 = filterSummary(out_45_RCI, tgt_ind_int_45_4);
selected_int_RCI_45_5 = filterSummary(out_45_RCI, tgt_ind_int_45_5);
selected_int_RCI_45_6 = filterSummary(out_45_RCI, tgt_ind_int_45_6);

%% plot 2*2 panel time series every 5 yrs
seed_site_rankings_45_1 = out_45.site_rankings(:,:,:,tgt_ind_int_45_1);
seed_site_rankings_45_2 = out_45.site_rankings(:,:,:,tgt_ind_int_45_2);
seed_site_rankings_45_3 = out_45.site_rankings(:,:,:,tgt_ind_int_45_3);
seed_site_rankings_45_4 = out_45.site_rankings(:,:,:,tgt_ind_int_45_4);
seed_site_rankings_45_5 = out_45.site_rankings(:,:,:,tgt_ind_int_45_5);
seed_site_rankings_45_6 = out_45.site_rankings(:,:,:,tgt_ind_int_45_6);

tstep = 10;

figure(4)
t = tiledlayout(2,3)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_1,selected_cf_RCI_45,yr,10,'mean' ,...
    {'RCI','Interv.','Counterf.'},[], cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_2,selected_cf_RCI_45,yr,10,'mean' ,...
    {'RCI','Interv.','Counterf.'},seed_site_rankings_45_2,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_3,selected_cf_RCI_45,yr,10,'mean' , ...
    {'RCI','Interv.','Counterf.'},[], ...
    cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_4,selected_cf_RCI_45,yr,10,'mean' , ...
    {'RCI','Interv.','Counterf.'},seed_site_rankings_45_4, ...
    cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_5,selected_cf_RCI_45,yr,10,'mean' , ...
    {'RCI','Interv.','Counterf.'},[], ...
    cols)
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI_45_6,selected_cf_RCI_45,yr,10,'mean' , ...
    {'RCI','Interv.','Counterf.'},[], ...
    cols)
hold off