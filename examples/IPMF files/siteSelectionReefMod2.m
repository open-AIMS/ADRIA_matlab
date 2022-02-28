%% Load ADRIA object
ai = ADRIA();

% retrieve default criteria weights 
[~,criteria,~] = ai.splitParameterTable(ai.sample_defaults);

%% Change any weights as desired
% e.g. change shade_connectivity weight and coral cover high weight to 1
criteria.shade_connectivity = 1;
criteria.coral_cover_high = 1;
criteria.shade_priority = 1;
criteria.depth_min = 0;

%% Connectivity
connectivity_file = './Inputs/Cairns/Connectivity/Cairns_connectivity_2014.csv';
ai.loadConnectivity(connectivity_file, cutoff=0.1);

%% Site Data
% first create data format
sdata = load('./Inputs/Cairns/Site_data/Cairns_reef_data.mat');
area = sdata.area;
nsites = length(area);
reef_siteid = 1:nsites;
reef_siteid = reef_siteid';
k = repmat(0.7,nsites,1);
recom_connectivity = reef_siteid;
IC = load("ReefModInitialCoverCairns.mat").cover;
sitedepth = ones(nsites,1);;
sitedata_tab = table(reef_siteid,area,k,IC,sitedepth,recom_connectivity)
writetable(sitedata_tab,'./Inputs/Cairns/Site_data/CairnsSiteData.csv');
ai.loadSiteData('./Inputs/Cairns/Site_data/CairnsSiteData.csv',['IC']);

%% DHW data
tf = 92;
n_reps = 20;
dhw_dat26 = "ReefModBleachMortCairnsRCP26.mat";
dhw_dat45 = "ReefModBleachMortCairnsRCP45.mat";
dhw_dat60 = "ReefModBleachMortCairnsRCP60.mat";

%% Wave data (cyclones)
damprob = "ReefModCycMortCairns.mat";
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

%% Rnaking variables
sslog = struct('seed',true,'shade',true)
% site_id, seeding rank, shading rank
rankings = [sites', zeros(nsites, 1), zeros(nsites, 1)];
prefseedsites = zeros(nsiteint,1);
prefshadesites = zeros(nsiteint,1);

init_coral_cov_col = ['TC'];

%% Run site selection RCP 26
% calculate rankings
rankings_mat_RCP26_alg1 = ai.siteSelection(criteria,tstep,n_reps,1,sslog,init_coral_cov_col,dhw_dat26,damprob);
rankings_mat_RCP26_alg2 = ai.siteSelection(criteria,tstep,n_reps,2,sslog,init_coral_cov_col,dhw_dat26,damprob);
rankings_mat_RCP26_alg3 = ai.siteSelection(criteria,tstep,n_reps,3,sslog,init_coral_cov_col,dhw_dat26,damprob);
% find mean seeding ranks over climate stochasticity
mean_ranks_seed_RCP26_alg1 = siteRanking(rankings_mat_RCP26_alg1(:,:,2:end),'seed');
mean_ranks_seed_RCP26_alg2 = siteRanking(rankings_mat_RCP26_alg2(:,:,2:end),'seed');
mean_ranks_seed_RCP26_alg3 = siteRanking(rankings_mat_RCP26_alg3(:,:,2:end),'seed');


%% Run site selection RCP 45
% calculate rankings
rankings_mat_RCP45_alg1 = ai.siteSelection(criteria,tstep,n_reps,1,sslog,init_coral_cov_col,dhw_dat45,damprob);
rankings_mat_RCP45_alg2 = ai.siteSelection(criteria,tstep,n_reps,2,sslog,init_coral_cov_col,dhw_dat45,damprob);
rankings_mat_RCP45_alg3 = ai.siteSelection(criteria,tstep,n_reps,3,sslog,init_coral_cov_col,dhw_dat45,damprob);
% find mean seeding ranks over climate stochasticity
mean_ranks_seed_RCP45_alg1 = siteRanking(rankings_mat_RCP45_alg1(:,:,2:end),'seed');
mean_ranks_seed_RCP45_alg2 = siteRanking(rankings_mat_RCP45_alg2(:,:,2:end),'seed');
mean_ranks_seed_RCP45_alg3 = siteRanking(rankings_mat_RCP45_alg3(:,:,2:end),'seed');

%% Run site selection RCP 60
% calculate rankings
rankings_mat_RCP60_alg1 = ai.siteSelection(criteria,tstep,n_reps,1,sslog,init_coral_cov_col,dhw_dat60,damprob);
rankings_mat_RCP60_alg2 = ai.siteSelection(criteria,tstep,n_reps,2,sslog,init_coral_cov_col,dhw_dat60,damprob);
rankings_mat_RCP60_alg3 = ai.siteSelection(criteria,tstep,n_reps,3,sslog,init_coral_cov_col,dhw_dat60,damprob);
% find mean seeding ranks over climate stochasticity
mean_ranks_seed_RCP60_alg1 = siteRanking(rankings_mat_RCP60_alg1(:,:,2:end),'seed');
mean_ranks_seed_RCP60_alg2 = siteRanking(rankings_mat_RCP60_alg2(:,:,2:end),'seed');
mean_ranks_seed_RCP60_alg3 = siteRanking(rankings_mat_RCP60_alg3(:,:,2:end),'seed');