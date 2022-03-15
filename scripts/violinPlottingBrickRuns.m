%% Loading counterfactual and intervention data
out_cfs_45 = load('./Outputs/brick_runs_RCP45_CFs.mat');
out_intervs_45 = load('./Outputs/brick_runs_RCP45_intervs.mat');

%% Extracting interventions of interest
% extract guided = 1 and guided = 0
tab_temp = table2array(out_intervs_45.inputs);
tab_temp = tab_temp(out_intervs_45.collected_scenarios,:);
tab_temp_cf = table2array(out_cfs_45.inputs);
tab_temp_cf = tab_temp_cf(out_cfs_45.collected_scenarios,:);
% scenarios where seeding>0 and is guided intervention
index_s1s2g1 = find(ismember(ismember(tab_temp(:,2)>0,tab_temp(:,3)>0),tab_temp(:,1)==1));


mean_CC = squeeze(mean(mean(out_intervs_45.coralTaxaCover_x_p_total_cover.mean,1),3));
% mean ranks over years and scenarios
site_rankings = squeeze(mean(mean(site_rankings,1),4));
site_vec = [(1:561)',mean_CC'];
ranks = sortrows(site_vec,2,'descend');
inds_sites = ranks(1:20,1);
%% Trajectory plots
index = find(ismember(ismember(ismember(ismember(tab_temp(:,2)==400,...
    tab_temp(:,3)==400),tab_temp(:,6)==8),...
    tab_temp(:,1)==1),tab_temp(:,7)==0.05));
metric = struct('mean',out_intervs_45.coralTaxaCover_x_p_total_cover.mean(:,inds_sites,index),...
    'median',out_intervs_45.coralTaxaCover_x_p_total_cover.median(:,inds_sites,index),...
    'std',out_intervs_45.coralTaxaCover_x_p_total_cover.std(:,inds_sites,index), ...
     'min', out_intervs_45.coralTaxaCover_x_p_total_cover.min(:,inds_sites,index),...
     'max',out_intervs_45.coralTaxaCover_x_p_total_cover.max(:,inds_sites,index))
fig = plotTrajectory(metric)

index_cf = find(ismember(ismember(ismember(ismember(tab_temp_cf(:,2)==0,...
    tab_temp_cf(:,3)==0),tab_temp_cf(:,6)==0),...
    tab_temp_cf(:,1)==0),tab_temp_cf(:,7)==0));
metric_cf = struct('mean',out_intervs_45.coralTaxaCover_x_p_total_cover.mean(:,inds_sites,index_cf),...
    'median',out_cfs_45.coralTaxaCover_x_p_total_cover.median(:,inds_sites,index_cf),...
    'std',out_cfs_45.coralTaxaCover_x_p_total_cover.std(:,inds_sites,index_cf), ...
     'min', out_cfs_45.coralTaxaCover_x_p_total_cover.min(:,inds_sites,index_cf),...
     'max',out_cfs_45.coralTaxaCover_x_p_total_cover.max(:,inds_sites,index_cf))
fig = plotTrajectory(metric_cf)
%% Violin plots
% plotting seeding vs counterfactual
yr = linspace(2026,2099,74);

% CoralTaxaCover_x_p_total_cover
% mean over sites
mean_TC_s1s2g1_yrs = squeeze(mean(out_intervs_45.coralTaxaCover_x_p_total_cover.mean(:,:,index_s1s2g1),2));
% mean over sites cf
mean_TC_cf_yrs = squeeze(mean(out_cfs_45.coralTaxaCover_x_p_total_cover.mean,2));

% plot every 5 yrs
figure(1)
hold on
al_goodplot(mean_TC_s1s2g1_yrs(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(mean_TC_cf_yrs(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.3])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Mean coral cover','Fontsize',16,'Interpreter','latex')
title('Mean coral cover, seeding vs. counterfactual','Fontsize',16,'Interpreter','latex')
hold off

% coralTaxaCover_x_p_juveniles
% mean over sites
mean_Ju_s1s2g1_yrs = squeeze(mean(out_intervs_45.coralTaxaCover_x_p_juveniles.mean(:,:,index_s1s2g1),2));
% mean over sites cf
mean_Ju_cf_yrs = squeeze(mean(out_cfs_45.coralTaxaCover_x_p_juveniles.mean,2));

% plot every 5 yrs
figure(2)
hold on
al_goodplot(mean_Ju_s1s2g1_yrs(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(mean_Ju_cf_yrs(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.035])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Mean Juveniles','Fontsize',16,'Interpreter','latex')
title('Mean Juveniles, seeding vs. counterfactual','Fontsize',16,'Interpreter','latex')
hold off

%coralEvenness
% mean over sites
mean_Ev_s1s2g1_yrs = squeeze(mean(out_intervs_45.coralEvenness.mean(:,:,index_s1s2g1),2));
% mean over sites cf
mean_Ev_cf_yrs = squeeze(mean(out_cfs_45.coralEvenness.mean,2));

% plot every 5 yrs
figure(3)
hold on
al_goodplot(mean_Ev_s1s2g1_yrs(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(mean_Ev_cf_yrs(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.9])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Mean Evenness','Fontsize',16,'Interpreter','latex')
title('Mean Evenness, seeding vs. counterfactual','Fontsize',16,'Interpreter','latex')
hold off

%shelterVolume
% mean over sites
mean_SV_s1s2g1_yrs = squeeze(mean(out_intervs_45.shelterVolume.mean(:,:,index_s1s2g1),2));
% mean over sites cf
mean_SV_cf_yrs = squeeze(mean(out_cfs_45.shelterVolume.mean,2));

% plot every 5 yrs
figure(4)
hold on
al_goodplot(mean_SV_s1s2g1_yrs(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(mean_SV_cf_yrs(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.15])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Mean Shelter Volume','Fontsize',16,'Interpreter','latex')
title('Mean Shelter Volume, seeding vs. counterfactual','Fontsize',16,'Interpreter','latex')
hold off

%% Make data table for BBNs and polar plots, using 15 best sites and 15 worst sites for seeding
% extract site rankings for seeding, where seeding is used (seeding>0 and guided)
% site_rankings = out_intervs_45.site_rankings(:,:,1,index_s1s2g1);
mean_CC = squeeze(mean(mean(out_intervs_45.coralTaxaCover_x_p_total_cover.mean,1),3));
% mean ranks over years and scenarios
site_rankings = squeeze(mean(mean(site_rankings,1),4));
site_vec = [(1:561)',mean_CC'];
ranks = sortrows(site_vec,2,'descend');
yr_5 = yr(1:5:end);

% best 15 and worst 15 according to average ranks
% top15 = ranks(1:15,1);
% last15 = ranks(end-15:end,1);
% sites = [top15;last15];
top30 = ranks(1:30,1);
index_g1 = out_intervs_45.collected_scenarios;
index_cf = out_cfs_45.collected_scenarios;
N = length(yr_5)*length(top30)*length(index_g1);
M = length(yr_5)*length(top30)*length(index_cf);
tab_temp = table2array(out_intervs_45.inputs);
tab_temp_cf = table2array(out_cfs_45.inputs);
% create intervention data table with:
% ['Year','Site','Guided','Seed1','Seed2','AssAdt','Natad','CoralCover',...
% 'Evenness','ShelterVol','Juveniles']
% create storage container
dat_tab_store = zeros(N,11);
dat_tab_store_cf = zeros(M,11);
count = 0;
for yy = 1:length(yr_5)
    for ss = 1:length(top30)
        for ii = 1:length(index_g1)
            count = count +1;
            dat_tab_store(count,1) = yr_5(yy);
            dat_tab_store(count,2) = ss;
            dat_tab_store(count,3:7) = tab_temp(index_g1(ii),[1:3,6:7]);
            dat_tab_store(count,8) = out_intervs_45.coralTaxaCover_x_p_total_cover.mean(yy,top30(ss),ii);
            dat_tab_store(count,9) = out_intervs_45.coralEvenness.mean(yy,top30(ss),ii);
            dat_tab_store(count,10) = out_intervs_45.shelterVolume.mean(yy,top30(ss),ii);
            dat_tab_store(count,11) = out_intervs_45.coralTaxaCover_x_p_juveniles.mean(yy,top30(ss),ii);

        end
    end
end

% count = 0;
% for yy = 1:length(yr_5)
%     for ss = 1:length(top30)
%         for ii = 1:length(index_cf)
%             count = count +1;
%             dat_tab_store_cf(count,1) = yr_5(yy);
%             dat_tab_store_cf(count,2) = ss;
%             dat_tab_store_cf(count,3:7) = tab_temp_cf(index_cf(ii),[1:3,6:7]);
%             dat_tab_store_cf(count,8) = out_cfs_45.coralTaxaCover_x_p_total_cover.mean(yy,top30(ss),ii);
%             dat_tab_store_cf(count,9) = out_cfs_45.coralEvenness.mean(yy,top30(ss),ii);
%             dat_tab_store_cf(count,10) = out_cfs_45.shelterVolume.mean(yy,top30(ss),ii);
%             dat_tab_store_cf(count,11) = out_cfs_45.coralTaxaCover_x_p_juveniles.mean(yy,top30(ss),ii);
% 
%         end
%     end
% end

%% Create BBNs using data
% first create BBN structure
names = {'Year';'Site';'Guided';'Seed1';'Seed2';'AssAdt';'NatAdt';'CC';'Ev';'SV';'Ju'};
nnodes = length(names)
parent_cell = cell(1, nnodes);
for i = 1:(nnodes-4)
    parent_cell{i} = [];
end
parent_cell{nnodes-3} = 1:(nnodes-4);
parent_cell{nnodes-2} = 1:(nnodes-4);
parent_cell{nnodes-1} = 1:(nnodes-4);
parent_cell{nnodes} = 1:(nnodes-4);

R = bn_rankcorr(parent_cell, dat_tab_store, 1, 1, names);

figure(2);
% plot the bbn as a network with the rank correlation matrix values as
% weightings
bn_visualize(parent_cell, R, names, gca);

%% BBN inferences
increArray = [2026,2041,2066];
knownVars =[1,400,400,4,0.05];
inf_cells = [1,3:7];
nodePos = 1;
F = multiBBNInf(dat_tab_store,R,knownVars,inf_cells,increArray,nodePos);

knownVars =[0,0,0,0,0];
F_cf = multiBBNInf(dat_tab_store,R,knownVars,inf_cells,increArray,nodePos);

% plots comparing coral cover for intervention and cf
figure(3)
hold on 
subplot(1,2,1)
plotHistMulti(F,2)
ylim([0,0.45])
xlim([0,1])
xlabel('Mean coral cover, Interv.','Fontsize',12,'Interpreter','latex')
h = legend('2026','2041','2066')
set(h,'Interpreter','latex','Fontsize',12)
subplot(1,2,2)
plotHistMulti(F_cf,2)
ylim([0,0.45])
xlim([0,1])
h = legend('2026','2041','2066')
set(h,'Interpreter','latex','Fontsize',12)
xlabel('Mean coral cover, CF','Fontsize',12,'Interpreter','latex')

figure(4)
hold on 
subplot(1,2,1)
plotHistMulti(F,4)
ylim([0,0.35])
xlim([0,0.3])
xlabel('Mean SV, Interv.','Fontsize',12,'Interpreter','latex')
h = legend('2026','2041','2066')
set(h,'Interpreter','latex','Fontsize',12)
subplot(1,2,2)
plotHistMulti(F_cf,4)
ylim([0,0.35])
xlim([0,0.3])
h = legend('2026','2041','2066')
set(h,'Interpreter','latex','Fontsize',12)
xlabel('Mean SV CF','Fontsize',12,'Interpreter','latex')
