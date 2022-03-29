%% Loading counterfactual and intervention data
out_45 = load('./Outputs/brick_runs_RCP45_2.mat');
out_45_RCI = load('./Outputs/brick_runs_RCP45_RCI.mat');
%% Indices for runs of interest
tgt_ind = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.fogging==0));
%% Make data table for BBNs and polar plots, using 15 best sites and 15 worst sites for seeding

sites = 1:561;
yrs = (1:74)+2025;

tab_temp = table2array(out_45.inputs);
tab_temp = tab_temp(tgt_ind,:);
N = length(yrs)*length(sites)*size(tab_temp,1);

% create intervention data table with:
% ['Year','Site','Guided','Seed1','Seed2','AssAdt','Natad','CoralCover',...
% 'Evenness','ShelterVol','Juveniles',RCI']
nnodes = 12;
% create storage container
dat_tab_store = zeros(N,nnodes);
count = 0;
for yy = 1:length(yrs)
    for ss = 1:length(sites)
        for ii = 1:size(tab_temp,1)
            count = count + 1;
            dat_tab_store(count,1) = yy;
            dat_tab_store(count,2) = ss;
            dat_tab_store(count,3:7) = tab_temp(ii,[1:3,6:7]);
            dat_tab_store(count,8) = out_45.coralTaxaCover_x_p_total_cover.mean(yy,sites(ss),tgt_ind(ii));
            dat_tab_store(count,9) = out_45.coralEvenness.mean(yy,sites(ss),tgt_ind(ii));
            dat_tab_store(count,10) = out_45.shelterVolume.mean(yy,sites(ss),tgt_ind(ii));
            dat_tab_store(count,11) = out_45.coralTaxaCover_x_p_juveniles.mean(yy,sites(ss),tgt_ind(ii));
            dat_tab_store(count,12) = out_45_RCI.mean(yy,sites(ss),tgt_ind(ii));

        end
    end
end

%% Create BBNs using data
% first create BBN structure
names = {'Year';'Site';'Guided';'Seed1';'Seed2';'AssAdt';'NatAdt';'CC';'Ev';'SV';'Ju';'RCI'};
parent_cell = cell(1, nnodes);
nmetrics = 5;
for i = 1:(nnodes-nmetrics)
    parent_cell{i} = [];
end
for k = 0:nmetrics-1
    parent_cell{nnodes-(k)} = 1:(nnodes-nmetrics);
end

R = bn_rankcorr(parent_cell, dat_tab_store, 1, 1, names);

figure(2);
% plot the bbn as a network with the rank correlation matrix values as
% weightings
bn_visualize(parent_cell, R, names, gca);

%% BBN inferences
increArray = [10, 20, 30];
knownVars =[1,500000,500000,8,0];
inf_cells = [1,3:7];
nodePos = 1;
F = multiBBNInf(dat_tab_store,R,knownVars,inf_cells,increArray,nodePos);

knownVars =[0,500000,500000,8,0];
F_cf = multiBBNInf(dat_tab_store,R,knownVars,inf_cells,increArray,nodePos);

%% plots comparing coral cover for intervention and cf
figure(3)
hold on 
subplot(1,2,1)
plotHistMulti(F,2)
ylim([0,0.45])
xlim([0,1])
xlabel('Mean coral cover, Interv.','Fontsize',12,'Interpreter','latex')
h = legend('Site 404','Site 39','Site 36','Site 50','Site 62','Site 49','Site 42','Site 58','Site 41')
set(h,'Interpreter','latex','Fontsize',12)
subplot(1,2,2)
plotHistMulti(F_cf,2)
ylim([0,0.45])
xlim([0,1])
h = legend('Site 404','Site 39','Site 36','Site 50','Site 62','Site 49','Site 42','Site 58','Site 41')
set(h,'Interpreter','latex','Fontsize',12)
xlabel('Mean coral cover, CF','Fontsize',12,'Interpreter','latex')

figure(4)
hold on 
subplot(1,2,1)
plotHistMulti(F,6)
ylim([0,0.45])
xlim([0,0.3])
xlabel('RCI Interv.','Fontsize',12,'Interpreter','latex')
h = legend('Site 404','Site 39','Site 36','Site 50','Site 62','Site 49','Site 42','Site 58','Site 41')
set(h,'Interpreter','latex','Fontsize',12)
subplot(1,2,2)
plotHistMulti(F_cf,6)
ylim([0,0.45])
xlim([0,0.3])
h = legend('Site 404','Site 39','Site 36','Site 50','Site 62','Site 49','Site 42','Site 58','Site 41')
set(h,'Interpreter','latex','Fontsize',12)
xlabel('RCI CF','Fontsize',12,'Interpreter','latex')
%% Fogging BBN
fog_runs = load("./Outputs/reruns_long_fog_brick_scens.mat");

sites = 1:561;
yrs = (1:74)+2025;
% seed1,seed2,fog,aadpt,natad
inputs_tab = []
tab_temp = table2array(out_45.inputs);
tab_temp = tab_temp(tgt_ind,:);
N = length(yrs)*length(sites)*size(tab_temp,1);

% create intervention data table with:
% ['Year','Site','Guided','Seed1','Seed2','AssAdt','Natad','CoralCover',...
% 'Evenness','ShelterVol','Juveniles',RCI']
nnodes = 12;
% create storage container
dat_tab_store = zeros(N,nnodes);
count = 0;
for yy = 1:length(yrs)
    for ss = 1:length(sites)
        for ii = 1:size(tab_temp,1)
            count = count + 1;
            dat_tab_store(count,1) = yy;
            dat_tab_store(count,2) = ss;
            dat_tab_store(count,3:7) = tab_temp(ii,[1:3,6:7]);
            dat_tab_store(count,8) = out_45.coralTaxaCover_x_p_total_cover.mean(yy,sites(ss),tgt_ind(ii));
            dat_tab_store(count,9) = out_45.coralEvenness.mean(yy,sites(ss),tgt_ind(ii));
            dat_tab_store(count,10) = out_45.shelterVolume.mean(yy,sites(ss),tgt_ind(ii));
            dat_tab_store(count,11) = out_45.coralTaxaCover_x_p_juveniles.mean(yy,sites(ss),tgt_ind(ii));
            dat_tab_store(count,12) = out_45_RCI.mean(yy,sites(ss),tgt_ind(ii));

        end
    end
end
