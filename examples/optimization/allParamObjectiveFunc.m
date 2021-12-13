function av_res = allParamObjectiveFunc(x, alg, tgt_name, ...
                                       combined_opts, nsites, ...
                                       wave_scens, dhw_scens, ...
                                       params, ecol_parms, ...
                                       TP_data, site_ranks, strongpred)
% Objective function that runs a single ADRIA simulation for all
% parameters.
%
% Gives total coral cover TC as single output averaged over sites and time.
% Input : 
%     x             : array, perturbed parameters
%     alg           : int, ranking algorithm 
%     tgt_name      : str, name of output to optimize (TC, C, E, S)
%     combined_opts : table, ADRIA parameter details
%     nsites        : int, number of sites
%     wave_scens    : matrix, available wave damage scenarios
%     dhw_scens     : matrix, available DHW scenarios
%     params        : array, core ADRIA parameter values (TO BE REPLACED)
%     ecol_parms    : array, ADRIA ecological parameter values (TO BE REPLACED)
%     TP_data       : array, Transition probability data
%     site_ranks    : array, site centrality data
%     strongpred    : array, data indicating strongest predecessor per site
%
% Output : 
%     av_res : average result (specified by tgt_name) over time/sites

%% Convert sampled values back to ADRIA expected values
converted_tbl = convertScenarioSelection(x', combined_opts);
scenarios = table2array(converted_tbl);

%% Subset scenario spec for use
interv = scenarios(:, 1:9);
criteria_weights = scenarios(:, 10:end);  % need better way of separating values...

% How many wave/DHW scenarios to use
num_reps = 10;  % should move this to function definition...

%% Setup output
tf = params.tf;
n_species = params.nspecies(1);  % total number of species considered
Y_TC = zeros(tf, nsites, num_reps);
Y_C = zeros(tf, n_species, nsites, num_reps);
Y_E = zeros(tf, nsites, num_reps);
Y_S = zeros(tf, nsites, num_reps);

%% Run ADRIA
parfor i = 1:num_reps
    w_scen = wave_scens(:, :, i);
    d_scen = dhw_scens(:, :, i);
    tmp = runADRIAScenario(interv, criteria_weights, ...
                            params, ecol_parms, ...
                            TP_data, site_ranks, strongpred, ...
                            w_scen, d_scen, alg);
    Y_TC(:, :, i) = tmp.TC;
    Y_C(:, :, :, i) = tmp.C;
    Y_E(:, :, i) = tmp.E;
    Y_S(:, :, i) = tmp.S;
end


 
%% Process results
processed = struct('TC', Y_TC, 'C', Y_C, 'E', Y_E, 'S', Y_S);

%% Average over sites/time
av_res = mean(processed.(tgt_name), 'all');
end
