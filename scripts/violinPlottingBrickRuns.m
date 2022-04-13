%% Loading counterfactual and intervention data
out_45 = load('./Outputs/RCP45_redux.mat');
% out_45_RCI = load('./Outputs/brick_runs_RCP45_RCI_no_evenness.mat');
% out_45_fog = load('./Outputs/RCP45_protective_fog.mat');
% out_26 = load('./Outputs/brick_runs_RCP26.mat');
% out_26_RCI = load('./Outputs/brick_runs_RCP26_RCI.mat');
% out_60 = load('./Outputs/brick_runs_RCP60.mat');
% out_60_RCI = load('./Outputs/brick_runs_RCP26_RCI.mat');

cols = parula(10);
cols = cols([6,8],:);
cols = [cols(2,:);cols(1,:)];

% load extra runs for fogging
%just_fog_runs = load("./Outputs/reruns_justfog_all_metrics.mat");

%% Violin plots: comparison of 4 metrics, counterfactual and intervention Seed 500, Aadpt 4, Natad 0.05
% vector of the years in the data set
yr = linspace(2026,2099,74);

tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)& ...
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
tgt_ind_int = find((out_45.inputs.Seedyr_start==2)& ...
                    (out_45.inputs.Shadeyr_start==2)& ...
                    (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Seedfreq==0)& ...
                    (out_45.inputs.Shadeyrs==20)& ...
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Seed1==500000)& ...
                    (out_45.inputs.Seed2==500000)& ...
                    (out_45.inputs.fogging==0.2)& ...
                    (out_45.inputs.Natad==0)& ...
                    (out_45.inputs.Aadpt==4)& ...
                    (out_45.inputs.Guided==1));

%% Use indices to select metrics
selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_cf);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_cf);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_cf);
% selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int);
% selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_cf);
selected_int_RCI = filterSummary(out_45.RCI, tgt_ind_int);
selected_cf_RCI = filterSummary(out_45.RCI, tgt_ind_cf);

%% plot 2*2 panel time series every 5 yrs
seed_site_rankings = out_45.site_rankings(:,:,:,tgt_ind_int);
struct_seed = struct('site_rankings',seed_site_rankings,'int',"seed");
tstep = 5;
figure(2)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_int_TC,selected_cf_TC,yr,tstep,'mean' ,...
    {'Coral Cover','Interv.','Counterf.'},struct_seed,cols,[],"Legend")
%xlim([2040,2060])
hold off

nexttile
hold on
plotCompareViolin(selected_int_RCI,selected_cf_RCI,yr,tstep,'mean' ,...
    {'RCI','Interv.','Counterf.'},struct_seed, cols)
%xlim([2040,2060])
hold off

nexttile
hold on
plotCompareViolin(selected_int_SV,selected_cf_SV,yr,tstep,'mean' , ...
    {'Relative Shelter Volume','Interv.','Counterf.'},struct_seed, ...
    cols)
%xlim([2040,2060])
hold off

nexttile
hold on
plotCompareViolin(selected_int_Ju,selected_cf_Ju,yr,tstep,'mean' , ...
    {'Juveniles','Interv.','Counterf.'},struct_seed,cols)
%xlim([2040,2060])
hold off

%% intervention Seed 500, Aadpt 4, Natad, Guided vs. unguided
yr = linspace(2026,2099,74);
key_params = (out_45.inputs.Seedyr_start==2)& ...
                    (out_45.inputs.Shadeyr_start==2)& ...
                    (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Seedfreq==0)& ...
                    (out_45.inputs.Shadeyrs==74)& ...
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Seed1==500000)& ...
                    (out_45.inputs.Seed2==500000)& ...
                    (out_45.inputs.fogging==0.2)& ...
                    (out_45.inputs.Natad==0.0)& ...
                    (out_45.inputs.Aadpt==8);
tgt_ind_intg = find(key_params&(out_45.inputs.Guided==1));
tgt_ind_intug = find(key_params&(out_45.inputs.Guided==0));

%% Select each metric using indices
selected_g_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_intg);
selected_ug_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_intug);
% selected_g_Ev = filterSummary(out_45.coralEvenness, tgt_ind_intg);
% selected_ug_Ev = filterSummary(out_45.coralEvenness, tgt_ind_intug);
selected_g_SV = filterSummary(out_45.shelterVolume, tgt_ind_intg);
selected_ug_SV = filterSummary(out_45.shelterVolume, tgt_ind_intug);
selected_g_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_intg);
selected_ug_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_intug);
selected_g_RCI = filterSummary(out_45.RCI, tgt_ind_intg);
selected_ug_RCI = filterSummary(out_45.RCI, tgt_ind_intug);

selected_g_TC = struct('mean',selected_g_TC.mean-selected_cf_TC.mean)
selected_ug_TC = struct('mean',selected_ug_TC.mean-selected_cf_TC.mean)
selected_g_SV = struct('mean',selected_g_SV.mean-selected_cf_SV.mean)
selected_ug_SV = struct('mean',selected_ug_SV.mean-selected_cf_SV.mean)
selected_g_Ju = struct('mean',selected_g_Ju.mean-selected_cf_Ju.mean)
selected_ug_Ju = struct('mean',selected_ug_Ju.mean-selected_cf_Ju.mean)
selected_g_RCI = struct('mean',selected_g_RCI.mean-selected_cf_RCI.mean)
selected_ug_RCI = struct('mean',selected_ug_RCI.mean-selected_cf_RCI.mean)

%% plot every 5 yrs
seed_site_rankings = out_45.site_rankings(:,:,:,tgt_ind_intg);
seed_struct = struct('site_rankings',seed_site_rankings,'int',"seed")
tstep = 5;
figure(3)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';

nexttile
hold on
plotCompareViolin(selected_g_TC,selected_ug_TC,yr,tstep,'mean' ,...
    {'$\delta$ Coral Cover','Guided','Unguided'},seed_struct,cols,[],"Legend")
hold off

nexttile
hold on
plotCompareViolin(selected_g_RCI,selected_ug_RCI,yr,tstep,'mean' ,...
    {'$\delta$ RCI','Guided','Unguided'},seed_struct,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_g_SV,selected_ug_SV,yr,tstep,'mean' ,...
    {'$\delta$ Relative Shelter Volume','Guided','Unguided'},seed_struct,cols)
hold off

nexttile
hold on
plotCompareViolin(selected_g_Ju,selected_ug_Ju,yr,tstep,'mean' ,...
    {'$\delta$ Juveniles','Guided','Unguided'},seed_struct,cols)
hold off
%% Mean value plots
figure(3)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';

nexttile
hold on
plot(yr,mean(selected_g_TC.mean,2),'Color',cols(1,:),'LineWidth',2)
plot(yr,mean(selected_ug_TC.mean,2),'Color',cols(2,:),'LineWidth',2)
plot(yr,median(selected_g_TC.mean,2),'Color',cols(1,:),'LineWidth',2,'LineStyle','--')
plot(yr,median(selected_ug_TC.mean,2),'Color',cols(2,:),'LineWidth',2,'LineStyle','--')
ylim([0,0.0425])
xlabel('Year','Interpreter','latex','Fontsize',12)
ylabel('$\delta$ mean coral cover','Interpreter','latex','Fontsize',12)
%xlim([2040,2060])
hold off

nexttile
hold on
plot(yr,mean(selected_g_RCI.mean,2),'Color',cols(1,:),'LineWidth',2)
plot(yr,mean(selected_ug_RCI.mean,2),'Color',cols(2,:),'LineWidth',2)
plot(yr,median(selected_g_RCI.mean,2),'Color',cols(1,:),'LineWidth',2,'LineStyle','--')
plot(yr,median(selected_ug_RCI.mean,2),'Color',cols(2,:),'LineWidth',2,'LineStyle','--')
ylim([0,0.0425])
xlabel('Year','Interpreter','latex','Fontsize',12)
ylabel('$\delta$ mean RCI','Interpreter','latex','Fontsize',12)
%xlim([2040,2060])
hold off

nexttile
hold on
plot(yr,mean(selected_g_SV.mean,2),'Color',cols(1,:),'LineWidth',2)
plot(yr,mean(selected_ug_SV.mean,2),'Color',cols(2,:),'LineWidth',2)
plot(yr,median(selected_g_SV.mean,2),'Color',cols(1,:),'LineWidth',2,'LineStyle','--')
plot(yr,median(selected_ug_SV.mean,2),'Color',cols(2,:),'LineWidth',2,'LineStyle','--')
ylim([0,0.0425])
xlabel('Year','Interpreter','latex','Fontsize',12)
ylabel('$\delta$ mean shelter volume ','Interpreter','latex','Fontsize',12)
%xlim([2040,2060])
hold off

nexttile
hold on
plot(yr,mean(selected_g_Ju.mean,2),'Color',cols(1,:),'LineWidth',2)
plot(yr,mean(selected_ug_Ju.mean,2),'Color',cols(2,:),'LineWidth',2)
plot(yr,median(selected_g_Ju.mean,2),'Color',cols(1,:),'LineWidth',2,'LineStyle','--')
plot(yr,median(selected_ug_Ju.mean,2),'Color',cols(2,:),'LineWidth',2,'LineStyle','--')
l = legend('Guided mean','Unguided mean','Guided median','Unguided median')
ylim([0,0.003])
set(l,'Interpreter','latex','Fontsize',10)
xlabel('Year','Interpreter','latex','Fontsize',12)
ylabel('$\delta$ mean juveniles','Interpreter','latex','Fontsize',12)
%xlim([2040,2060])
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
base_vars = (out_45.inputs.Seedyr_start==2)& ...
            (out_45.inputs.Shadeyr_start==2)& ...
            (out_45.inputs.Shadefreq==1)& ...
            (out_45.inputs.Seedfreq==0)& ...
            (out_45.inputs.Shadeyrs==74)& ...
            (out_45.inputs.Seedyrs==5)& ...
            (out_45.inputs.Natad==0);

tgt_ind_int_45_seedOnly = find(base_vars& ...
                        (out_45.inputs.fogging==0)& ...
                        (out_45.inputs.Aadpt==0)& ...
                        (out_45.inputs.Seed1==500000)& ...
                        (out_45.inputs.Seed2==500000)& ...
                        (out_45.inputs.Guided==1));
% Fogging only
tgt_ind_int_45_fogOnly = find(base_vars& ...
                        (out_45.inputs.fogging==0.2)& ...
                        (out_45.inputs.Aadpt==0)& ...
                        (out_45.inputs.Seed1==500000)& ...
                        (out_45.inputs.Seed2==500000)& ...
                        (out_45.inputs.Guided==1));
% 4 DHW seed 
tgt_ind_int_45_seed4dhw = find(base_vars& ...
                        (out_45.inputs.fogging==0)& ...
                        (out_45.inputs.Aadpt==4)& ...
                        (out_45.inputs.Seed1==500000)& ...
                        (out_45.inputs.Seed2==500000)& ...
                        (out_45.inputs.Guided==1));
% 8 DHW seed
tgt_ind_int_45_seed8dhw = find(base_vars& ...
                        (out_45.inputs.fogging==0)& ...
                        (out_45.inputs.Aadpt==8)& ...
                        (out_45.inputs.Seed1==500000)& ...
                        (out_45.inputs.Seed2==500000)& ...
                        (out_45.inputs.Guided==1));
% 8 DHW and fogging
tgt_ind_int_45_fog8dhw = find(base_vars& ...
                        (out_45.inputs.fogging==0.2)& ...
                        (out_45.inputs.Aadpt==8)& ...
                        (out_45.inputs.Seed1==500000)& ...
                        (out_45.inputs.Seed2==500000)& ...
                        (out_45.inputs.Guided==1));
% 4 DHW and fogging
tgt_ind_int_45_fog4dhw = find(base_vars& ...
                        (out_45.inputs.fogging==0.2)& ...
                        (out_45.inputs.Aadpt==4)& ...
                        (out_45.inputs.Seed1==500000)& ...
                        (out_45.inputs.Seed2==500000)& ...
                        (out_45.inputs.Guided==1));

%% retrieve indices for each scenario
% counterfactual
selected_cf_RCI_45 = filterSummary(out_45.RCI, tgt_ind_cf_45);
% only seeded 
selected_int_RCI_seedOnly = filterSummary(out_45.RCI, tgt_ind_int_45_seedOnly);
% Fogging only
selected_int_RCI_45_fogOnly = filterSummary(out_45.RCI, tgt_ind_int_45_fogOnly);
%struct('mean',just_fog_runs.reruns_justfog.RCI_mean);
% 4 DHW seed 
selected_int_RCI_45_seed4dhw = filterSummary(out_45.RCI, tgt_ind_int_45_seed4dhw);
% 8 DHW seed 
selected_int_RCI_45_seed8dhw = filterSummary(out_45.RCI, tgt_ind_int_45_seed8dhw);
% 8 DHW and fogging
selected_int_RCI_45_fog8dhw = filterSummary(out_45.RCI, tgt_ind_int_45_fog8dhw);
% 4 DHW and fogging
selected_int_RCI_45_fog4dhw = filterSummary(out_45.RCI, tgt_ind_int_45_fog4dhw);

%% plot 2*3 panel time series every 10 yrs
rerun_seed_ranks = load("./Outputs/reruns_seed_ranks.mat");

% set up site ranks structs for each scenario
seed_site_rankings_45_seedOnly = out_45.site_rankings(:,:,:,tgt_ind_int_45_seedOnly);
intv_struct_seedOnly = struct('site_rankings',seed_site_rankings_45_seedOnly,'int',"seed");

seed_site_rankings_45_fogOnly = out_45.site_rankings(:,:,:,tgt_ind_int_45_fogOnly);
intv_struct_fogOnly = struct('site_rankings',seed_site_rankings_45_fogOnly,'int',"shade");

seed_site_rankings_45_seed4dhw = out_45.site_rankings(:,:,:,tgt_ind_int_45_seed4dhw);
intv_struct_seed4dhw = struct('site_rankings',seed_site_rankings_45_seed4dhw,'int',"seed");

seed_site_rankings_45_seed8dhw = out_45.site_rankings(:,:,:,tgt_ind_int_45_seed8dhw);
intv_struct_seed8dhw = struct('site_rankings',seed_site_rankings_45_seed8dhw,'int',"seed");

seed_site_rankings_45_fog8dhw = out_45.site_rankings(:,:,:,tgt_ind_int_45_fog8dhw);
intv_struct_fog8dhw = struct('site_rankings',seed_site_rankings_45_fog8dhw,'int',"seed");

seed_site_rankings_45_fog4dhw = out_45.site_rankings(:,:,:,tgt_ind_int_45_fog4dhw);
intv_struct_fog4dhw = struct('site_rankings',seed_site_rankings_45_fog4dhw,'int',"seed");

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

%% Memory saving for just using RCI

cols = parula(10);
cols = cols([6,8],:);
cols = [cols(2,:);cols(1,:)];

out_45_RCI = out_45.RCI;
out_45_CC = out_45.coralTaxaCover_x_p_total_cover;
out_45_inputs = out_45.inputs;
out_45_site_select = out_45.site_rankings;
clear('out_45')
out_45 = struct('RCI',out_45_RCI,'total_cover',out_45_CC,'inputs',out_45_inputs,'site_rankings',out_45_site_select)

%% Violin plots: delta guided vs unguided for 20 top sites vs. whole domain
time_slice = 15:35;
unchanged_vars = (out_45.inputs.Seedyr_start==2)& ...
                    (out_45.inputs.Shadeyr_start==2)& ...
                    (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Seedfreq==0)& ...
                    (out_45.inputs.Shadeyrs==74)& ...
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Seed1==500000)& ...
                    (out_45.inputs.Seed2==500000)& ...
                    (out_45.inputs.fogging==0.2)& ...
                    (out_45.inputs.Natad==0.0);

tgt_ind_int_Guided_0dhw = find(unchanged_vars&(out_45.inputs.Aadpt==0)& ...
                    (out_45.inputs.Guided==1));
                    
tgt_ind_int_Guided_4dhw = find(unchanged_vars&(out_45.inputs.Aadpt==4)& ...
                    (out_45.inputs.Guided==1));

tgt_ind_int_Guided_8dhw = find(unchanged_vars&(out_45.inputs.Aadpt==8)& ...
                    (out_45.inputs.Guided==1));

tgt_ind_int_Unguided_0dhw = find(unchanged_vars&(out_45.inputs.Aadpt==0)& ...
                    (out_45.inputs.Guided==0));

tgt_ind_int_Unguided_4dhw = find(unchanged_vars&(out_45.inputs.Aadpt==4)& ...
                    (out_45.inputs.Guided==0));

tgt_ind_int_Unguided_8dhw = find(unchanged_vars&(out_45.inputs.Aadpt==8)& ...
                    (out_45.inputs.Guided==0));

tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)& ...
                    (out_45.inputs.Shadeyr_start==2)& ...
                    (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Seedfreq==0)& ...
                    (out_45.inputs.Shadeyrs==20)& ...
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Seed1==0)& ...
                    (out_45.inputs.Seed2==0)& ...
                    (out_45.inputs.fogging==0)& ...
                    (out_45.inputs.Natad==0.0)& ...
                    (out_45.inputs.Aadpt==0)& ...
                    (out_45.inputs.Guided==0));

%% Use indices to select RCI's and calculate delta RCI
metric = "total_cover"
if strcmp(metric,"RCI")
    plotxaxis = "RCI"
elseif strcmp(metric,"total_cover")
    plotxaxis = "Coral Cover"
end
selected_int_RCI_Guided_0dhw = filterSummary(out_45.(metric), tgt_ind_int_Guided_0dhw);
selected_int_RCI_Guided_4dhw = filterSummary(out_45.(metric), tgt_ind_int_Guided_4dhw);
selected_int_RCI_Guided_8dhw = filterSummary(out_45.(metric), tgt_ind_int_Guided_8dhw);

selected_int_RCI_Unguided_0dhw = filterSummary(out_45.(metric), tgt_ind_int_Unguided_0dhw);
selected_int_RCI_Unguided_4dhw = filterSummary(out_45.(metric), tgt_ind_int_Unguided_4dhw);
selected_int_RCI_Unguided_8dhw = filterSummary(out_45.(metric), tgt_ind_int_Unguided_8dhw);

selected_cf_RCI = filterSummary(out_45.(metric), tgt_ind_cf);

deltaRCI_Guided_0dhw = median(selected_int_RCI_Guided_0dhw.mean(time_slice,:)-selected_cf_RCI.mean(time_slice,:),1);
deltaRCI_Guided_4dhw = median(selected_int_RCI_Guided_4dhw.mean(time_slice,:)-selected_cf_RCI.mean(time_slice,:),1);
deltaRCI_Guided_8dhw = median(selected_int_RCI_Guided_8dhw.mean(time_slice,:)-selected_cf_RCI.mean(time_slice,:),1);

deltaRCI_Unguided_0dhw = median(selected_int_RCI_Unguided_0dhw.mean(time_slice,:)-selected_cf_RCI.mean(time_slice,:),1);
deltaRCI_Unguided_4dhw = median(selected_int_RCI_Unguided_4dhw.mean(time_slice,:)-selected_cf_RCI.mean(time_slice,:),1);
deltaRCI_Unguided_8dhw = median(selected_int_RCI_Unguided_8dhw.mean(time_slice,:)-selected_cf_RCI.mean(time_slice,:),1);

%% Retreive indices of top 20 performing site

    [~,top20_Unguided_0dhw_sites] = maxk(deltaRCI_Unguided_0dhw,20,2);
    [~,top20_Unguided_4dhw_sites] = maxk(deltaRCI_Unguided_4dhw,20,2);
    [~,top20_Unguided_8dhw_sites] = maxk(deltaRCI_Unguided_8dhw,20,2);
    
    [~,top20_Guided_0dhw_sites] = maxk(deltaRCI_Guided_0dhw,20,2);
    [~,top20_Guided_4dhw_sites] = maxk(deltaRCI_Guided_4dhw,20,2);
    [~,top20_Guided_8dhw_sites] = maxk(deltaRCI_Guided_8dhw,20,2);

    top20perf_Unguided_0dhw = deltaRCI_Unguided_0dhw(:,top20_Unguided_0dhw_sites);
    top20perf_Unguided_4dhw = deltaRCI_Unguided_4dhw(:,top20_Unguided_4dhw_sites);
    top20perf_Unguided_8dhw = deltaRCI_Unguided_8dhw(:,top20_Unguided_8dhw_sites);
    
    top20perf_Guided_0dhw = deltaRCI_Guided_0dhw(:,top20_Guided_0dhw_sites);
    top20perf_Guided_4dhw = deltaRCI_Guided_4dhw(:,top20_Guided_4dhw_sites);
    top20perf_Guided_8dhw = deltaRCI_Guided_8dhw(:,top20_Guided_8dhw_sites);

    top20_Guided_0dhw_site_ranks = squeeze(mean(out_45.site_rankings(:,:,1,tgt_ind_int_Guided_0dhw),1));
    top20_Guided_0dhw_sites = sortrows([(1:561)', top20_Guided_0dhw_site_ranks'],2,'ascend');
    top20ranks_Guided_0dhw_sites = top20_Guided_0dhw_sites(1:20,1);
    
    top20_Guided_4dhw_site_ranks = squeeze(mean(out_45.site_rankings(:,:,1,tgt_ind_int_Guided_4dhw),1));
    top20_Guided_4dhw_sites = sortrows([(1:561)', top20_Guided_4dhw_site_ranks'],2,'ascend');
    top20ranks_Guided_4dhw_sites = top20_Guided_4dhw_sites(1:20,1);
    
    top20_Guided_8dhw_site_ranks = squeeze(mean(out_45.site_rankings(:,:,1,tgt_ind_int_Guided_8dhw),1));
    top20_Guided_8dhw_sites = sortrows([(1:561)', top20_Guided_8dhw_site_ranks'],2,'ascend');
    top20ranks_Guided_8dhw_sites = top20_Guided_8dhw_sites(1:20,1);

    top20ranks_Unguided_0dhw = deltaRCI_Unguided_0dhw(:,top20ranks_Guided_0dhw_sites);
    top20ranks_Unguided_4dhw = deltaRCI_Unguided_4dhw(:,top20ranks_Guided_4dhw_sites);
    top20ranks_Unguided_8dhw = deltaRCI_Unguided_8dhw(:,top20ranks_Guided_8dhw_sites);
    
    top20ranks_Guided_0dhw = deltaRCI_Guided_0dhw(:,top20ranks_Guided_0dhw_sites);
    top20ranks_Guided_4dhw = deltaRCI_Guided_4dhw(:,top20ranks_Guided_4dhw_sites);
    top20ranks_Guided_8dhw = deltaRCI_Guided_8dhw(:,top20ranks_Guided_8dhw_sites);



%% Plotting 2*2 violin plot
dhw = [1,2,3];
%['0 DHW','4DHW','8DHW']
deltaRCI_Unguided = [deltaRCI_Unguided_0dhw(:), deltaRCI_Unguided_4dhw(:), deltaRCI_Unguided_8dhw(:)];
deltaRCI_Guided = [deltaRCI_Guided_0dhw(:), deltaRCI_Guided_4dhw(:), deltaRCI_Guided_8dhw(:)];
deltaRCI_Unguided_top20perf = [top20perf_Unguided_0dhw(:), top20perf_Unguided_4dhw(:), top20perf_Unguided_8dhw(:)];
deltaRCI_Guided_top20perf = [top20perf_Guided_0dhw(:), top20perf_Guided_4dhw(:), top20perf_Guided_8dhw(:)];
deltaRCI_Unguided_top20ranks = [top20ranks_Unguided_0dhw(:), top20ranks_Unguided_4dhw(:), top20ranks_Unguided_8dhw(:)];
deltaRCI_Guided_top20ranks = [top20ranks_Guided_0dhw(:), top20ranks_Guided_4dhw(:), top20ranks_Guided_8dhw(:)];

col1 = cols(2,:);
col2 = cols(1,:);

figure(4)
t = tiledlayout(3,2)
t.TileSpacing = 'compact';

nexttile
hold on
al_goodplot(deltaRCI_Unguided, dhw, 0.5, col1);
xlim([0,4]);
ylim([0,0.6]);
xlabel('Assisted Adaptation','Fontsize',14,'Interpreter','latex');
ylabel(strcat("$\delta ", plotxaxis," $"),'Fontsize',14,'Interpreter','latex');
xticks([1 2 3]);
xticklabels({'0 DHW','4 DHW','8 DHW'});
title('Unguided, full domain','Fontsize',16,'Interpreter','latex');
hold off

nexttile
hold on
al_goodplot(deltaRCI_Guided, dhw, 0.5, col2);
xlim([0,4]);
ylim([0,0.6]);
xlabel('Assisted Adaptation','Fontsize',14,'Interpreter','latex');
ylabel(strcat("$\delta ", plotxaxis," $"),'Fontsize',14,'Interpreter','latex');
xticks([1 2 3]);
xticklabels({'0 DHW','4 DHW','8 DHW'});
title('Guided, full domain','Fontsize',16,'Interpreter','latex');
hold off

nexttile
hold on
al_goodplot(deltaRCI_Unguided_top20perf, dhw, 0.5, col1);
xlim([0,4]);
ylim([0,0.6]);
xlabel('Assisted Adaptation','Fontsize',14,'Interpreter','latex');
ylabel(strcat("$\delta ", plotxaxis," $"),'Fontsize',14,'Interpreter','latex');
xticks([1 2 3]);
xticklabels({'0 DHW','4 DHW','8 DHW'});
title(strcat("Unguided, top 20 performing sites"),'Fontsize',16,'Interpreter','latex');
hold off

nexttile
hold on
al_goodplot(deltaRCI_Guided_top20perf, dhw, 0.5, col2);
xlim([0,4]);
ylim([0,0.6]);
xlabel('Assisted Adaptation','Fontsize',14,'Interpreter','latex');
ylabel(strcat("$\delta ", plotxaxis," $"),'Fontsize',14,'Interpreter','latex');
xticks([1 2 3]);
xticklabels({'0 DHW','4 DHW','8 DHW'});
title(strcat("Guided, top 20 performing sites"),'Fontsize',16,'Interpreter','latex');
hold off

nexttile
hold on
al_goodplot(deltaRCI_Unguided_top20ranks, dhw, 0.5, col1);
xlim([0,4]);
ylim([0,0.6]);
xlabel('Assisted Adaptation','Fontsize',14,'Interpreter','latex');
ylabel(strcat("$\delta ", plotxaxis," $"),'Fontsize',14,'Interpreter','latex');
xticks([1 2 3]);
xticklabels({'0 DHW','4 DHW','8 DHW'});
title(strcat("Unguided, top 20 ranked sites"),'Fontsize',16,'Interpreter','latex');
hold off

nexttile
hold on
al_goodplot(deltaRCI_Guided_top20ranks, dhw, 0.5, col2);
xlim([0,4]);
ylim([0,0.6]);
xlabel('Assisted Adaptation','Fontsize',14,'Interpreter','latex');
ylabel(strcat("$\delta ", plotxaxis," $"),'Fontsize',14,'Interpreter','latex');
xticks([1 2 3]);
xticklabels({'0 DHW','4 DHW','8 DHW'});
title(strcat("Guided, top 20 ranked sites"),'Fontsize',16,'Interpreter','latex');
hold off

%% Plots of different start years for seeding and shading

unchanged_vars = (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Aadpt==4)& ...
                    (out_45.inputs.Seedfreq==0)& ...                    
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Seed1==500000)& ...
                    (out_45.inputs.Seed2==500000)& ...
                    (out_45.inputs.Natad==0.0)& ...
                    (out_45.inputs.Guided==1);

tgt_ind_int_seedyr2 = find(unchanged_vars&(out_45.inputs.Seedyr_start==2)& ...
    (out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadeyrs==20)&...
     (out_45.inputs.fogging==0));
tgt_ind_int_seedyr6 = find(unchanged_vars&(out_45.inputs.Seedyr_start==6)& ...
    (out_45.inputs.Shadeyr_start==6)&(out_45.inputs.Shadeyrs==20)&...
     (out_45.inputs.fogging==0));
tgt_ind_int_seedyr11 = find(unchanged_vars&(out_45.inputs.Seedyr_start==11)& ...
    (out_45.inputs.Shadeyr_start==11)&(out_45.inputs.Shadeyrs==20)&...
     (out_45.inputs.fogging==0));
tgt_ind_int_seedyr16 = find(unchanged_vars&(out_45.inputs.Seedyr_start==16)& ...
    (out_45.inputs.Shadeyr_start==16)&(out_45.inputs.Shadeyrs==20)&...
     (out_45.inputs.fogging==0));

tgt_ind_int_seedfogyr2 = find(unchanged_vars&(out_45.inputs.Seedyr_start==2)& ...
    (out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadeyrs==74)&...
     (out_45.inputs.fogging==0.2));
tgt_ind_int_seedfogyr6 = find(unchanged_vars&(out_45.inputs.Seedyr_start==6)& ...
    (out_45.inputs.Shadeyr_start==6)&(out_45.inputs.Shadeyrs==74)&...
     (out_45.inputs.fogging==0.2));
tgt_ind_int_seedfogyr11 = find(unchanged_vars&(out_45.inputs.Seedyr_start==11)& ...
    (out_45.inputs.Shadeyr_start==11)&(out_45.inputs.Shadeyrs==74)&...
     (out_45.inputs.fogging==0.2));
tgt_ind_int_seedfogyr16 = find(unchanged_vars&(out_45.inputs.Seedyr_start==16)& ...
    (out_45.inputs.Shadeyr_start==16)&(out_45.inputs.Shadeyrs==74)&...
     (out_45.inputs.fogging==0.2));

tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)& ...
                    (out_45.inputs.Shadeyr_start==2)& ...
                    (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Seedfreq==0)& ...
                    (out_45.inputs.Shadeyrs==20)& ...
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Seed1==0)& ...
                    (out_45.inputs.Seed2==0)& ...
                    (out_45.inputs.fogging==0)& ...
                    (out_45.inputs.Natad==0.0)& ...
                    (out_45.inputs.Aadpt==0)& ...
                    (out_45.inputs.Guided==0));
%% Load site data
ai = ADRIA()
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/', cutoff=0.01);
ai.loadCoralCovers("./Inputs/Brick/site_data/coralCoverBrickTruncated.mat");
areas = ai.site_data.area;
areas_large = repmat(areas',74,1);
%% plotting
yr = linspace(2026,2099,74);
selected_int_seedyr2 = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int_seedyr2);
selected_int_seedyr6 = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int_seedyr6);
selected_int_seedyr11 = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int_seedyr11);
selected_int_seedyr16 = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int_seedyr16);

selected_int_seedfogyr2 = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int_seedfogyr2);
selected_int_seedfogyr6 = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int_seedfogyr6);
selected_int_seedfogyr11 = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int_seedfogyr11);
selected_int_seedfogyr16 = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int_seedfogyr16);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_cf);

cols2 = parula(10);
figure(4)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';

nexttile
hold on
plot(yr,mean(selected_int_seedyr2.mean,2)-mean(selected_cf_TC.mean,2),'Color',cols2(4,:),'LineWidth',2)
plot(yr,mean(selected_int_seedyr6.mean,2)-mean(selected_cf_TC.mean,2),'Color',cols2(5,:),'LineWidth',2)
plot(yr,mean(selected_int_seedyr11.mean,2)-mean(selected_cf_TC.mean,2),'Color',cols2(9,:),'LineWidth',2)
plot(yr,mean(selected_int_seedyr16.mean,2)-mean(selected_cf_TC.mean,2),'Color',[255/255,102/255,102/255],'LineWidth',2)
l = legend('2026','2031','2036','2040')
set(l,'Interpreter','latex','Fontsize',18)
xlabel('Year','Interpreter','latex','Fontsize',18)
ylabel('$\delta$ mean coral cover (prop.)','Interpreter','latex','Fontsize',16)
ax = gca;
ax.FontSize = 18;
ax.YAxis.Exponent=0;
ytickformat('%1.3f')
hold off

nexttile
hold on
plot(yr,mean(selected_int_seedyr2.mean.*areas_large,2)-mean(selected_cf_TC.mean.*areas_large,2),'Color',cols2(4,:),'LineWidth',2)
plot(yr,mean(selected_int_seedyr6.mean.*areas_large,2)-mean(selected_cf_TC.mean.*areas_large,2),'Color',cols2(5,:),'LineWidth',2)
plot(yr,mean(selected_int_seedyr11.mean.*areas_large,2)-mean(selected_cf_TC.mean.*areas_large,2),'Color',cols2(9,:),'LineWidth',2)
plot(yr,mean(selected_int_seedyr16.mean.*areas_large,2)-mean(selected_cf_TC.mean.*areas_large,2),'Color',[255/255,102/255,102/255],'LineWidth',2)
xlabel('Year','Interpreter','latex','Fontsize',18)
ylabel('$\delta$ mean coral cover (hectares)','Interpreter','latex','Fontsize',16)
ax = gca;
ax.FontSize = 18;
hold off

nexttile
hold on
plot(yr,mean(selected_int_seedfogyr2.mean,2)-mean(selected_cf_TC.mean,2),'Color',cols2(4,:),'LineWidth',2)
plot(yr,mean(selected_int_seedfogyr6.mean,2)-mean(selected_cf_TC.mean,2),'Color',cols2(5,:),'LineWidth',2)
plot(yr,mean(selected_int_seedfogyr11.mean,2)-mean(selected_cf_TC.mean,2),'Color',cols2(9,:),'LineWidth',2)
plot(yr,mean(selected_int_seedfogyr16.mean,2)-mean(selected_cf_TC.mean,2),'Color',[255/255,102/255,102/255],'LineWidth',2)
xlabel('Year','Interpreter','latex','Fontsize',18)
ylabel('$\delta$ mean coral cover (prop.)','Interpreter','latex','Fontsize',16)
ax = gca;
ax.FontSize = 18;
hold off

nexttile
hold on
plot(yr,mean(selected_int_seedfogyr2.mean.*areas_large,2)-mean(selected_cf_TC.mean.*areas_large,2),'Color',cols2(4,:),'LineWidth',2)
plot(yr,mean(selected_int_seedfogyr6.mean.*areas_large,2)-mean(selected_cf_TC.mean.*areas_large,2),'Color',cols2(5,:),'LineWidth',2)
plot(yr,mean(selected_int_seedfogyr11.mean.*areas_large,2)-mean(selected_cf_TC.mean.*areas_large,2),'Color',cols2(9,:),'LineWidth',2)
plot(yr,mean(selected_int_seedfogyr16.mean.*areas_large,2)-mean(selected_cf_TC.mean.*areas_large,2),'Color',[255/255,102/255,102/255],'LineWidth',2)
xlabel('Year','Interpreter','latex','Fontsize',18)
ylabel('$\delta$ mean coral cover (hectares)','Interpreter','latex','Fontsize',16)
ax = gca;
ax.FontSize = 18;
hold off