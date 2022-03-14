function collated_mets = gatherSummary(file_loc, opts)
% Gather summary statistics of results saved across many NetCDF files.
% Should only used with result sets created by running ADRIA with
% `ai.runToDisk(___, summarize=true)`
%
% Inputs:
%   file_loc   : str, directory location and filename prefix
%                  e.g., "./some_folder/file_prefix"
%   target_var : str, variable to collate (returns all results if not
%                  specified)
%   scenarios  : array, of indices or booleans indicating which scenarios
%                  to keep. Defaults to all.
%   summarize  : logical, to generate a single set of summary stats (true), or
%                  to keep summary stats separate for each scenario (false; the default)
%
% Output:
%    collated_mets : struct, of summary stats for each metric across time (tf) and space (nsites).
    arguments
        file_loc string
        opts.target_var string = "all"  % collate raw results if nothing specified.
        opts.scenarios = []
        opts.summarize logical = false % whether or not to collapse everything along time, or to keep individual scenarios
    end
    
    target_var = opts.target_var;
    scenarios = opts.scenarios;
    summarize = opts.summarize;

    file_prefix = fullfile(file_loc);
    pat = strcat(file_prefix, '_*]].nc');
    file_info = dir(pat);
    folder = file_info.folder;

    % ds = datastore(target_files, "FileExtensions", ".nc", "Type", "file", "ReadFcn", @readDistributed);
    wb = waitbar(0, 'Collecting summarized result set...');
    
    % Get list of variable names
    file = file_info(1);
    fn = file.name;
    full_path = fullfile(folder, fn);

    % Get initial dataset
    [Ycollated, ~] = readDistributed(full_path, target_var);
    var_names = string(fieldnames(Ycollated));
    if contains("all", var_names)
        var_names = "all";
    end

    num_vars = length(var_names);
    num_vars_str = num2str(num_vars);
    v_count = 0;

    % Collate each variable across all files
    % Although slower than looping over files first, this approach will
    % use less memory
    for vid = 1:num_vars
        vn = var_names(vid);

        v_count = v_count + 1;

        waitbar(v_count/num_vars, wb, strcat("Reading ", num2str(v_count), " of ", num_vars_str, " metrics/logs"));
        for file = file_info(2:end)'
            fn = file.name;
            full_path = fullfile(folder, fn);

            [Ystruct, ~] = readDistributed(full_path, vn);

            nd = ndims(Ycollated.(vn));
            if nd < 5
                nd_tmp = nd;
            elseif nd == 5
                nd_tmp = 4;
            end

            Ycollated.(vn) = cat(nd_tmp, Ycollated.(vn), Ystruct.(vn));
        end

        if contains(vn, ["__mean", "__std", "__median", "__std", "__min", "__max"])
            tmp = split(vn, "__");
            stat = tmp(2);
            stat_func = str2func(stat);

            if ~isempty(scenarios)
                tmp = Ycollated.(vn);
                Ycollated.(vn) = tmp(:, :, scenarios);
                clear tmp;
            end

            if summarize
                % Otherwise just combine results into one giant result set
                % collated_mets.(ent).(stat) = concatMetrics(Y_collated, tmp_fn);
                if (contains(vn, "__min") || contains(vn, "__max"))
                    Ycollated.(vn) = squeeze(stat_func(Ycollated.(vn), [], 3));
                elseif contains(vn, "__std")
                    Ycollated.(vn) = squeeze(stat_func(Ycollated.(vn), 0, 3));
                else
                    % mean/median
                    Ycollated.(vn) = squeeze(stat_func(Ycollated.(vn), 3));
                end
            end
        else
            % log entries
            nd = ndims(Ycollated.(vn));
            if nd == 5
                % ndSparse arrays don't like being summarized across
                % multiple dimensions so apply mean twice
                % once across replicates, another across scenarios
                Ycollated.(vn) = squeeze(mean(Ycollated.(vn), 5));

                if ~isempty(scenarios)
                    tmp = Ycollated.(vn);
                    Ycollated.(vn) = tmp(:, :, :, scenarios);
                    clear tmp;
                end

                if summarize
                    Ycollated.(vn) = squeeze(mean(Ycollated.(vn), 4));
                end
            elseif nd < 5
                if vn == "fog_log"
                    % Handle special case for fog_log with ndims == 4
                    Ycollated.(vn) = squeeze(mean(Ycollated.(vn), 3));
                end

                if ~isempty(scenarios)
                    tmp = Ycollated.(vn);
                    Ycollated.(vn) = tmp(:, :, scenarios);
                    clear tmp;
                end

                if summarize
                    Ycollated.(vn) = squeeze(mean(Ycollated.(vn), 3));
                end
            end
        end
    end

    waitbar(1,wb,'Finishing');
    
    waitbar(1, wb, 'Collating...');
    
    fnames = string(fieldnames(Ycollated));

    % Get name of metric entries (without the suffix indicating the stats)
    split_fnames = arrayfun(@(x) split(x, "__"), fnames, 'UniformOutput', false);
    unique_entries = unique(string(cellfun(@(x) string(strjoin(x(1:end-1), "__")), split_fnames, 'UniformOutput', false)));
    unique_entries = unique_entries(strlength(unique_entries) > 0);
    
    collated_mets = struct();
    for ent = unique_entries'
        if ~contains(strcat(ent, "__", "mean"), fnames)
            % add log entries
            collated_mets.(ent) = Ycollated.(ent);
            Ycollated.(ent) = [];
            continue
        end

        % Prep structure to hold results
        collated_mets.(ent) = struct();

        for stat = ["mean", "median", "std", "min", "max"]
            % stat_func = str2func(stat);
            tmp_fn = strcat(ent, "__", stat);
            
            % Combine results into one giant result set
            collated_mets.(ent).(stat) = Ycollated.(tmp_fn);
            Ycollated.(tmp_fn) = [];
        end
    end

    close(wb);
end


function [result, md] = readDistributed(filename, target_var)
% Helper to read ADRIA reef condition data chunked into separate files.
    arguments
        filename string
        target_var string
    end

    % Get information about NetCDF data source
    file_info = ncinfo(filename);
    md = getADRIARunMetadata(filename);

    % Extract variable names and datatypes
    try
        var_names = string({file_info.Variables.Name});
        is_group = false;
    catch ME
        if strcmp("MATLAB:structRefFromNonStruct", ME.identifier)
            is_group = true;
        else
            rethrow(ME)
        end
    end

    nsims = md.n_sims;
    result = struct();

    % Open netcdf file once
    ncid = netcdf.open(filename, 'NC_NOWRITE');

    if ~is_group
        % Handle older result structure where results were ungrouped
        n_vars = length(var_names);
        for v = 1:n_vars
            var_n = var_names{v};
            if ~contains(target_var, var_n)
                % skip logs for now...
                % we'd need to restructure the return type to be a struct
                % or add a flag indicating what result set (raw or logs) is 
                % desired...
                continue
            end
            
            var_id = netcdf.inqVarID(ncid, var_n);
            tmp = netcdf.getVar(ncid, var_id, 'single');

            dim_len = ndims(tmp);
            switch dim_len
                case 5
                    result(1:nsims, var_n) = {tmp(:, :, :, 1:nsims, :)};
                case 4
                    result(1:nsims, var_n) = {tmp(:, :, 1:nsims, :)};
                otherwise
                    error("Unexpected number of dims in result file");
            end

            clear tmp;
        end
        
        netcdf.close(ncid);
        
        return
    end

    % Handle cases where results were grouped
    vars = file_info.Groups.Variables;

    % Get group IDs
    group_ids = netcdf.inqGrps(ncid);
    var_names = string({vars.Name});
    if contains(target_var, var_names)
        % Extract a single variable
        result.(target_var) = [];
        num_vars = 1;
        var_names = var_names(var_names == target_var);
    else
        % If above two conditions are not matched, then extract everything
        for v = 1:length(var_names)
            result.(var_names(v)) = [];
        end
        
        num_vars = length(var_names);
    end

    % Collate data
    num_groups = length(group_ids);
    log_match = ["_log", "_rankings"];
    for v_id = 1:num_vars
        v = var_names(v_id);
        for run_id = 1:num_groups
            grp_id = group_ids(run_id);
            var_id = netcdf.inqVarID(grp_id, v);

            tmp = netcdf.getVar(grp_id, var_id, 'single');

            nd = ndims(tmp);
            if nd == 5
                nd_tmp = 4;
            else
                nd_tmp = nd+1;
            end

            if contains(v, log_match)
                result.(v) = ndSparse(cat(nd_tmp, result.(v), tmp));
            else
                result.(v) = cat(nd_tmp, result.(v), tmp);
            end

            clear tmp;
        end
        
        result.(v) = squeeze(result.(v));
    end
    
    netcdf.close(ncid);
end


function md = getADRIARunMetadata(filename)
% Helper function to collect metadata from netCDFs.
% 
% record_start
% record_end
% n_sims
% n_reps
% n_timesteps
% n_sites
% n_species
md = struct();
md.record_start = ncreadatt(filename, "/", "record_start");
md.record_end = ncreadatt(filename, "/", "record_end");
md.n_sims = ncreadatt(filename, "/", "n_sims");
md.n_reps = ncreadatt(filename, "/", "n_reps");
md.n_timesteps = ncreadatt(filename, "/", "n_timesteps");
md.n_sites = ncreadatt(filename, "/", "n_sites");
md.n_species = ncreadatt(filename, "/", "n_species");
end
