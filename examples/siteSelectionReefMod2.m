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
cyear = 2014;
connectivity_file = sprintf('./Inputs/Cairns/Connectivity/Cairns_connectivity_%4.0f.csv',cyear);
ai.loadConnectivity(connectivity_file, cutoff=0.1);

%% Site Data
% first create data format
sdata = load('./Inputs/Cairns/Site_data/Cairns_reef_data.mat');
area = sdata.area;
nsites = length(area);
reef_siteid = 1:nsites;
reef_siteid = reef_siteid';
k = repmat(70,nsites,1);
recom_connectivity = reef_siteid;
TC = load("ReefModInitialCoverCairns.mat").cover*100;
sitedepth = -1*ones(nsites,1);;
sitedata_tab = table(reef_siteid,area,k,TC,sitedepth,recom_connectivity);
writetable(sitedata_tab,'./Inputs/Cairns/Site_data/CairnsSiteData.csv');
ai.loadSiteData('./Inputs/Cairns/Site_data/CairnsSiteData.csv',['TC']);

%% DHW data
tf = 92;
n_reps = 20;
dhw_dat26 = "ReefModBleachMortCairnsRCP26.mat";
dhw_dat45 = "ReefModBleachMortCairnsRCP45.mat";
dhw_dat60 = "ReefModBleachMortCairnsRCP60.mat";

%% Wave data (cyclones)
damprob = "ReefModCycMortCairns.mat";
tstep = 1;

%% Rnaking variables
nsiteint = ai.constants.nsiteint;
sslog = struct('seed',true,'shade',true);
% site_id, seeding rank, shading rank
rankings = [reef_siteid, zeros(nsites, 1), zeros(nsites, 1)];
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

%% Saving ranks
filename = sprintf('./Outputs/Rankings_RCPs264560_connectivity%4.0f.xlsx',cyear);
T = table(reef_siteid,mean_ranks_seed_RCP26_alg1,mean_ranks_seed_RCP26_alg2,mean_ranks_seed_RCP26_alg3,...
    mean_ranks_seed_RCP45_alg1,mean_ranks_seed_RCP45_alg2,mean_ranks_seed_RCP45_alg3,...
    mean_ranks_seed_RCP60_alg1,mean_ranks_seed_RCP60_alg2,mean_ranks_seed_RCP60_alg3);
T.Properties.VariableNames ={'Site','Order, RCP 26', 'TOPSIS, RCP 26', 'VIKOR, RCP 26',...
                            'Order, RCP 45', 'TOPSIS, RCP 45', 'VIKOR, RCP 45',...
                            'Order, RCP 60', 'TOPSIS, RCP 60', 'VIKOR, RCP 60'};
writetable(T,filename,'Sheet','Site ranks no cover filtering');