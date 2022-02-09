%% Load site data for 2026;
% Connectivity
connectivity_fn = './Inputs/Moore/connectivity/2015_IPMF/connectivity_mean_day1to3_2015.csv';
[TP_data, site_ranks, strong_pred, site_ids] = siteConnectivity(connectivity_fn, 0.1);
RCP = 45;
Year = 2026;
yrstr = num2str(Year);

% Site Data
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id", "k", [strcat("Acropora",yrstr), strcat("Goniastrea",yrstr)], "sitedepth", "recom_connectivity", "reef_siteid"]]);


% Account for cases where multiple sites are located within a single recom
% cell.
% Duplicate TP rows/columns for sites that site within the same
% connectivity cell
if height(site_data) > height(TP_data)
    [~, ~, g_idx] = unique(site_data.recom_connectivity, 'rows', 'first');
    TP_data = TP_data(g_idx, g_idx);
    site_data = sortrows(site_data, "recom_connectivity");
else
    
    % Sort by reef_siteid so datasets match up
    site_data = sortrows(site_data, "reef_siteid");
    
    % combine the two columns
    test_join = table(site_ids, site_data{:, "reef_siteid"});
    
    % error out if things don't line up as expected
    assert(all(string(test_join{:, 1}) == string(test_join{:, 2})), ...
        "Reef Site ID order does not match!")
end

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
coral_min = 0.15;
% Filter out sites outside of desired depth range
max_depth = depth_min + depth_offset;

depth_criteria = (site_data.sitedepth > -max_depth) & (site_data.sitedepth < -depth_min);
considered_site_idx = find(depth_criteria);
considered_recom_ids = site_data{considered_site_idx, "recom_connectivity"};

max_cover = site_data.k/100.0; % Max coral cover at each site

nsites = length(considered_recom_ids);
damprob = zeros(length(site_data.recom_connectivity),1);
nsiteint = 5; %nsites;
    
sumcover = (site_data.(strcat('Acropora',yrstr)) + site_data.(strcat('Goniastrea',yrstr)))/100.0;
coral_criteria = (sumcover>coral_min);


depth_coral_priority_idx = find((depth_criteria+coral_criteria)==2);
depth_coral_priority_recom_ids = site_data{depth_coral_priority_idx, "recom_connectivity"};

nsitescor = length(depth_coral_priority_recom_ids);

store_seed_rankings_Order = zeros(nreps,nsites,2);
store_seed_rankings_TOPSIS = zeros(nreps,nsites,2);
store_seed_rankings_VIKOR = zeros(nreps,nsites,2);
store_seed_rankings_Order_coralf = zeros(nreps,nsitescor,2);
store_seed_rankings_TOPSIS_coralf = zeros(nreps,nsitescor,2);
store_seed_rankings_VIKOR_coralf = zeros(nreps,nsitescor,2);

for l = 1:nreps
    dhw_step = dhw_scen(tstep,:,l);
    heatstressprob = dhw_step';

    dMCDA_vars1 = struct('site_ids', considered_site_idx, 'nsiteint', nsiteint, 'prioritysites', [], ...
                'strongpred', strong_pred, 'centr', site_ranks.C1, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
                'sumcover', sumcover,'maxcover', max_cover, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
                'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
                'wtpredecshade', wtpredecshade);
    dMCDA_vars2 = struct('site_ids', depth_coral_priority_idx, 'nsiteint', nsiteint, 'prioritysites', [], ...
                'strongpred', strong_pred, 'centr', site_ranks.C1, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
                'sumcover', sumcover,'maxcover', max_cover, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
                'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
                'wtpredecshade', wtpredecshade);
    
    [~, ~, ~, ~, rankingsalg1] = ADRIA_DMCDA(dMCDA_vars1, 1);
    [~, ~, ~, ~, rankingsalg2] = ADRIA_DMCDA(dMCDA_vars1, 2);
    [~, ~, ~, ~, rankingsalg3] = ADRIA_DMCDA(dMCDA_vars1, 3);
    store_seed_rankings_Order(l,:,:) = rankingsalg1(:,2:end);
    store_seed_rankings_TOPSIS(l,:,:) = rankingsalg2(:,2:end);
    store_seed_rankings_VIKOR(l,:,:) = rankingsalg3(:,2:end);

    [~, ~, ~, ~, rankingsalg1_coralf] = ADRIA_DMCDA(dMCDA_vars2, 1);
    [~, ~, ~, ~, rankingsalg2_coralf] = ADRIA_DMCDA(dMCDA_vars2, 2);
    [~, ~, ~, ~, rankingsalg3_coralf] = ADRIA_DMCDA(dMCDA_vars2, 3);
    store_seed_rankings_Order_coralf(l,:,:) = rankingsalg1_coralf(:,2:end);
    store_seed_rankings_TOPSIS_coralf(l,:,:) = rankingsalg2_coralf(:,2:end);
    store_seed_rankings_VIKOR_coralf(l,:,:) = rankingsalg3_coralf(:,2:end);
end
siteranks_Order = siteRanking(store_seed_rankings_Order,"seed");
siteranks_TOPSIS = siteRanking(store_seed_rankings_TOPSIS,"seed");
siteranks_VIKOR = siteRanking(store_seed_rankings_VIKOR,"seed");
siteranks_Order_coralf = siteRanking(store_seed_rankings_Order_coralf,"seed");
siteranks_TOPSIS_coralf = siteRanking(store_seed_rankings_TOPSIS_coralf,"seed");
siteranks_VIKOR_coralf = siteRanking(store_seed_rankings_VIKOR_coralf,"seed");

T1 = table(site_data{considered_site_idx, "reef_siteid"}, considered_site_idx, ...
          considered_recom_ids, siteranks_Order, siteranks_TOPSIS, siteranks_VIKOR);

T2 = table(site_data{depth_coral_priority_idx, "reef_siteid"}, depth_coral_priority_idx , ...
          depth_coral_priority_recom_ids, siteranks_Order_coralf, siteranks_TOPSIS_coralf, siteranks_VIKOR_coralf);

filename = sprintf('./Outputs/Rankings_RCP%2.0f_Year%4.0f_revised_w_idx_mean_2015_IPMF_table_index.xlsx',RCP,Year);
T1.Properties.VariableNames = {'reef_siteid' 'site_index_id' 'recom_id' 'order_rank' 'TOPSIS_rank', 'VIKOR_rank'};
T2.Properties.VariableNames = {'reef_siteid_coral_filtered' 'site_index_id_coral_filtered' 'recom_id' 'order_rank' 'TOPSIS_rank' 'VIKOR_rank'};
writetable(T1,filename,'Sheet','Depth Filtered');
writetable(T2,filename,'Sheet','Depth & Cover <= 15% Filtered');
