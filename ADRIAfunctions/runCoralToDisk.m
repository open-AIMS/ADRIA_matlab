function runCoralToDisk(intervs, crit_weights, coral_params, sim_params, ...
                              TP_data, site_ranks, strongpred, ...
                              initial_cover, ...
                              n_reps, wave_scen, dhw_scen, site_data, ...
                              collect_logs, file_prefix, batch_size, ...
                              metrics, summarize, ode_func,ode_opts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ADRIA: Adaptive Dynamic Reef Intervention Algorithm %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run all simulations, writing results to file in `netcdf` format.
%
% Inputs:
%    interv       : table, of intervention scenarios
%    crit_weights : table, of criteria weights for each scenario
%    coral_params : table, of coral parameter values for each scenario
%    sim_params   : struct, of simulation constants
%    TP_data      : matrix, of transition probabilities (connectivity)
%    site_ranks   :
%    strongpred   : matrix, strongest predecessor for each site
%    initial_cover: matrix[timesteps, nsites, N], initial coral cover data
%    n_reps       : int, number of replicates to use
%    wave_scen    : matrix[timesteps, nsites, N], spatio-temporal wave damage scenario
%    dhw_scen     : matrix[timesteps, nsites, N], degree heating weeek scenario
%    site_data    : table, of site data
%    collect_logs : string, of what logs to collect
%                     "seed", "shade", "site_rankings" etc.
%    file_prefix : str, write results to batches of netCDFs instead of
%                    storing in memory.
%    batch_size : int, number of simulations per worker to run at a time.
%    metrics : cell, of function handles
%    ode_func : function handle, designates the solver to be used to solve
%               the growth ode at each time step.
%    ode_opts : struct with labels 'abstol' and 'reltol', designates
%               tolerances to be used in ode solver.
% Output:
%    results : struct,
%          - Y, [n_timesteps, n_sites, N, n_reps]
%          - seed_log, [n_timesteps, n_sites, N, 2, n_reps]
%          - shade_log, [n_timesteps, n_sites, N, n_reps]
%          - shade_log, [n_timesteps, n_sites, N, n_reps]
%
% Example:
%     >> runCoralToDisk(interv_scens, criteria_weights, coral_params, ...
%                       sim_constants, ...
%                       TP_data, site_ranks, strongpred, n_reps, ...
%                       w_scens, d_scens, './test', 4);
%     >> Y = collectDistributedResults('./test', N, n_reps, n_species=36);

N = height(intervs);

nsites = height(site_data);
timesteps = sim_params.tf;

% Create output matrices
coral_spec = coralSpec();
nspecies = height(coral_spec);  % total number of species considered

file_prefix = string(file_prefix);

% Ensure directory exists
has_sep = contains(file_prefix, filesep) | contains(file_prefix, "/");
if ~has_sep
    msg = ['Provided file prefix does not specify folder.' newline ...
           'Use "./" if current working directory is intended.'];
    error(msg);
end

pathparts = strsplit(file_prefix, {filesep,'/'});
target_dir = join(pathparts(1:end-1), filesep);
if ~isfolder(target_dir)
    warning(strcat("Target directory '", target_dir, "' not found! Creating..."))
    mkdir(target_dir);
end

n_batches = ceil(N / batch_size);
b_starts = 1:batch_size:N;
b_ends = [batch_size:batch_size:N, N];

% pre-assign scenario specs for each batch
b_intervs = cell(n_batches,1);
b_cws = cell(n_batches,1);
b_coralp = cell(n_batches,1);
parfor b_i = 1:n_batches
    b_start = b_starts(b_i);
    b_end = b_ends(b_i);
    b_intervs{b_i} = intervs(b_start:b_end, :);
    b_cws{b_i} = crit_weights(b_start:b_end, :);
    
    b_coralp{b_i} = coral_params(b_start:b_end, :);
end

% Remove vars to save memory
clear('intervs')
clear('crit_weights')

w_scen_ss = wave_scen(:, :, 1:n_reps);
d_scen_ss = dhw_scen(:, :, 1:n_reps);

% Catch for special edge case when only a single scenario is available
coral_cover_dims = ndims(initial_cover);
if coral_cover_dims == 3
    initial_cover = initial_cover(:, :, 1:n_reps);
elseif coral_cover_dims == 2
    initial_cover = repmat(initial_cover, 1, 1, n_reps);
end

parfor b_i = 1:n_batches
    b_start = b_starts(b_i);
    b_end = b_ends(b_i);
    
    tmp_fn = strcat(file_prefix, '_[[', num2str(b_start), '-', num2str(b_end), ']].nc');
    if isfile(tmp_fn)
        % sims already run, skip...
        msg = strcat("Result file ", tmp_fn, " found. Skipping...");
        warning(msg);
        continue
    end
    
    b_len = (b_end - b_start) + 1;
    b_interv = b_intervs{b_i};
    b_cw = b_cws{b_i};
    b_cp = b_coralp{b_i};
    
    % Create empty log cache, otherwise matlab complains about
    % uninitialized temporary variables
    seed_log = [];
    shade_log = [];
    fog_log = [];
    rankings = [];
    
    if any(strlength(collect_logs) > 0)
        if any(ismember("seed", collect_logs))
            % 2 = number of species being seeded
            seed_log = zeros(timesteps, 2, nsites, 1, n_reps);
        end

        if any(ismember("shade", collect_logs))
            shade_log = zeros(timesteps, nsites, 1, n_reps);
        end
        
        if any(ismember("fog", collect_logs))
            fog_log = zeros(timesteps, nsites, 1, n_reps);
        end

        if any(ismember("site_rankings", collect_logs))
            rankings = zeros(timesteps, nsites, 2, 1, n_reps);
        end
    end
    
    for i = 1:b_len
        scen_it = b_interv(i, :);
        scen_crit = b_cw(i, :);
        
        % Note: This slows things down considerably
        % Could rejig everything to use (subset of) the table directly...
        scen_coral_params = extractCoralSamples(b_cp(i, :), coral_spec);
        
        raw = zeros(timesteps, nspecies, nsites, 1, n_reps);

        for j = 1:n_reps
            res = coralScenario(scen_it, scen_crit, ...
                                   scen_coral_params, sim_params, ...
                                   TP_data, site_ranks, strongpred, ...
                                   initial_cover(:, :, j), ...
                                   w_scen_ss(:, :, j), d_scen_ss(:, :, j), ...
                                   site_data, collect_logs,ode_func,ode_opts);
            raw(:, :, :, 1, j) = res.Y;
            
            if any(strlength(collect_logs) > 0)
                if any(ismember("seed", collect_logs))
                    seed_log(:, :, :, 1, j) = res.seed_log;
                end
                
                if any(ismember("shade", collect_logs))
                    shade_log(:, :, 1, j) = res.shade_log;
                end
                
                if any(ismember("fog", collect_logs))
                    fog_log(:, :, 1, j) = res.fog_log;
                end
                
                if any(ismember("site_rankings", collect_logs))
                    rankings(:, :, :, 1, j) = res.site_rankings;
                end
            end
        end
        
        % save results
        if isempty(metrics)
            tmp_d = struct("all", raw);
        else
            tmp_d = collectMetrics(raw, coral_params, metrics);
            
            if summarize
                tmp_d = summarizeMetrics(tmp_d);
            end
        end
        
        if any(strlength(collect_logs) > 0)
            % Store the average locations/ranks for each climate replicate
            if any(ismember("seed", collect_logs))
                tmp_d.seed_log = mean(seed_log, ndims(seed_log));
            end

            if any(ismember("shade", collect_logs))
                tmp_d.shade_log = mean(shade_log, ndims(shade_log));
            end
            
            if any(ismember("fog", collect_logs))
                tmp_d.fog_log = mean(fog_log, ndims(fog_log));
            end

            if any(ismember("site_rankings", collect_logs))
                rankings(rankings == 0) = nsites + 1;
                tmp_d.site_rankings = mean(rankings, ndims(rankings));
            end
        end
        
        saveData(tmp_d, tmp_fn, group=strcat("run_", num2str(i)));
        
        % Reassign large data structures to save memory
        % (can't use `clear` here due to `parfor`)
        raw = [];
        tmp_d = [];

    end

    % include metadata
    nc_md = struct(...
        'record_start', b_start, ...
        'record_end', b_end, ...
        'n_sims', b_len, ...
        'n_reps', n_reps, ...
        'n_timesteps', timesteps, ...
        'n_sites', nsites, ...
        'n_species', nspecies);
    saveData(struct(), tmp_fn, attributes=nc_md);
end

end