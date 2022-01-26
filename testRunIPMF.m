
ai = ADRIA();
% site_vec = 
% cover_init = (sum over species to leave sitewise)
fn = strcat("Inputs/example_wave_DHWs_RCP_expanded_", num2str(obj.constants.RCP), ".nc");
dhw_scens = ncread(fn, "DHW");
% heat_stress_p = dhw_scens() - need to select correct year- look at data
% site_centr
% 
% replace with correct file for IPMF
[TP_data, site_ranks, strongpred] = siteConnectivity('MooreTPmean_ExpandedExample.xlsx', 0.1);

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

% Filter out sites outside of desired depth range
max_depth = criteria.depth_min + criteria.depth_offset;
depth_criteria = (site_data.sitedepth > -max_depth) & (site_data.sitedepth < -criteria.depth_min);
depth_priority = site_data{depth_criteria, "recom_connectivity"};

nsites = length(site_vec);
p_sites = zeros(nsites); % so column will be removed for priority sites
% do 20 runs to plot distributions
for ns = 1:10
    
    
    dMCDA_vars = struct('nsites', nsites, 'nsiteint', nsiteint, ...
        'prioritysites', p_sites, ...
        'strongpred', strongpred, 'centr', site_centr, 'damprob', 0, ...
        'heatstressprob', heat_stress_p, 'sumcover', cover_init, 'risktol', risktol, ...
        'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
        'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, ...
        'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, ...
        'wtpredecshade', wtpredecshade);

    % None of these should error and cause test failure
    [prefseedsites_alg1, ~, ~, ~] = ADRIA_DMCDA(dMCDA_vars, 1);
    [prefseedsites_alg2, ~, ~, ~] = ADRIA_DMCDA(dMCDA_vars, 2);
    [prefseedsites_alg3, ~, ~, ~] = ADRIA_DMCDA(dMCDA_vars, 3);
end

