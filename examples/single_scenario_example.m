%% Parameter prep
mc_scenario_generation
scenarios = table2array(converted_tbl);
IT = scenarios(:, 1:9);
criteria_weights(:, 10:end);  % need better way of separating values...

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

Y = repmat(tmp_s, ninter, 1);

%% setup for the geographical setting including environmental input layers
[wave_scen, dhw_scen] = setupADRIAsims(1, params, nsites);

% TODO: Replace these with wave/DHW projection scenarios instead

%% Scenario runs
% Currently running interventions only
%
% In actuality, this would be done for some combination of:
% intervention * criteria * environment parameters * ecological parameter
%     * wave_scen * dhw_scen * alg_ind * N_sims
% where the combinations would be generated via some quasi-monte carlo
% sequence

tic
w_scen = wave_scen(:, :, 1);
d_scen = dhw_scen(:, :, 1);
parfor i = 1:ninter
    Y(i) = runADRIAScenario(IT(i, :), criteria_weights(i, :), ...
                            param_tbl(i, :), ecol_tbl(i, :), ...
                            TP_data, site_ranks, strongpred, nsites, ...
                            w_scen, d_scen, alg_ind);
end
tmp = toc;

disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(ninter), " sims (", num2str(tmp/ninter), " seconds per run)"))

%% post-processing
% collate data across all scenario runs

tf = params.tf;
processed = struct('TC', zeros(tf, nsites, ninter, 1), 'C', zeros(tf, 4, nsites, ninter, 1), 'E', zeros(tf, nsites, ninter, 1), 'S', zeros(tf, nsites, ninter, 1));
for i = 1:ninter
    processed.TC(:, :, i, :) = Y(i).TC;
    processed.C(:, :, :, i, :) = Y(i).C;
    processed.E(:, :, i, :) = Y(i).E;
    processed.S(:, :, i, :) = Y(i).S;
end

%% analysis
ecosys_results = Corals_to_Ecosys_Services(processed);
analyseADRIAresults1(ecosys_results);
