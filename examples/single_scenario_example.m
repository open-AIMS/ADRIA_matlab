% Example script illustrating running ADRIA one scenario at a time.

%% Generate monte carlo samples

% number of scenarios (not factoring in RCP replicates)
N = 8;

inter_opts = interventionDetails();
criteria_opts = criteriaDetails();

% all available parameter options
combined_opts = [inter_opts; criteria_opts];

% Generate using simple monte carlo
% Create selection table based on lower/upper parameter bounds
p_sel = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound{p};
    b = combined_opts.upper_bound{p};
    
    selection = (b - a) .* rand(N, 1) + a;
    
    p_sel.(combined_opts.name{p}) = selection;
end

% Convert sampled values to ADRIA usable values
% Necessary as samplers expect real-valued parameters (e.g., floats)
% where as in practice ADRIA makes use of integer and categorical
% parameters
converted_tbl = convertScenarioSelection(p_sel, combined_opts);

%% Parameter prep
scenarios = table2array(converted_tbl);

% Separate parameters into components
% (to be replaced with a better way of separating these...)
IT = scenarios(:, 1:9);
criteria_weights = scenarios(:, 10:end);

% Environmental and ecological parameter values etc
[params, ecol_params] = ADRIAparms();
% ninter = size(IT, 1);
alg_ind = 1;

%% Load site data
[F0, xx, yy, nsites] = ADRIA_siteTable('MooreSites.xlsx');
[TP_data, site_ranks, strongpred] = ADRIA_TP('MooreTPmean.xlsx', params.con_cutoff);

%% ... generate parameter permutations ...
% Creating dummy permutations
param_tbl = struct2table(params);
ecol_tbl = struct2table(ecol_params);

param_tbl = repmat(param_tbl, N, 1);
ecol_tbl = repmat(ecol_tbl, N, 1);
% criteria_weights = repmat(criteria_weights, ninter, 1);

%% Setup output
% Create temporary struct
tmp_s.TC = 0;
tmp_s.C = 0;
tmp_s.E = 0;
tmp_s.S = 0;

%% Determine total number of simulations
num_reps = 3;  % Number of replicate RCP scenarios
Y = repmat(tmp_s, N, num_reps);

%% setup for the geographical setting including environmental input layers
% [wave_scen, dhw_scen] = setupADRIAsims(num_sims, params, nsites);

% Load wave/DHW scenario data
% Generated with generateWaveDHWs.m
% TODO: Replace these with wave/DHW projection scenarios instead
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(params.RCP), ".nc");
wave_scen = ncread(fn, "wave");
dhw_scen = ncread(fn, "DHW");

%% Scenario runs
% Currently running interventions only
%
% In actuality, this would be done for some combination of:
% intervention * criteria * environment parameters * ecological parameter
%     * wave_scen * dhw_scen * alg_ind * N_sims
% where the combinations would be generated via some quasi-monte carlo
% sequence

tic
for i = 1:N
    scen_it = IT(i, :);
    scen_crit = criteria_weights(i, :);
    scen_params = param_tbl(i, :);
    ecol_params = ecol_tbl(i, :);
    parfor j = 1:num_reps
        w_scen = wave_scen(:, :, j);
        d_scen = dhw_scen(:, :, j);
        Y(i, j) = runADRIAScenario(scen_it, scen_crit, ...
                                   scen_params, ecol_params, ...
                                   TP_data, site_ranks, strongpred, ...
                                   w_scen, d_scen, alg_ind);
    end
end
tmp = toc;

disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*num_reps), " scenarios (", num2str(tmp/(N*num_reps)), " seconds per run)"))

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
