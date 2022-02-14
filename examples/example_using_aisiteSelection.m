%% Example showcasing how to define and run specific scenarios

rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% Change any weights as desires
% e.g. change shade_connectivity weight and coral cover high weight to 1
ai.criterias.sample_defaults(3) = 1;
ai.criterias.sample_defaults(5) = 1;

%% Set-up scenario

% Load site specific data & connectivity
ai.loadConnectivity('./Inputs/Moore/connectivity/2015/moore_d2_2015_transfer_probability_matrix_wide.csv',cutoff=0.1);
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

% number of climatic replicates
n_reps = 10;

% specify want rankings for seeding and shading
sslog = struct('seed', true,'shade', true);

% specify species and year to use for coral cover
init_coral_cov_col = ["Acropora2026", "Goniastrea2026"];

% specify file containing dhw data
dhw_dat = "dhwRCP45.mat";

% choose algorithm to use
alg_ind = 1;

% specify timeslice to use in dhw data
tstep = 1;

%% Run site selection
% calculate rankings
rankings_mat = ai.siteSelection(n_reps,tstep,alg_ind,sslog,init_coral_cov_col,dhw_dat);
% find mean seeding ranks over climate stochasticity
mean_ranks_seed = siteRanking(rankings_mat(:,:,2:end),'seed');
% pair with site IDs
mean_ranks_seed = [rankings_mat(1,:,1)' mean_ranks_seed];

