%% Instantiate ADRIA Interface
ai = ADRIA();

% retrieve default criteria weights
[~, criteria, ~] = ai.splitParameterTable(ai.sample_defaults);

%% Change weights as desired
% change depth criteria so that no sites will be filtered due to depth
% plus change criteria to include shading/fogging
criteria.depth_min = 0;
criteria.shade_connectivity = 1;
criteria.wave_stress = 0;
criteria.coral_cover_high = 1;
criteria. shade_priority = 1;

tf = 74; % no. of time steps
ai.constants.tf = tf;

%% Site Data
% first create data format
sdata = readtable('./Inputs/Hastings/Site_data/Hastings_2019_630_reftable.csv');

% read in 2015 connectivity data and 2016 data to find sites in common
conn = readtable('./Inputs/Hastings/connectivity/2016/Hastings_2016_d1_transfer_probability_matrix_wide.csv');
recom_connectivity = conn.source_site;

% create vector of site_IDS
reef_siteid = sdata.site_id;

% find all sites in both the site data and connectivity files
% rename as integers for site selection indexing
inds = ismember(reef_siteid,recom_connectivity);
reef_siteid = reef_siteid(inds);

% extract area
area = sdata.area(inds);

% extract carrying capacity
k = sdata.k(inds);

% extract lat and long
lat = sdata.lat(inds);
long = sdata.long(inds);

% create fake depth vector so that no sites are filtered due to depth
nsites = sum(inds);
sitedepth = -1 * ones(nsites, 1);

%% Save site data as new file with generic structure then load in ai
% recreate site data based on generic structure
site_data_file = './Inputs/Hastings/Site_data/HastingsSiteData.csv';
sitedata_tab = table(reef_siteid, area, k, sitedepth, recom_connectivity, lat, long);
writetable(sitedata_tab, site_data_file);

% load in ai
ai.loadSiteData(site_data_file)

%% Load DHW data
n_reps = 50;
dhwRCP45 = "./Inputs/Hastings/DHWs/dhwRCP45.mat";
ai.loadDHWData(dhwRCP45,n_reps);

%% Create fake coral cover file
covers = 10*ones(nsites,2);
coral_cover_file = "./Inputs/Hastings/Site_data/HastingsCC.mat"
save(coral_cover_file,"covers")

% load file into ai
ai.loadCoralCovers(coral_cover_file)

%% Begin site selection
% connectivity years to use
cyears = [2016, 2019];
days = 1:3;
% use first step of DHW data
tstep = 1;
for d = days % connectivity days loop
    for cyr = cyears % connectivity years loop

        %% Connectivity
        sprintf("Day %1.0f, year %4.0f",d,cyr)
        connectivity_file = sprintf('./Inputs/Hastings/connectivity/%4.0f/Hastings_%4.0f_d%1.0f_transfer_probability_matrix_wide.csv', cyr,cyr,d);
        ai.loadConnectivity(connectivity_file, cutoff = 0.1);

        %% Ranking variables
        nsiteint = ai.constants.nsiteint;
        sslog = struct('seed', true, 'shade', false);
        % Set up rankings storage site_id, seeding rank, shading rank
        rankings = [(1:nsites)', zeros(nsites, 1), zeros(nsites, 1)];
        prefseedsites = zeros(nsiteint, 1);
        prefshadesites = zeros(nsiteint, 1);
        
        %% Run site selections over each RCP scenario
        rcp_ranks = struct();
 
        % calculate rankings
        % index using ind as dhw and wave data is full years data set
        order_sel = ai.siteSelection(criteria, tstep, n_reps, 1, sslog);
        topsis_sel = ai.siteSelection(criteria, tstep, n_reps, 2, sslog);
        vikor_sel = ai.siteSelection(criteria, tstep, n_reps, 3, sslog);
        
        % Store site selections
        rcp_ranks.Order = order_sel;
        rcp_ranks.TOPSIS = topsis_sel;
        rcp_ranks.VIKOR = vikor_sel;
    
        % Find mean seeding ranks over climate stochasticity
        rcp_ranks.mean_Order = siteRanking(order_sel(:, :, 2:end), 'seed');
        rcp_ranks.mean_TOPSIS = siteRanking(topsis_sel(:, :, 2:end), 'seed');
        rcp_ranks.mean_VIKOR = siteRanking(vikor_sel(:, :, 2:end), 'seed');

        %% Saving ranks
        % create filename
        filename = sprintf('./Outputs/Rankings_Hastings_connectivity%4.0f_day%1.0f.xlsx', cyr, d);
        
        % create table of ranks and corresponding ReefMod IDs
        T = table(reef_siteid, ...
            rcp_ranks.mean_Order, rcp_ranks.mean_TOPSIS, rcp_ranks.mean_VIKOR);

        % Set table column names
        T.Properties.VariableNames = {'Site ID',...
            'Order (RCP 45)', 'TOPSIS (RCP 45)', 'VIKOR (RCP 45)'};

        % Write table to Excel file
        writetable(T, filename, 'Sheet', sprintf('Site ranks'));
    end
end