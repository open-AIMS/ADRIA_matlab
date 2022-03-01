%% Load ADRIA object
ai = ADRIA();
% retrieve default criteria weights 
[~,criteria,~] = ai.splitParameterTable(ai.sample_defaults);

%% Change weights as desired
% change depth criteria so that no sites will be filtered due to depth
criteria.depth_min = 0;

%% Connectivity
cyear = 2014;
connectivity_file = sprintf('./Inputs/Cairns/Connectivity/Cairns_connectivity_%4.0f.csv',cyear);
ai.loadConnectivity(connectivity_file, cutoff=0.1);

%% Site Data
% first create data format
sdata = load('./Inputs/Cairns/Site_data/Cairns_reef_data.mat');
% extract area
area = sdata.area;
nsites = length(area);
% create vector of site_IDS
reef_siteid = 1:nsites;
reef_siteid = reef_siteid';
% create vector of carrying capacity
k = repmat(70,nsites,1);
% make connectivity ids be the same and ordered ids
recom_connectivity = reef_siteid;
% load initial coral cover
TC = load("./Inputs/Cairns/Site_data/ReefModInitialCoverCairns.mat").cover*100;
% create fake depth vector so that no sites are filtered due to depth
sitedepth = -1*ones(nsites,1);
% recreate site data based on generic structure
sitedata_tab = table(reef_siteid,area,k,TC,sitedepth,recom_connectivity);
writetable(sitedata_tab,'./Inputs/Cairns/Site_data/CairnsSiteData.csv');
% load site data in ai object
ai.loadSiteData('./Inputs/Cairns/Site_data/CairnsSiteData.csv',['TC']);

%% Find degraded sites (<0.15 coral cover to favour strongest predecessors of these sites)
low_TC = reef_siteid(TC<=15);
% put these sites as priority predecessor sites in MCDA
ai.constants.prioritysites = low_TC;
%% DHW data
% no. of time steps
tf = 92;
% no. of replicates
n_reps = 20;
% 3 dhw filepaths for 3 RCPs
dhw_dat26 = "./Inputs/Cairns/DHWs/ReefModBleachMortCairnsRCP26.mat";
dhw_dat45 = "./Inputs/Cairns/DHWs/ReefModBleachMortCairnsRCP45.mat";
dhw_dat60 = "./Inputs/Cairns/DHWs/ReefModBleachMortCairnsRCP60.mat";

%% if running for the first time, need to change struct labels and order of
% dimensions (not sure if .mat files are transferring over github)
% dhw = permute(load(dhw_dat26).bleach_mort,[3,2,1]);
% % resave with name which ai.siteSelection will recognise
% save(dhw_dat26,'dhw')
% % repeat for other RCPs
% dhw = permute(load(dhw_dat45).bleach_mort,[3,2,1]);
% save(dhw_dat45,'dhw')
% dhw = permute(load(dhw_dat60).bleach_mort,[3,2,1]);
% save(dhw_dat60,'dhw')

%% Wave data (cyclones)
damprob = "./Inputs/Cairns/Waves/ReefModCycMortCairns.mat";

%% if running for the first time need to change struct labels
% wave = load(damprob).cyc_mort;
% % resave with name which ai.siteSelection will recognise
% save(damprob,'wave')

tstep = 5; % assuming runs start in 2021 and we have coral cover from 2025

%% Ranking variables
% actual site ids used in Reefmod
site_ids_rm = load('./Inputs/Cairns/Site_data/LIST_CAIRNS_REEFS').reefs190.Reef_ID;
nsiteint = ai.constants.nsiteint;
sslog = struct('seed',true,'shade',true);
% Set up rankings storage site_id, seeding rank, shading rank
rankings = [reef_siteid, zeros(nsites, 1), zeros(nsites, 1)];
prefseedsites = zeros(nsiteint,1);
prefshadesites = zeros(nsiteint,1);

% initial coral cover column name
init_coral_cov_col = ['TC'];

%% Run site selection RCP 26
% load dhw data for RCP 26
ai.loadDHWData(dhw_dat26, n_reps);
% calculate rankings
rankings_mat_RCP26_alg1 = ai.siteSelection(criteria,tstep,n_reps,1,sslog,init_coral_cov_col,damprob);
rankings_mat_RCP26_alg2 = ai.siteSelection(criteria,tstep,n_reps,2,sslog,init_coral_cov_col,damprob);
rankings_mat_RCP26_alg3 = ai.siteSelection(criteria,tstep,n_reps,3,sslog,init_coral_cov_col,damprob);
% find mean seeding ranks over climate stochasticity
mean_ranks_seed_RCP26_alg1 = siteRanking(rankings_mat_RCP26_alg1(:,:,2:end),'seed');
mean_ranks_seed_RCP26_alg2 = siteRanking(rankings_mat_RCP26_alg2(:,:,2:end),'seed');
mean_ranks_seed_RCP26_alg3 = siteRanking(rankings_mat_RCP26_alg3(:,:,2:end),'seed');


%% Run site selection RCP 45
% load dhw data for RCP 45
ai.loadDHWData(dhw_dat45, n_reps);
% calculate rankings
rankings_mat_RCP45_alg1 = ai.siteSelection(criteria,tstep,n_reps,1,sslog,init_coral_cov_col,damprob);
rankings_mat_RCP45_alg2 = ai.siteSelection(criteria,tstep,n_reps,2,sslog,init_coral_cov_col,damprob);
rankings_mat_RCP45_alg3 = ai.siteSelection(criteria,tstep,n_reps,3,sslog,init_coral_cov_col,damprob);
% find mean seeding ranks over climate stochasticity
mean_ranks_seed_RCP45_alg1 = siteRanking(rankings_mat_RCP45_alg1(:,:,2:end),'seed');
mean_ranks_seed_RCP45_alg2 = siteRanking(rankings_mat_RCP45_alg2(:,:,2:end),'seed');
mean_ranks_seed_RCP45_alg3 = siteRanking(rankings_mat_RCP45_alg3(:,:,2:end),'seed');

%% Run site selection RCP 60
% load dhw data for RCP 60
ai.loadDHWData(dhw_dat60, n_reps);
% calculate rankings
rankings_mat_RCP60_alg1 = ai.siteSelection(criteria,tstep,n_reps,1,sslog,init_coral_cov_col,damprob);
rankings_mat_RCP60_alg2 = ai.siteSelection(criteria,tstep,n_reps,2,sslog,init_coral_cov_col,damprob);
rankings_mat_RCP60_alg3 = ai.siteSelection(criteria,tstep,n_reps,3,sslog,init_coral_cov_col,damprob);
% find mean seeding ranks over climate stochasticity
mean_ranks_seed_RCP60_alg1 = siteRanking(rankings_mat_RCP60_alg1(:,:,2:end),'seed');
mean_ranks_seed_RCP60_alg2 = siteRanking(rankings_mat_RCP60_alg2(:,:,2:end),'seed');
mean_ranks_seed_RCP60_alg3 = siteRanking(rankings_mat_RCP60_alg3(:,:,2:end),'seed');

%% Saving ranks
% create filename
filename = sprintf('./Outputs/Rankings_RCPs264560_connectivity%4.0f.xlsx',cyear);
% create table of ranks and corresponding ReefMod IDs
T = table(site_ids_rm,mean_ranks_seed_RCP26_alg1,mean_ranks_seed_RCP26_alg2,mean_ranks_seed_RCP26_alg3,...
    mean_ranks_seed_RCP45_alg1,mean_ranks_seed_RCP45_alg2,mean_ranks_seed_RCP45_alg3,...
    mean_ranks_seed_RCP60_alg1,mean_ranks_seed_RCP60_alg2,mean_ranks_seed_RCP60_alg3);
% Set table column names
T.Properties.VariableNames ={'Site ID','Order, RCP 26', 'TOPSIS, RCP 26', 'VIKOR, RCP 26',...
                            'Order, RCP 45', 'TOPSIS, RCP 45', 'VIKOR, RCP 45',...
                            'Order, RCP 60', 'TOPSIS, RCP 60', 'VIKOR, RCP 60'};
% Write table to Excel file
writetable(T,filename,'Sheet','Site ranks for 3 RCPs');