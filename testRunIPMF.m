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

store_seed_rankings_alg1 = zeros(1,nsites,nreps);
store_seed_rankings_alg2 = zeros(1,nsites,nreps);
store_seed_rankings_alg3 = zeros(1,nsites,nreps);

for l = 1:nreps
    dhw_step = dhw_scen(tstep,:,l);
    heatstressprob = dhw_step';
    dMCDA_vars = struct('site_ids', depth_priority, 'nsiteint', nsiteint, 'prioritysites', [], ...
                'strongpred', strong_pred, 'centr', site_ranks.C1, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
                'sumcover', sumcover,'maxcover', max_cover, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
                'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
                'wtpredecshade', wtpredecshade);
    
    [~, ~, ~, ~, rankingsalg1] = ADRIA_DMCDA(dMCDA_vars, 1);
    [~, ~, ~, ~, rankingsalg2] = ADRIA_DMCDA(dMCDA_vars, 2);
    [~, ~, ~, ~, rankingsalg3] = ADRIA_DMCDA(dMCDA_vars, 3);
    store_seed_rankings_alg1(:,:,l) = rankingsalg1(:,2);
    store_seed_rankings_alg2(:,:,l) = rankingsalg2(:,2);
    store_seed_rankings_alg3(:,:,l) = rankingsalg3(:,2);
end

siteranks_alg1 = siteRanking(store_seed_rankings_alg1,"seed");
siteranks_alg2 = siteRanking(store_seed_rankings_alg2,"seed");
siteranks_alg3 = siteRanking(store_seed_rankings_alg3,"seed");
% siteranks_alg1 = mean(squeeze(store_seed_rankings_alg1),2);
% siteranks_alg2 = mean(squeeze(store_seed_rankings_alg2),2);
% siteranks_alg3 = mean(squeeze(store_seed_rankings_alg3),2);
% 
% siteranks_alg1_round = round(siteranks_alg1);
% siteranks_alg2_round = round(siteranks_alg2);
% siteranks_alg3_round = round(siteranks_alg3);

sites_after_filtering = depth_priority;
T = table(sites_after_filtering,siteranks_alg1,siteranks_alg2,siteranks_alg3);
writetable(T,sprintf('Rankings_RCP%2.0f_Year%4.0f_revised.xlsx',RCP,Year))


