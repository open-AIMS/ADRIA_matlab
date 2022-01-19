
ai = ADRIA();
rd = ai.sample_defaults;
eg_vals = ai.convertSamples(rd);
eg_vals = table2array(eg_vals);

[TP_data, site_ranks, strongpred] = siteConnectivity('MooreTPmean.xlsx', 0.1);

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

nsites = length(strongpred);
risktol = eg_vals(1, 9); % risk tolerance

%% Testing randomised sites

% do 10 trials...
for ns = 1:10
    % nsites = rand_sites(ns);
    
    % Randomly select number of sites to intervene
    % and priority sites
    nsiteint = randi([1, nsites], 1);
    p_sites = randi([1,9], 1):randi([10,25], 1);
    
    dMCDA_vars = struct('nsites', nsites, 'nsiteint', nsiteint, ...
        'prioritysites', p_sites, ...
        'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, ...
        'heatstressprob', 0, 'sumcover', 0, 'risktol', risktol, ...
        'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
        'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, ...
        'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, ...
        'wtpredecshade', wtpredecshade);

    % None of these should error and cause test failure
    [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 1);
    [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 2);
    [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 3);
end

%% Testing zero sites
% Intervene on zero sites - this should give zeros for the output 
nsiteint = 0;
p_sites = randi([1,9], 1):randi([10,25], 1);

dMCDA_vars = struct('nsites', nsites, 'nsiteint', nsiteint, ...
    'prioritysites', p_sites, ...
    'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, ...
    'heatstressprob', 0, 'sumcover', 0, 'risktol', risktol, ...
    'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
    'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, ...
    'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, ...
    'wtpredecshade', wtpredecshade);

% These should all be zero
[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 1);
tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 0), "All values expected to be 0, but some were not")

[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 2);

tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 0), "All values expected to be 0, but some were not")

[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 3);
tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 0), "All values expected to be 0, but some were not")

%% Testing one site
% Intervene on zero sites - this should give zeros for the output 
nsites = length(strongpred);
nsiteint = 1;
p_sites = randi([1,9], 1):randi([10,25], 1);

dMCDA_vars = struct('nsites', nsites, 'nsiteint', nsiteint, ...
    'prioritysites', p_sites, ...
    'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, ...
    'heatstressprob', 0, 'sumcover', 0, 'risktol', risktol, ...
    'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
    'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, ...
    'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, ...
    'wtpredecshade', wtpredecshade);

% None of these should error and cause test failure (test if 1 or 0 as
% either the single site does not satify the wave and heat risk tolerances
% and so = 0 or it does and = 1)
[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 1);
tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 1) || all(tmp == 0), "All values expected to be 1, but some were not")
[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 2);
tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 1) || all(tmp == 0), "All values expected to be 1, but some were not")
[prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, 3);
tmp = [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites];
assert(all(tmp == 1) || all(tmp == 0), "All values expected to be 1, but some were not")