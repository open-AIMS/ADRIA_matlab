%% Parameter prep
mc_scenario_generation
scenarios = table2array(converted_tbl);
IT = scenarios(:, 1:9);
criteria_weights = scenarios(:, 10:end);  % need better way of separating values...

% interventions = interventionSpecification(sims=10);
% [IT, ~] = interventionTable(interventions); %calls function that builds intervention table, ...

% criteria_weights = criteriaWeights();
[params, ecol_params] = ADRIAparms(); %environmental and ecological parameter values etc
ninter = size(IT, 1);
alg_ind = 1;

%% Load site data
[F0, xx, yy, nsites] = ADRIA_siteTable('MooreSites.xlsx');
[TP_data, site_ranks, strongpred] = ADRIA_TP('MooreTPmean.xlsx', params.con_cutoff);

%% ... generate parameter permutations ...
% Creating dummy permutations
param_tbl = struct2table(params);
ecol_tbl = struct2table(ecol_params);

param_tbl = repmat(param_tbl, ninter, 1);
ecol_tbl = repmat(ecol_tbl, ninter, 1);
criteria_weights = repmat(criteria_weights, ninter, 1);

%% Setup output
% Create temporary struct
tmp_s.TC = 0;
tmp_s.C = 0;
tmp_s.E = 0;
tmp_s.S = 0;

%% Determine total number of scenarios
num_reps = 3;  % Number of replicate RCP scenarios
Y = repmat(tmp_s, ninter, num_reps);

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
for i = 1:ninter
    scen_it = IT(i, :);
    scen_crit = criteria_weights(i, :);
    scen_params = param_tbl(i, :);
    ecol_params = ecol_tbl(i, :);
    parfor j = 1:num_reps
        w_scen = wave_scen(:, :, j);
        d_scen = dhw_scen(:, :, j);
        Y(i, j) = runADRIAScenario(scen_it, scen_crit, ...
                                scen_params, ecol_params, ...
                                TP_data, site_ranks, strongpred, nsites, ...
                                w_scen, d_scen, alg_ind);
    end
end
tmp = toc;

disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(ninter*num_sims), " scenarios (", num2str(tmp/(ninter*num_sims)), " seconds per run)"))

%% post-processing
% collate data across all scenario runs

tf = params.tf;
processed = struct('TC', zeros(tf, nsites, ninter, num_sims), ...
                   'C', zeros(tf, 4, nsites, ninter, num_sims), ...
                   'E', zeros(tf, nsites, ninter, num_sims), ...
                   'S', zeros(tf, nsites, ninter, num_sims));
for i = 1:ninter
    for j = 1:num_reps
        processed.TC(:, :, i, j) = Y(i, j).TC;
        processed.C(:, :, :, i, j) = Y(i, j).C;
        processed.E(:, :, i, j) = Y(i, j).E;
        processed.S(:, :, i, j) = Y(i, j).S;
    end
end

%% analysis
ecosys_results = Corals_to_Ecosys_Services(processed);
analyseADRIAresults1(ecosys_results);
