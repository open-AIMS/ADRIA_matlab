% Example script illustrating running ADRIA scenarios

%% Generate monte carlo samples

% Number of scenarios
N = 8;
num_reps = 3;  % Number of replicate RCP scenarios

% Collect details of available parameters
inter_opts = interventionDetails();
criteria_opts = criteriaDetails();

% Create main table listing all available parameter options
combined_opts = [inter_opts; criteria_opts];

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
p_sel = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound{p};
    b = combined_opts.upper_bound{p};
    
    selection = (b - a).*rand(N, 1) + a;
    
    p_sel.(combined_opts.name{p}) = selection;
end

%% Parameter prep

% Creating dummy permutations for core ADRIA parameters
% (environmental and ecological parameter values etc)
% This process will be replaced
[params, ecol_params] = ADRIAparms();
param_tbl = struct2table(params);
ecol_tbl = struct2table(ecol_params);

param_tbl = repmat(param_tbl, N, 1);
ecol_tbl = repmat(ecol_tbl, N, 1);

% Convert sampled values to ADRIA usable values
% Necessary as samplers expect real-valued parameters (e.g., floats)
% where as in practice ADRIA makes use of integer and categorical
% parameters
converted_tbl = convertScenarioSelection(p_sel, combined_opts);

% Separate parameters into components
% (to be replaced with a better way of separating these...)
IT = converted_tbl{:, 1:9};
criteria_weights = converted_tbl{:, 10:end};

% use order-ranking for example
alg_ind = 1;

%% Load site specific data
[F0, xx, yy, nsites] = ADRIA_siteTable('MooreSites.xlsx');
[TP_data, site_ranks, strongpred] = ADRIA_TP('MooreTPmean.xlsx', params.con_cutoff);

%% setup for the geographical setting including environmental input layers
% Load wave/DHW scenario data
% Generated with generateWaveDHWs.m
% TODO: Replace these with wave/DHW projection scenarios instead
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(params.RCP), ".nc");
wave_scen = ncread(fn, "wave");
dhw_scen = ncread(fn, "DHW");

%% Scenario runs
% Currently running over unique interventions and criteria weights only for
% a limited number of RCP scenarios.
%
% In actuality, this would be done for some combination of:
% intervention * criteria * environment parameters * ecological parameter
%     * wave_scen * dhw_scen * alg_ind * N_sims
% where the unique combinations would be generated via some quasi-monte 
% carlo sequence, or through some user-informed process.

tic
Y = runScenarios(IT, criteria_weights, param_tbl, ecol_tbl, ...
                 TP_data, site_ranks, strongpred, num_reps, ...
                 wave_scen, dhw_scen, alg_ind);
tmp = toc;

disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*num_reps), " simulations (", num2str(tmp/(N*num_reps)), " seconds per run)"))

%% post-processing
% collate data across all scenario runs

tf = params.tf;
processed = struct('TC', zeros(tf, nsites, N, num_reps), ...
                   'C', zeros(tf, 4, nsites, N, num_reps), ...
                   'E', zeros(tf, nsites, N, num_reps), ...
                   'S', zeros(tf, nsites, N, num_reps));
for i = 1:N
    for j = 1:num_reps
        processed.TC(:, :, i, j) = Y(i, j).TC;
        processed.C(:, :, :, i, j) = Y(i, j).C;
        processed.E(:, :, i, j) = Y(i, j).E;
        processed.S(:, :, i, j) = Y(i, j).S;
    end
end

%% analysis
% ecosys_results = coralsToEcosysServices(processed);
% analyseADRIAresults1(ecosys_results);
