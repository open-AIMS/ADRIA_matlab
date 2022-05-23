%% Example showcasing how use the ADRIA interface to do pure site selection, 
% without running the ecological model

%% 1. initialize ADRIA interface
% Load site specific data & connectivity
site_data = './Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv';
conn_data = './Inputs/Moore/connectivity/2015/moore_d2_2015_transfer_probability_matrix_wide.csv';
dhw_data = './Inputs/Moore/DHWs/dhwRCP45.mat';
wave_data = './Inputs/Moore/Waves/wave_data.mat';
nreps = 10;
ai = ADRIA(connectivity=conn_data, site_data=site_data, dhw=dhw_data,...
    wave=wave_data, conn_cutoff=0.1, n_reps=nreps);

%% Set-up scenario

% specify want rankings for seeding and shading
sslog = struct('seed', true,'shade', true);

% specify species and year to use for coral cover
ai.init_coral_cov_col = ["Acropora2026", "Goniastrea2026"];

% choose algorithm to use
alg_ind = 1;

% specify timeslice to use in dhw data
tstep = 1;

% retrieve default criteria weights 
[~,criteria,~] = ai.splitParameterTable(ai.sample_defaults);

%% Change any weights as desired
% e.g. change shade_connectivity weight and coral cover high weight to 1
criteria.shade_connectivity = 1;
criteria.coral_cover_high = 1;

%% Run site selection
% calculate rankings
rankings_mat = ai.siteSelection(criteria,tstep,nreps,alg_ind,sslog);
% find mean seeding ranks over climate stochasticity
mean_ranks_seed = siteRanking(rankings_mat(:,:,2:end),'seed');
% pair with site IDs
mean_ranks_seed = [rankings_mat(1,:,1)' mean_ranks_seed];

