%% Load site data for 2026;
% Connectivity
[TP_data, site_ranks, strong_pred] = siteConnectivity('./Inputs/Moore/connectivity/2015/moore_d2_2015_transfer_probability_matrix_wide.csv', 0.1);
RCP = 45;
Year = 2026;
yrstr = num2str(Year);

% Site Data
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id", "k", [strcat("Acropora",yrstr), strcat("Goniastrea",yrstr)], "sitedepth", "recom_connectivity", "reef_siteid"]]);
site_data = sortrows(site_data, "recom_connectivity");

% Duplicate TP rows/columns for sites that site within the same
% connectivity cell
[~, ~, g_idx] = unique(site_data.recom_connectivity, 'rows', 'first');
TP_data = TP_data(g_idx, g_idx);

% DHW data
tf = 50;
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

considered_site_idx = find((site_data.sitedepth > -max_depth) & (site_data.sitedepth < -depth_min));
considered_recom_ids = site_data{considered_site_idx, "recom_connectivity"};

max_cover = site_data.k/100.0; % Max coral cover at each site

nsites = length(depth_priority);
damprob = zeros(length(site_data.recom_connectivity),1);
nsiteint = 5; %nsites;
    
sumcover = (site_data.(strcat('Acropora',yrstr)) + site_data.(strcat('Goniastrea',yrstr)))/100.0;

store_seed_rankings_Order = zeros(nreps,nsites,2);
store_seed_rankings_TOPSIS = zeros(nreps,nsites,2);
store_seed_rankings_VIKOR = zeros(nreps,nsites,2);

for l = 1:nreps
    dhw_step = dhw_scen(tstep,:,l);
    heatstressprob = dhw_step';
    dMCDA_vars = struct('site_ids', considered_recom_ids, 'nsiteint', nsiteint, 'prioritysites', [], ...
                'strongpred', strong_pred, 'centr', site_ranks.C1, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
                'sumcover', sumcover,'maxcover', max_cover, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
                'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
                'wtpredecshade', wtpredecshade);
    
    [~, ~, ~, ~, rankingsalg1] = ADRIA_DMCDA(dMCDA_vars, 1);
    [~, ~, ~, ~, rankingsalg2] = ADRIA_DMCDA(dMCDA_vars, 2);
    [~, ~, ~, ~, rankingsalg3] = ADRIA_DMCDA(dMCDA_vars, 3);
    store_seed_rankings_Order(l,:,:) = rankingsalg1(:,2:end);
    store_seed_rankings_TOPSIS(l,:,:) = rankingsalg2(:,2:end);
    store_seed_rankings_VIKOR(l,:,:) = rankingsalg3(:,2:end);
end

siteranks_Order = siteRanking(store_seed_rankings_Order,"seed");
siteranks_TOPSIS = siteRanking(store_seed_rankings_TOPSIS,"seed");
siteranks_VIKOR = siteRanking(store_seed_rankings_VIKOR,"seed");

T = table(site_data{considered_id, "reef_siteid"}, considered_id, ...
          considered_recom_ids, siteranks_Order, siteranks_TOPSIS, siteranks_VIKOR);

T.Properties.VariableNames = {'reef_siteid' 'site_index_id' 'recom_id' 'order_rank' 'TOPSIS_rank', 'VIKOR_rank'};
writetable(T,sprintf('./Outputs/Rankings_RCP%2.0f_Year%4.0f_revised_w_idx_day2.xlsx',RCP,Year))


