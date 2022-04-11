%% Loading counterfactual and intervention data
out_45 = load('./Outputs/RCP45_redux.mat');

%% Indices for runs of interest
tgt_ind = find((out_45.inputs.Shadefreq==1)& ...
                (out_45.inputs.Seedfreq==0)& ...
                (out_45.inputs.Shadeyrs==74)& ...
                (out_45.inputs.Seedyrs==5));

% make sure counterfactual is in runs
tgt_ind_cf = find((out_45.inputs.Shadefreq==1)& ...
                  (out_45.inputs.Seedfreq==0)& ...
                  (out_45.inputs.Shadeyrs==20)& ...
                  (out_45.inputs.Seedyrs==5)& ...
                  (out_45.inputs.Shadeyr_start==2)&...
                  (out_45.inputs.Seedyr_start==2)&...
                  (out_45.inputs.Seed1==0)& ...
                  (out_45.inputs.Seed2==0)& ...
                  (out_45.inputs.fogging==0)& ...
                  (out_45.inputs.Natad==0)& ...
                  (out_45.inputs.Aadpt==0)& ...
                  (out_45.inputs.Guided==0));
%% Make data table for BBNs and polar plots, using 15 best sites and 15 worst sites for seeding

sites = 1:561;
yrs = (1:74)+2025;

tab_temp_full = table2array(out_45.inputs);
tab_temp = tab_temp_full(tgt_ind,:);
N = length(yrs)*length(sites)*size(tab_temp,1);

nnodes = 13;
% create storage container
dat_tab_store = zeros(N,nnodes);

% create intervention data table with:
% ['Year','Site','Guided','Seed1','fogging','AssAdt','Natad','CoralCover','ShelterVol','Juveniles',RCI']

count = 0;
for yy = 1:length(yrs)
    for ss = 1:length(sites)
        for ii = 1:size(tab_temp,1)
            count = count + 1;
            dat_tab_store(count,1) = yy;
            dat_tab_store(count,2) = ss;
            dat_tab_store(count,3:9) = tab_temp(ii,[1:2,4,6:7,12:13]);
            dat_tab_store(count,nnodes-3) = out_45.coralTaxaCover_x_p_total_cover.mean(yy,sites(ss),tgt_ind(ii))-out_45.coralTaxaCover_x_p_total_cover.mean(yy,sites(ss),tgt_ind_cf);
            dat_tab_store(count,nnodes-2) = out_45.shelterVolume.mean(yy,sites(ss),tgt_ind(ii))-out_45.shelterVolume.mean(yy,sites(ss),tgt_ind_cf);
            dat_tab_store(count,nnodes-1) = out_45.coralTaxaCover_x_p_juveniles.mean(yy,sites(ss),tgt_ind(ii))-out_45.coralTaxaCover_x_p_juveniles.mean(yy,sites(ss),tgt_ind_cf);
            dat_tab_store(count,nnodes) = out_45.RCI.mean(yy,sites(ss),tgt_ind(ii))-out_45.RCI.mean(yy,sites(ss),tgt_ind_cf);

        end
    end
end


% tab_temp_cf = tab_temp_full(tgt_ind_cf,:);
% N = length(yrs)*length(sites)*size(tab_temp_cf,1);
% nnodes = 13;
% % create storage container
% dat_tab_store_cf = zeros(N,nnodes);
% count = 0;
% for yy = 1:length(yrs)
%     for ss = 1:length(sites)
%         for ii = 1:size(tab_temp_cf,1)
%             count = count + 1;
%             dat_tab_store_cf(count,1) = yy;
%             dat_tab_store_cf(count,2) = ss;
%             dat_tab_store_cf(count,3:9) = tab_temp(ii,[1:2,4,6:7,12:13]);
%             dat_tab_store_cf(count,nnodes-3) = out_45.coralTaxaCover_x_p_total_cover.mean(yy,sites(ss),tgt_ind_cf(ii));
%             dat_tab_store_cf(count,nnodes-2) = out_45.shelterVolume.mean(yy,sites(ss),tgt_ind_cf(ii));
%             dat_tab_store_cf(count,nnodes-1) = out_45.coralTaxaCover_x_p_juveniles.mean(yy,sites(ss),tgt_ind_cf(ii));
%             dat_tab_store_cf(count,nnodes) = out_45.RCI.mean(yy,sites(ss),tgt_ind_cf(ii));
% 
%         end
%     end
% end
% 
% bbn_data = [dat_tab_store;dat_tab_store_cf];

%% Create BBNs using data
% first create BBN structure
names = {'Year';'Site';'Guided';'Seed1';'fogging';'AssAdt';'NatAdt';'Seedyr_start';'Shadeyr_start';'CC';'SV';'Ju';'RCI'};
parent_cell = cell(1, nnodes);
nmetrics = 4;
for i = 1:(nnodes-nmetrics)
    parent_cell{i} = [];
end
for k = 0:nmetrics-1
    parent_cell{nnodes-(k)} = 1:(nnodes-nmetrics);
end

R = bn_rankcorr(parent_cell, bbn_data, 1, 1, names);

figure(2);
% plot the bbn as a network with the rank correlation matrix values as
% weightings
bn_visualize(parent_cell, R, names, gca);

%% BBN inferences: Guided vs. unguided
c1 = 'Guided';
c2 = 'Unguided';
increArray = [15,35,55];
knownVars =[1,500000,0.2,8,0,2,2];
inf_cells = [1,3:9];
nodePos = 1;
F = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);

knownVars =[0,500000,0.2,8,0,2,2];
F_cf = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);

%% plots comparing coral cover for intervention and cf
yrs = increArray+2025;
leg = [];
for k = 1:length(yrs)
    leg = [leg;num2str(yrs(k))];
end
figure(3)
t = tiledlayout(1,2)
t.TileSpacing = 'compact';

nexttile
hold on 
plotHistMulti(F,2,1000)
ylim([0,0.325])
xlim([0,0.8])
xlabel(strcat("Mean coral cover ",c1),'Fontsize',14,'Interpreter','latex')
h = legend(leg)
set(h,'Interpreter','latex','Fontsize',14)
ylabel("Probability",'Fontsize',14,'Interpreter','latex')
ax = gca;
ax.FontSize = 12;

nexttile
plotHistMulti(F_cf,2,1000)
ylim([0,0.325])
xlim([0,0.8])
h = legend(leg)
set(h,'Interpreter','latex','Fontsize',14)
xlabel(strcat("Mean coral cover ",c2),'Fontsize',14,'Interpreter','latex')
ylabel("Probability",'Fontsize',14,'Interpreter','latex')
ax = gca;
ax.FontSize = 12;

figure(4)
t = tiledlayout(1,2)
t.TileSpacing = 'compact';

nexttile
hold on 
plotHistMulti(F,5,1000)
ylim([0,0.35])
xlim([0,0.3])
xlabel(strcat("Mean RCI ",c1),'Fontsize',14,'Interpreter','latex')
h = legend(leg)
set(h,'Interpreter','latex','Fontsize',14)
ylabel("Probability",'Fontsize',14,'Interpreter','latex')
ax = gca;
ax.FontSize = 12;

nexttile
plotHistMulti(F_cf,5,1000)
ylim([0,0.35])
xlim([0,0.3])
h = legend(leg)
set(h,'Interpreter','latex','Fontsize',14)
xlabel(strcat("Mean RCI ",c2),'Fontsize',14,'Interpreter','latex')
ylabel("Probability",'Fontsize',14,'Interpreter','latex')
ax = gca;
ax.FontSize = 12;
%% BBN inferences: startyr 2,6,11,16
increArray = [2,6,11,16];
knownVars =[35,1,500000,0.2,4,0,2];
inf_cells = [1,3:9];
nodePos = 8;
Fsy = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);
%% Plotting
figure(5)
hold on 
plotHistMulti(Fsy,2,1000)
ylim([0,0.35])
xlim([0,0.5])
xlabel(strcat("Mean Coral Cover "),'Fontsize',12,'Interpreter','latex')
ylabel('Probability','Fontsize',12,'Interpreter','latex')
h = legend('2026','2031','2036','2040')
set(h,'Interpreter','latex','Fontsize',12)
ax = gca;
ax.FontSize = 12;
hold off
%% BBN inferences:0dhw, 4dhw, 8dhw 
c1 = 'Interv.';
c2 = 'Counterf.';
%{'Year';'Site';'Guided';'Seed1';'fogging';'AssAdt';'NatAdt';
% 'Seedyr_start';'Shadeyr_start';'CC';'SV';'Ju';'RCI'};
increArray = [15,35,55];
knownVars =[0,0,0,0,2,2];
inf_cells = [1,4:9];
nodePos = 1;
Fcf = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);

knownVars =[0,0.2,0,0,2,2];
F0 = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);

knownVars =[500000,0.2,4,0,2,2];
F4 = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);

knownVars =[500000,0.2,8,0,2,2];
F8 = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);

%% Plotting 2*2
figure(5)
t = tiledlayout(2,2)
t.TileSpacing = 'compact';
c1 ='';
% counterf
nexttile
hold on 
plotHistMulti(Fcf,3,1000)
ylim([0,0.35])
xlim([0,0.5])
xlabel(strcat("Mean Coral Cover ",c1),'Fontsize',12,'Interpreter','latex')
ylabel('Probability','Fontsize',12,'Interpreter','latex')
h = legend(leg)
set(h,'Interpreter','latex','Fontsize',12)
ax = gca;
ax.FontSize = 12;
hold off

% 0dhw seeding 
nexttile
hold on 
plotHistMulti(F0,3,1000)
ylim([0,0.35])
xlim([0,0.5])
xlabel(strcat("Mean Coral Cover ",c1),'Fontsize',12,'Interpreter','latex')
ylabel('Probability','Fontsize',12,'Interpreter','latex')
ax = gca;
ax.FontSize = 12;
hold off

% 4dhw seeding 
nexttile
hold on 
plotHistMulti(F4,3,1000)
ylim([0,0.35])
xlim([0,0.5])
xlabel(strcat("Mean Coral Cover ",c1),'Fontsize',12,'Interpreter','latex')
ylabel('Probability','Fontsize',12,'Interpreter','latex')
ax = gca;
ax.FontSize = 12;
hold off

% 8dhw seeding 
nexttile
hold on 
plotHistMulti(F8,3,1000)
ylim([0,0.35])
xlim([0,0.5])
xlabel(strcat("Mean Coral Cover ",c1),'Fontsize',12,'Interpreter','latex')
ylabel('Probability','Fontsize',12,'Interpreter','latex')
ax = gca;
ax.FontSize = 12;
hold off

%% Plot BBN map for top 20 performing sites
% find top 20 sites for 
top30_ind = (out_45.inputs.Seedyr_start==2)& ...
                    (out_45.inputs.Shadeyr_start==2)& ...
                    (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Seedfreq==0)& ...
                    (out_45.inputs.Shadeyrs==74)& ...
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Seed1==500000)& ...
                    (out_45.inputs.Seed2==500000)& ...
                    (out_45.inputs.fogging==0.2)& ...
                    (out_45.inputs.Natad==0.0)& ...
                    (out_45.inputs.Aadpt==4)&...
                    (out_45.inputs.Guided==1);
top30cf_ind = (out_45.inputs.Seedyr_start==2)& ...
                    (out_45.inputs.Shadeyr_start==2)& ...
                    (out_45.inputs.Shadefreq==1)& ...
                    (out_45.inputs.Seedfreq==0)& ...
                    (out_45.inputs.Shadeyrs==20)& ...
                    (out_45.inputs.Seedyrs==5)& ...
                    (out_45.inputs.Seed1==0)& ...
                    (out_45.inputs.Seed2==0)& ...
                    (out_45.inputs.fogging==0)& ...
                    (out_45.inputs.Natad==0.0)& ...
                    (out_45.inputs.Aadpt==0)&...
                    (out_45.inputs.Guided==0);
top30_int_coralcover = filterSummary(out_45.coralTaxaCover_x_p_total_cover, top30_ind);
top30_cf_coralcover = filterSummary(out_45.coralTaxaCover_x_p_total_cover, top30cf_ind);
[~,top30_sites] = maxk(mean(top30_int_coralcover.mean-top30_cf_coralcover.mean,1),30,2);
%% Calculate distributions for intervention and counterfactual @ 2060
%{'Year';'Site';'Guided';'Seed1';'fogging';'AssAdt';'NatAdt';
% 'Seedyr_start';'Shadeyr_start';'CC';'SV';'Ju';'RCI'};
inf_cells = [1:9];
increArray = randi([1,561],[1,30]);
nodePos = 2;

knownVars = [35,0,0,0,0,0,2,2];
F_sites_cf = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);

knownVars = [35,1,500000,0.2,4,0,2,2];
F_sites_int = multiBBNInf(bbn_data,R,knownVars,inf_cells,increArray,nodePos);

%% calculate probability that >20% coral cover
nsite_map = 30;
P_sites_cf = zeros(nsite_map,1);
P_sites_int = zeros(nsite_map,1);
ind = 1;
val = 0.2;
met_ind = 1;

for ll = 1:nsite_map
    dist_cf = F_sites_cf{ll}{met_ind};
    P_sites_cf(ll) = calcBBNProb(dist_cf,val,ind);
    dist_int = F_sites_int{ll}{met_ind};
    P_sites_int(ll) = calcBBNProb(dist_int,val,ind);
end

cat_prob_cf = discretize(P_sites_cf,[0 0.1 0.2 0.3 0.4 0.5 1],'categorical',...
    {'0-0.1', '0.1-0.2', '0.2-0.3','0.3-0.4','0.4-0.5','0.5-1'});
cat_prob_int = discretize(P_sites_int,[0 0.1 0.2 0.3 0.4 0.5 1],'categorical',...
    {'0-0.1', '0.1-0.2', '0.2-0.3','0.3-0.4','0.4-0.5','0.5-1'});


%% Mapping probabilities
ai = ADRIA()
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/', cutoff=0.01);
ai.loadCoralCovers("./Inputs/Brick/site_data/coralCoverBrickTruncated.mat");
lat = ai.site_data.lat(top30_sites);
long = ai.site_data.long(top30_sites);

map_data_cf = table(lat,long,P_sites_cf,cat_prob_cf)
map_data_int = table(lat,long,P_sites_int,cat_prob_int)
map_data_cf.Properties.VariableNames = {'Latitude','Longitude','Probability','P(Coral Cover>0.2)'}
map_data_int.Properties.VariableNames = {'Latitude','Longitude','Probability','P(Coral Cover>0.2)'}

t = tiledlayout(1,2)
t.TileSpacing = 'compact';

% counterf
nexttile
subtitle('Counterfactual','Fontsize',12,'Interpreter','latex')
geobubble(map_data_cf,'Longitude','Latitude','SizeVariable','Probability','ColorVariable',...
    'P(Coral Cover>0.2)','Basemap','satellite','MapLayout','maximized','SizeLimits',[0,0.5],...
    'BubbleColorList',parula(6))
colormap = parula;
nexttile
subtitle('Intervention','Fontsize',12,'Interpreter','latex')
geobubble(map_data_int,'Longitude','Latitude','SizeVariable','Probability','ColorVariable',...
    'P(Coral Cover>0.2)','Basemap','satellite','MapLayout','maximized','SizeLimits',[0,0.5],...
    'BubbleColorList',parula(6))
colormap = parula;
