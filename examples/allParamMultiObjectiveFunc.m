function av_res = allParamMultiObjectiveFunc(x, alg, tgt_names, ...
                                       combined_opts, nsites, ...
                                       wave_scens, dhw_scens, ...
                                       params, ecol_parms, ...
                                       TP_data, site_ranks, ...
                                       strongpred, ES_vars)
    % Objective function that runs a single ADRIA simulation for all
    % parameters.
    %
    % Gives total coral cover TC as single output averaged over sites and time.
    % Input : 
    %     x             : array, perturbed parameters
    %     alg           : int, ranking algorithm 
    %     tgt_names      : cell of strs, name of output to optimize (TC, E, S, CES, PES)
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
    % Create temporary struct
    tmp_s.TC = 0;
    tmp_s.E = 0;
    tmp_s.S = 0;

    Y = repmat(tmp_s, 1, num_reps);

    %% Run ADRIA
    parfor i = 1:num_reps
        w_scen = wave_scens(:, :, i);
        d_scen = dhw_scens(:, :, i);
        Y(i) = runADRIAScenario(interv, criteria_weights, ...
                                params, ecol_parms, ...
                                TP_data, site_ranks, strongpred, nsites, ...
                                w_scen, d_scen, alg);
    end

    %% Process results
    % check if any ES to be calculated
    if any(strcmp(tgt_names,'CES'))||any(strcmp(tgt_names,'PES'))
        tf = params.tf;
        processed = struct('TC', zeros(tf, nsites, 1, num_reps), ...
                       'E', zeros(tf, nsites, 1, num_reps), ...
                       'S', zeros(tf, nsites, 1, num_reps),...
                       'CES', zeros(tf, nsites, 1, num_reps),...
                       'PES', zeros(tf, nsites, 1, num_reps));
        for i = 1:num_reps
            processed.TC(:, :, :, i) = Y(i).TC;
            processed.E(:, :, :, i) = Y(i).E;
            processed.S(:, :, :, i) = Y(i).S;
        end

        outs_ES = coralsToEcosysServices(processed,ES_vars);
        
        if any(strcmp(tgt_names,'CES'))
            processed.CES = outs_ES.CES;
        elseif any(strcmp(tgt_names,'PES'))
            processed.PES = outs_ES.PES;
        end

    else
        %% Process results
        tf = params.tf;
        processed = struct('TC', zeros(tf, nsites, 1, num_reps), ...
                       'E', zeros(tf, nsites, 1, num_reps), ...
                       'S', zeros(tf, nsites, 1, num_reps));
        for nn = 1:length(tgt_names)
            tgt_name = tgt_names{nn};
            for i = 1:num_reps
                processed.(tgt_name)(:, :, :, i) = Y(i).(tgt_name);
            end
        end
    end

    %% Average over sites/time
    av_res = zeros(length(tgt_names));
    for kk = 1:length(tgt_names)
        av_res(kk) = mean(processed.(tgt_names{k}), 'all');
    end
end
