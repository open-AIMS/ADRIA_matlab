
ai = ADRIA();
rd = ai.sample_defaults;
eg_vals = ai.convertSamples(rd);
eg_vals = table2array(eg_vals);

[TP_data, site_ranks, strongpred] = siteConnectivity('moore_d2_2015_transfer_probability_matrix_wide.csv', 0.1);
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id", "k", [strcat("Acropora",yrstr), strcat("Goniastrea",yrstr)], "sitedepth", "recom_connectivity"]]);
site_data = sortrows(site_data, "recom_connectivity");
[~, ~, g_idx] = unique(site_data.recom_connectivity, 'rows', 'first');
TP_data = TP_data(g_idx, g_idx);

dhw_scen = load("dhwRCP45.mat").dhw(1:tf, :, 1:nreps);

% Weights for connectivity , waves (ww), high cover (whc) and low
wtwaves = eg_vals(:, 1); % weight of wave damage in MCDA
wtheat = eg_vals(:, 2); % weight of heat damage in MCDA
wtconshade = eg_vals(:, 3); % weight of connectivity for shading in MCDA
wtconseed = eg_vals(:, 4); % weight of connectivity for seeding in MCDA
wthicover = eg_vals(:, 5); % weight of high coral cover in MCDA (high cover gives preference for seeding corals but high for SRM)
wtlocover = eg_vals(:, 6); % weight of low coral cover in MCDA (low cover gives preference for seeding corals but high for SRM)
wtpredecseed = eg_vals(:, 7); % weight for the importance of seeding sites that are predecessors of priority reefs
wtpredecshade = eg_vals(:, 8); % weight for the importance of shading sites that are predecessors of priority reefs
risktol = eg_vals(1, 9); % risk tolerance

depth_min = 5; % minimum site depth
depth_offset = 5; % depth range from min depth


% Filter out sites outside of desired depth range
max_depth = depth_min + depth_offset;
depth_criteria = (site_data.sitedepth > -max_depth) & (site_data.sitedepth < -depth_min);
depth_priority = site_data{depth_criteria, "recom_connectivity"};
nsites = length(strongpred);
risktol = eg_vals(1, 9); % risk tolerance

%% Testing randomised sites

sslog = struct('seed',true,'shade',false);

% do 10 trials...
for ns = 1:10
    % Randomly select number of sites to intervene
    % and priority sites
    nsiteint = randi([1, nsites], 1);
    p_sites = randi([1,9], 1):randi([10,25], 1);
    
    rankings = zeros(nsites, 3);
    rankings(:, 1) = 1:nsites;
    
    prefseedsites = zeros(1,nsiteint);
    prefshadesites = zeros(1,nsiteint);
    
    dMCDA_vars = struct('site_ids', depth_priority, 'nsiteint', nsiteint, ...
        'prioritysites', p_sites, 'maxcover', repmat(0.8, 26, 1), ...
        'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', zeros(26,1), ...
        'heatstressprob', zeros(26,1), 'sumcover', zeros(26,1), 'risktol', risktol, ...
        'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
        'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, ...
        'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, ...
        'wtpredecshade', wtpredecshade);

    % None of these should error and cause test failure
    [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 1, sslog, prefseedsites, prefshadesites, rankings);
    [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 2, sslog, prefseedsites, prefshadesites, rankings);
    [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 3, sslog, prefseedsites, prefshadesites, rankings);
end

%% Testing zero sites
% Intervene on zero sites - this should give zeros for the output 
nsiteint = 0;
p_sites = randi([1,9], 1):randi([10,25], 1);

dMCDA_vars = struct('site_ids', [1:26]', 'nsiteint', nsiteint, ...
    'prioritysites', p_sites, 'maxcover', repmat(0.8, 26, 1), ...
    'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', zeros(26,1), ...
    'heatstressprob', zeros(26,1), 'sumcover', zeros(26,1), 'risktol', risktol, ...
    'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
    'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, ...
    'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, ...
    'wtpredecshade', wtpredecshade);

sslog = struct('seed',true,'shade',false);

rankings = zeros(nsiteint, 3);
rankings(:, 1) = 1:nsiteint;

prefseedsites = zeros(1,nsiteint);
prefshadesites = zeros(1,nsiteint);

% These should all be zero
[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 1, sslog, prefseedsites, prefshadesites, rankings);
tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 0), "All values expected to be 0, but some were not")

[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 2, sslog, prefseedsites, prefshadesites, rankings);

tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 0), "All values expected to be 0, but some were not")

[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 3, sslog, prefseedsites, prefshadesites, rankings);
tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 0), "All values expected to be 0, but some were not")

%% Testing one site
% Intervene on zero sites - this should give zeros for the output 
nsites = length(strongpred);
nsiteint = 1;
p_sites = randi([1,9], 1):randi([10,25], 1);

dMCDA_vars = struct('site_ids', [1:26]', 'nsiteint', nsiteint, ...
    'prioritysites', p_sites, 'maxcover', repmat(0.8, 26, 1), ...
    'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', ones(26,1), ...
    'heatstressprob', ones(26,1), 'sumcover', zeros(26,1), 'risktol', risktol, ...
    'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
    'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, ...
    'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, ...
    'wtpredecshade', wtpredecshade);

% None of these should error and cause test failure (test if 1 or 0 as
% either the single site does not satify the wave and heat risk tolerances
% and so = 0 or it does and = 1)
strategy = 1;
sslog = struct('seed',true,'shade',false);

rankings = zeros(nsiteint, 3);
rankings(:, 1) = 1:nsiteint;

prefseedsites = zeros(1,nsiteint);
prefshadesites = zeros(1,nsiteint);
        
[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, strategy, sslog, prefseedsites, prefshadesites, rankings);
num_selected = [nprefseedsites, nprefshadesites];
assert(all(num_selected == 1), "Number of sites expected to be 1, but some were not");

% sel_sites = [prefseedsites, prefshadesites];
% assert(sel_sites == sel_sites(1), "Selected sites should be identical!");

[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 2, sslog, prefseedsites, prefshadesites, rankings);
num_selected = [nprefseedsites, nprefshadesites];
assert(all(num_selected == 1), "Number of sites expected to be 1, but some were not");

[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 3, sslog, prefseedsites, prefshadesites, rankings);
num_selected = [nprefseedsites, nprefshadesites];
assert(all(num_selected == 1), "Number of sites expected to be 1, but some were not");
