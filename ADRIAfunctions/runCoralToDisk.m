function runCoralToDisk(intervs, crit_weights, coral_params, sim_params, ...
                              TP_data, site_ranks, strongpred, ...
                              init_cov, ...
                              n_reps, wave_scen, dhw_scen, site_data, ...
                              collect_logs, file_prefix, batch_size)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ADRIA: Adaptive Dynamic Reef Intervention Algorithm %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run all simulations, writing results to file in `netcdf` format.
%
% Inputs:
%    interv       : table, of intervention scenarios
%    criteria     : table, of criteria weights for each scenario
%    coral_params : table, of ecological parameter permutations
%    sim_params   : struct, of simulation constants
%    wave_scen    : matrix[timesteps, nsites, n_reps], spatio-temporal wave damage scenario
%    dhw_scen     : matrix[timesteps, nsites, n_reps], degree heating weeek scenario
%    site_data    : table, holding max coral cover, recom site ids, etc.
%    collect_logs : string, indication of what logs to collect - "seed", "shade", "site_rankings"
%    file_prefix : str, write results to batches of netCDFs instead of
%                    storing in memory.
%    batch_size : int, size of simulation batches to run/save when writing
%                    to disk.
%
% Output:
%    results : struct,
%          - Y, [n_timesteps, n_sites, N, n_reps]
%          - seed_log, [n_timesteps, n_sites, N, n_species, n_reps]
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
for b_i = 1:n_batches
    b_start = b_starts(b_i);
    b_end = b_ends(b_i);
    b_intervs{b_i} = intervs(b_start:b_end, :);
    b_cws{b_i} = crit_weights(b_start:b_end, :);
    
    b_coralp{b_i} = coral_params(b_start:b_end, :);
end

% Remove vars to save memory
clear('intervs')
clear('crit_weights')

parfor b_i = 1:n_batches
    b_start = b_starts(b_i);
    b_end = b_ends(b_i);
    initial_cover = init_cov;
    
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
    
    % Create batch cache
    raw = zeros(timesteps, nspecies, nsites, b_len, n_reps);
    
    % Create empty log cache, otherwise matlab complains about
    % uninitialized temporary variables
    seed_log = [];
    shade_log = [];
    rankings = [];
    
    if strlength(collect_logs) > 0
        if ismember("seed", collect_logs)
            seed_log = ndSparse(zeros(timesteps, nspecies, nsites, b_len, n_reps));
        end

        if ismember("shade", collect_logs)
            shade_log = ndSparse(zeros(timesteps, nsites, b_len, n_reps));
        end

        if ismember("site_rankings", collect_logs)
            rankings = ndSparse(zeros(timesteps, nsites, 2, b_len, n_reps));
        end
    end
    
    for i = 1:b_len
        scen_it = b_interv(i, :);
        scen_crit = b_cw(i, :);
        
        % Note: This slows things down considerably
        % Could rejig everything to use (subset of) the table directly...
        scen_coral_params = extractCoralSamples(b_cp(i, :), coral_spec);

        if isempty(initial_cover)
            initial_cover = repmat(scen_coral_params.basecov, 1, nsites);
        end

        for j = 1:n_reps
            w_scen = wave_scen(:, :, j);
            d_scen = dhw_scen(:, :, j);
            res = coralScenario(scen_it, scen_crit, ...
                                   scen_coral_params, sim_params, ...
                                   TP_data, site_ranks, strongpred, ...
                                   initial_cover, ...
                                   w_scen, d_scen, ...
                                   site_data, collect_logs);
            raw(:, :, :, i, j) = res.Y;
            
            if strlength(collect_logs) > 0
                if ismember("seed", collect_logs)
                    seed_log(:, :, :, i, j) = res.seed_log;
                end
                
                if ismember("shade", collect_logs)
                    shade_log(:, :, i, j) = res.shade_log;
                end
                
                if ismember("site_rankings", collect_logs)
                    rankings(:, :, :, i, j) = res.MCDA_rankings;
                end
            end
        end
    end
    
    % save results
    tmp_d = struct();
    tmp_d.all = raw;
    
    if strlength(collect_logs) > 0
        if ismember("seed", collect_logs)
            tmp_d.seed_log = full(seed_log);
        end

        if ismember("shade", collect_logs)
            tmp_d.shade_log = full(shade_log);
        end

        if ismember("site_rankings", collect_logs)
            tmp_d.MCDA_rankings = full(rankings);
        end
    end
    
    % include metadata
    nc_md = struct();
    nc_md.record_start = b_start;
    nc_md.record_end = b_end;
    nc_md.n_sims = b_len;
    nc_md.n_reps = n_reps;
    nc_md.n_timesteps = timesteps;
    nc_md.n_sites = nsites;
    nc_md.n_species = nspecies;
    
    saveData(tmp_d, tmp_fn, attributes=nc_md);
    
    % Clear vars to save memory
    % (can't use `clear` here due to `parfor`)
    tmp_d = [];
end

end