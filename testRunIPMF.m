%% Load site data;
% Connectivity
[TP_data, site_ranks, strong_pred] = siteConnectivity('./Inputs/Moore/connectivity/2015', 0.1);

% Site Data
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id", "k", ["Acropora2026", "Goniastrea2026"], "sitedepth", "recom_connectivity"]]);
site_data = sortrows(site_data, "recom_connectivity");
[~, ~, g_idx] = unique(site_data.recom_connectivity, 'rows', 'first');
TP_data = TP_data(g_idx, g_idx);

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
depth_offset =5; % depth range from min depth

% Filter out sites outside of desired depth range
max_depth = depth_min + depth_offset;
depth_criteria = (site_data.sitedepth > -max_depth) & (site_data.sitedepth < -depth_min);
depth_priority = site_data{depth_criteria, "recom_connectivity"};

max_cover = site_data.k/100.0; % Max coral cover at each site

nsites = length(depth_priority);
p_sites = zeros(nsites); % so column will be removed for priority sites

% do 20 runs to plot distributions
%for ns = 1:10
    
sumcover =    site_data.Acropora2026 + site_data.Goniastrea2026;

dMCDA_vars = struct('site_ids', depth_priority, 'nsiteint', nsiteint, 'prioritysites', [], ...
            'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, 'heatstressprob', 0, ...
            'sumcover', sumcover,'maxcover', max_cover, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
            'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed,...
            'wtpredecshade', wtpredecshade);

% None of these should error and cause test failure
[prefseedsites_alg1, ~, ~, ~] = ADRIA_DMCDA(dMCDA_vars, 1);
[prefseedsites_alg2, ~, ~, ~] = ADRIA_DMCDA(dMCDA_vars, 2);
[prefseedsites_alg3, ~, ~, ~] = ADRIA_DMCDA(dMCDA_vars, 3);
%end

