

%% Connectivity
connectivity_file = './Inputs/Cairns/Connectivity/Cairns_connectivity_2011.xlsx';
[TP_data, site_ranks, strong_pred, site_ids] = siteConnectivity(connectivity_file, 0.1);

%% Site Data
sdata = load('./Inputs/Cairns/Site_data/Cairns_reef_data.mat');
area = sdata.area;
centr = site_ranks.C1;
nsites = length(area);
k = repmat(0.7,1,nsites-1);

%% Initial Coral Cover
IC = load("ReefModInitialCoverCairns.mat");

%% DHW data
tf = 20;
nreps = 92;
dhw_scen26 = load("ReefModBleachMortCairnsRCP26.mat").bleach_mort(1:tf, :, 1:nreps);
dhw_scen45 = load("ReefModBleachMortCairnsRCP45.mat").bleach_mort(1:tf, :, 1:nreps);
dhw_scen60 = load("ReefModBleachMortCairnsRCP60.mat").bleach_mort(1:tf, :, 1:nreps);

%% Wave data (cyclones)
damprob = load("ReefModCycMortCairns.mat").cyc_mort(1:nreps,:,1:tf);

%% Set up criteria weightings
wtwaves = 1; % weight of wave damage in MCDA
wtheat = 1; % weight of heat damage in MCDA
wtconshade = 1; % weight of connectivity for shading in MCDA
wtconseed = 1; % weight of connectivity for seeding in MCDA
wthicover = 1; % weight of high coral cover in MCDA (high cover gives preference for seeding corals but high for SRM)
wtlocover = 1; % weight of low coral cover in MCDA (low cover gives preference for seeding corals but high for SRM)
wtpredecseed = 1; % weight for the importance of seeding sites that are predecessors of priority reefs
wtpredecshade = 1; % weight for the importance of shading sites that are predecessors of priority reefs
risktol = 1; % risk tolerance

nsiteint = 5; % intervene at 5 sites
sites = 1:nsites;
tstep = 1;

%% Ranking calcs RCP 26
sslog = struct('seed',true,'shade',true)
store_seed_rankings_Order26 = zeros(nreps,nsites,2);
store_seed_rankings_TOPSIS26 = zeros(nreps,nsites,2);
store_seed_rankings_VIKOR26 = zeros(nreps,nsites,2);
% site_id, seeding rank, shading rank
rankings = [sites', zeros(nsites, 1), zeros(nsites, 1)];
prefseedsites = zeros(nsiteint,1);
prefshadesites = zeros(nsiteint,1);

for l = 1:nreps
    dhw_step = dhw_scen26(tstep,:,l);
    heatstressprob = dhw_step';

    dMCDA_vars = struct('site_ids', sites, 'nsiteint', nsiteint, 'prioritysites', [], ...
                'strongpred', strong_pred, 'centr', centr, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
                'sumcover', IC.cover,'maxcover', k, 'area',area,'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
                'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
                'wtpredecshade', wtpredecshade);
    
    [~, ~, ~, ~, rankingsalg1] = ADRIA_DMCDA(dMCDA_vars, 1, sslog,prefseedsites,prefshadesites,rankings);
    [~, ~, ~, ~, rankingsalg2] = ADRIA_DMCDA(dMCDA_vars, 2, sslog,prefseedsites,prefshadesites,rankings);
    [~, ~, ~, ~, rankingsalg3] = ADRIA_DMCDA(dMCDA_vars, 3, sslog,prefseedsites,prefshadesites,rankings);
    store_seed_rankings_Order26(l,:,:) = rankingsalg1(:,2:end);
    store_seed_rankings_TOPSIS26(l,:,:) = rankingsalg2(:,2:end);
    store_seed_rankings_VIKOR26(l,:,:) = rankingsalg3(:,2:end);
end

siteranks_Order26 = siteRanking(store_seed_rankings_Order26,"seed");
siteranks_TOPSIS26 = siteRanking(store_seed_rankings_TOPSIS26,"seed");
siteranks_VIKOR26 = siteRanking(store_seed_rankings_VIKOR26,"seed");

%% Begin ranking calcs RCP 45
sslog = struct('seed',true,'shade',true)
store_seed_rankings_Order45 = zeros(nreps,nsites,2);
store_seed_rankings_TOPSIS45 = zeros(nreps,nsites,2);
store_seed_rankings_VIKOR45 = zeros(nreps,nsites,2);
% site_id, seeding rank, shading rank
rankings = [sites', zeros(nsites, 1), zeros(nsites, 1)];
prefseedsites = zeros(nsiteint,1);
prefshadesites = zeros(nsiteint,1);

for l = 1:nreps
    dhw_step = dhw_scen45(tstep,:,l);
    heatstressprob = dhw_step';

    dMCDA_vars = struct('site_ids', sites, 'nsiteint', nsiteint, 'prioritysites', [], ...
                'strongpred', strong_pred, 'centr', centr, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
                'sumcover', IC.cover,'maxcover', k, 'area',area,'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
                'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
                'wtpredecshade', wtpredecshade);
    
    [~, ~, ~, ~, rankingsalg1] = ADRIA_DMCDA(dMCDA_vars, 1, sslog,prefseedsites,prefshadesites,rankings);
    [~, ~, ~, ~, rankingsalg2] = ADRIA_DMCDA(dMCDA_vars, 2, sslog,prefseedsites,prefshadesites,rankings);
    [~, ~, ~, ~, rankingsalg3] = ADRIA_DMCDA(dMCDA_vars, 3, sslog,prefseedsites,prefshadesites,rankings);
    store_seed_rankings_Order45(l,:,:) = rankingsalg1(:,2:end);
    store_seed_rankings_TOPSIS45(l,:,:) = rankingsalg2(:,2:end);
    store_seed_rankings_VIKOR45(l,:,:) = rankingsalg3(:,2:end);
end

siteranks_Order45 = siteRanking(store_seed_rankings_Order45,"seed");
siteranks_TOPSIS45 = siteRanking(store_seed_rankings_TOPSIS45,"seed");
siteranks_VIKOR45 = siteRanking(store_seed_rankings_VIKOR45,"seed");

%% Begin ranking calcs RCP 60
sslog = struct('seed',true,'shade',true)
store_seed_rankings_Order60 = zeros(nreps,nsites,2);
store_seed_rankings_TOPSIS60 = zeros(nreps,nsites,2);
store_seed_rankings_VIKOR60 = zeros(nreps,nsites,2);
% site_id, seeding rank, shading rank
rankings = [sites', zeros(nsites, 1), zeros(nsites, 1)];
prefseedsites = zeros(nsiteint,1);
prefshadesites = zeros(nsiteint,1);

for l = 1:nreps
    dhw_step = dhw_scen60(tstep,:,l);
    heatstressprob = dhw_step';

    dMCDA_vars = struct('site_ids', sites, 'nsiteint', nsiteint, 'prioritysites', [], ...
                'strongpred', strong_pred, 'centr', centr, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
                'sumcover', IC.cover,'maxcover', k, 'area',area,'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
                'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
                'wtpredecshade', wtpredecshade);
    
    [~, ~, ~, ~, rankingsalg1] = ADRIA_DMCDA(dMCDA_vars, 1, sslog,prefseedsites,prefshadesites,rankings);
    [~, ~, ~, ~, rankingsalg2] = ADRIA_DMCDA(dMCDA_vars, 2, sslog,prefseedsites,prefshadesites,rankings);
    [~, ~, ~, ~, rankingsalg3] = ADRIA_DMCDA(dMCDA_vars, 3, sslog,prefseedsites,prefshadesites,rankings);
    store_seed_rankings_Order60(l,:,:) = rankingsalg1(:,2:end);
    store_seed_rankings_TOPSIS60(l,:,:) = rankingsalg2(:,2:end);
    store_seed_rankings_VIKOR60(l,:,:) = rankingsalg3(:,2:end);
end

siteranks_Order60 = siteRanking(store_seed_rankings_Order60,"seed");
siteranks_TOPSIS60 = siteRanking(store_seed_rankings_TOPSIS60,"seed");
siteranks_VIKOR60 = siteRanking(store_seed_rankings_VIKOR60,"seed");