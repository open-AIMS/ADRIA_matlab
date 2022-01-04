% Example script illustrating running ADRIA scenarios
rng(101)

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

% Optional step: Extract unique scenarios
[u_ss, u_rows, group_idx] = mapDuplicateScenarios(converted_tbl);

% Separate parameters into components
% (to be replaced with a better way of separating these...)
interv_scens = u_ss(:, 1:9);  % intervention scenarios
criteria_weights = u_ss(:, 10:end);

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
wave_scens = ncread(fn, "wave");
dhw_scens = ncread(fn, "DHW");

%% Scenario runs
% Currently running over unique interventions and criteria weights only for
% a limited number of RCP scenarios.
%
% In actuality, this would be done for some combination of:
% intervention * criteria * environment parameters * ecological parameter
%     * wave_scen * dhw_scen * alg_ind * N_sims
% where the unique combinations would be generated via some quasi-monte 
% carlo sequence, or through some user-informed process.

% Select random subset of RCP conditions WITHOUT replacement
n_rep_scens = length(wave_scens);
rcp_scens = datasample(1:n_rep_scens, num_reps, 'Replace', false);
w_scens = wave_scens(:, :, rcp_scens);
d_scens = dhw_scens(:, :, rcp_scens);

tic
Y = runADRIA(interv_scens, criteria_weights, param_tbl, ecol_tbl, ...
                 TP_data, site_ranks, strongpred, num_reps, ...
                 w_scens, d_scens, alg_ind);
tmp = toc;

disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*num_reps), " simulations (", num2str(tmp/(N*num_reps)), " seconds per run)"))

% Map unique scenarios to original scenario list
Y = mapDuplicateResults(Y, u_rows, group_idx);

%% post-processing
% collate data across all scenario runs

% tf = params.tf;
% nspecies = 4;
% processed = struct('TC', zeros(tf, nsites, N, num_reps), ...
%                    'C', zeros(tf, nspecies, nsites, N, num_reps), ...
%                    'E', zeros(tf, nsites, N, num_reps), ...
%                    'S', zeros(tf, nsites, N, num_reps));
% for i = 1:N
%     for j = 1:num_reps
%         processed.TC(:, :, i, j) = Y.TC(i, j);
%         processed.C(:, :, :, i, j) = Y.C(i, j);
%         processed.E(:, :, i, j) = Y.E(i, j);
%         processed.S(:, :, i, j) = Y.S(i, j);
%     end
% end
processed = Y;

%% analysis
% Prompt for importance balancing
MetricPrompt = {'Relative importance of coral evenness for cultural ES (proportion):', ...
        'Relative importance of structural complexity for cultural ES (proportion):', ...
        'Relative importance of coral evenness for provisioning ES (proportion):', ...
        'Relative importance of structural complexity for provisioning ES (proportion):', ...
        'Total coral cover at which scope to support Cultural ES is maximised:', ...
        'Total coral cover at which scope to support Provisioning ES is maximised:', ...
        'Row used as counterfactual:'};
dlgtitle = 'Coral metrics and scope for ecosystem-services provision';
dims = [1, 50];
definput = {'0.5', '0.5', '0.2', '0.8', '0.5', '0.5', '1'};
answer = inputdlg(MetricPrompt, dlgtitle, dims, definput, "off");
evcult = str2double(answer{1});
strcult = str2double(answer{2});
evprov = str2double(answer{3});
strprov = str2double(answer{4});
TCsatCult = str2double(answer{5});
TCsatProv = str2double(answer{6});
cf = str2double(answer{7}); %counterfactual

ES_vars = [evcult, strcult, evprov, strprov, TCsatCult, TCsatProv, cf];

ecosys_results = coralsToEcosysServices(processed, ES_vars);
analyseADRIAresults1(ecosys_results);
