%% Load site data for 2026;
% Connectivity
[TP_data, site_ranks, strong_pred] = siteConnectivity('./Inputs/Moore/connectivity/2015', 0.1);
RCP = 45;
Year = 2026;
yrstr = num2str(Year);
% Site Data
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id", "k", [strcat("Acropora",yrstr), strcat("Goniastrea",yrstr)], "sitedepth", "recom_connectivity"]]);
site_data = sortrows(site_data, "recom_connectivity");
[~, ~, g_idx] = unique(site_data.recom_connectivity, 'rows', 'first');
TP_data = TP_data(g_idx, g_idx);

% DHW data
tf = 25;
nreps = 50;
dhw_scen = load("dhwRCP45.mat").dhw(1:tf, :, 1:nreps);

% time step corresponding to initial data
tstep = Year-2025;

% Weights for connectivity , waves (ww), high cover (whc) and low
wtwaves = 0; % weight of wave damage in MCDA
wtheat = 1; % weight of heat damage in MCDA
wtconshade = 0; % weight of connectivity for shading in MCDA
wtconseed = 1; % weight of connectivity for seeding in MCDA
wthicover = 0; % weight of high coral cover in MCDA (high cover gives preference for seeding corals but high for SRM)
wtlocover = 1; % weight of low coral cover in MCDA (low cover gives preference for seeding corals but high for SRM)
wtpredecseed = 0; % weight for the importance of seeding sites that are predecessors of priority reefs
wtpredecshade = 0; % weight for the importance of shading sites that are predecessors of priority reefs
risktol = 1; % risk tolerance
depth_min = 5; % minimum site depth
depth_offset = 5; % depth range from min depth

% Filter out sites outside of desired depth range
max_depth = depth_min + depth_offset;
depth_criteria = (site_data.sitedepth > -max_depth) & (site_data.sitedepth < -depth_min);
depth_priority = site_data{depth_criteria, "recom_connectivity"};

max_cover = site_data.k/100.0; % Max coral cover at each site

nsites = length(depth_priority);
damprob = zeros(length(site_data.recom_connectivity),1);
nsiteint = 5; %nsites;
    
sumcover = (site_data.(strcat('Acropora',yrstr)) + site_data.(strcat('Goniastrea',yrstr)))/100.0;


dhw_step = dhw_scen(tstep,:,1);
heatstressprob = dhw_step';
dMCDA_vars = struct('site_ids', depth_priority, 'nsiteint', nsiteint, 'prioritysites', [], ...
        'strongpred', strong_pred, 'centr', site_ranks.C1, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
        'sumcover', sumcover,'maxcover', max_cover, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
        'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
        'wtpredecshade', wtpredecshade);

prefseedsites = depth_priority(1:5);
prefshadesites = depth_priority(1:5);
rankings = [depth_priority,zeros(nsites,1),zeros(nsites,1)];
sslog = struct('seed',1,'shade',0);
[prefseedalg1, prefshadealg1, nprefshadealg1, nprefshadealg1, rankingsalg1] = ADRIA_DMCDA(dMCDA_vars, 1, sslog,prefseedsites,prefshadesites,rankings);
[prefseedalg2, prefshadealg2, nprefshadealg2, nprefshadealg2, rankingsalg2] = ADRIA_DMCDA(dMCDA_vars, 2, sslog,prefseedsites,prefshadesites,rankings);
[prefseedalg3, prefshadealg3, nprefshadealg3, nprefshadealg3, rankingsalg3] = ADRIA_DMCDA(dMCDA_vars, 3, sslog,prefseedsites,prefshadesites,rankings);

% checks 
% check none of the algorithms change the shading preferred sites input
sum(prefshadealg1==prefshadesites)/length(prefshadesites)
sum(prefshadealg2==prefshadesites)/length(prefshadesites)
sum(prefshadealg3==prefshadesites)/length(prefshadesites)
% check none of the algorithms change the input shading rankings
sum(rankings(:,3)==rankingsalg1(:,3))/length(rankings(:,3))
sum(rankings(:,3)==rankingsalg2(:,3))/length(rankings(:,3))
sum(rankings(:,3)==rankingsalg3(:,3))/length(rankings(:,3))
