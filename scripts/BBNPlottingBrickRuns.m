%% Loading counterfactual and intervention data
out_45 = load('./Outputs/brick_runs_RCP45.mat');

%% Make data table for BBNs and polar plots, using 15 best sites and 15 worst sites for seeding
% extract site rankings for seeding, where seeding is used (seeding>0 and guided)
% site_rankings = out_45.site_rankings(:,:,1,index_s1s2g1);
%mean_CC = squeeze(mean(mean(out_45.coralTaxaCover_x_p_total_cover.mean,1),3));
% mean ranks over years and scenarios
% site_rankings = squeeze(mean(mean(site_rankings,1),4));
% site_vec = [(1:561)',mean_CC'];
% ranks = sortrows(site_vec,2,'descend');

% select 50 random sites
sites = randperm(561,50);
yr_5 = yr;
%(1:5:end);

% best 15 and worst 15 according to average ranks
% top15 = ranks(1:15,1);
% last15 = ranks(end-15:end,1);
% sites = [top15;last15];
%top30 = ranks(1:30,1);
tab_temp = table2array(out_45.inputs);
N = length(yr_5)*length(sites)*size(tab_temp,1);
tab_temp = table2array(out_45.inputs);

% create intervention data table with:
% ['Year','Site','Guided','Seed1','Seed2','AssAdt','Natad','CoralCover',...
% 'Evenness','ShelterVol','Juveniles']
% create storage container
dat_tab_store = zeros(N,17);
count = 0;
for yy = 1:length(yr_5)
    for ss = 1:length(sites)
        for ii = 1:size(tab_temp,1)
            count = count +1;
            dat_tab_store(count,1) = yy;
            dat_tab_store(count,2) = ss;
            dat_tab_store(count,3:8) = tab_temp(ii,[1:4,6:7]);
            dat_tab_store(count,9) = out_45.coralTaxaCover_x_p_total_cover.mean(yy,sites(ss),ii);
            dat_tab_store(count,10) = out_45.coralEvenness.mean(yy,sites(ss),ii);
            dat_tab_store(count,11) = out_45.shelterVolume.mean(yy,sites(ss),ii);
            dat_tab_store(count,12) = out_45.coralTaxaCover_x_p_juveniles.mean(yy,sites(ss),ii);

        end
    end
end

%% Create BBNs using data
% first create BBN structure
names = {'Year';'Site';'Guided';'Seed1';'Seed2';'fog';'AssAdt';'NatAdt';'CC';'Ev';'SV';'Ju'};
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
increArray = [5,10,15];
knownVars =[0,500000,500000,2,0.05];
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