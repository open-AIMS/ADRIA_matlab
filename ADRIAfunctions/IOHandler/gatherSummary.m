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
%   scenarios  : array, of indices for which scenarios to read in.
%                  (defaults to all)
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
    
    % Get relevant input set
    input_md_fi = dir(strcat(file_loc, "*]]_inputs.nc"));
    N = height(extractInputsUsed(strcat(input_md_fi.folder, "/", input_md_fi.name)));

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
    [Yfirst, ~] = readDistributed(full_path, target_var, scenarios);
    var_names = string(fieldnames(Yfirst));
    if length(target_var) == 1
        if strcmp(target_var, "all") && any(contains(var_names, "all"))
            var_names = "all";
        end
    else
        % Collect the specified target variables
        var_names = target_var;
    end
    
    Ycollated = struct();
    fnames = string(fieldnames(Yfirst));
    for fn_id = 1:length(fnames)
        fn = fnames(fn_id);
        nd = ndims(Yfirst.(fn));
        cat_dim = nd;
        
        sz = size(Yfirst.(fn));
        
        % Create dimension indexer, as we don't know how big each
        % dimension is.
        sel = repmat({1}, 1, min(nd, 4));
        for i = 1:min(length(sz), 4)
            sel(i) = {1:sz(i)};
        end
        
        sz(cat_dim) = N;
        Ycollated.(fn) = zeros(sz, 'single');
        Ycollated.(fn)(sel{:}) = Yfirst.(fn);
    end

    num_vars = length(var_names);
    num_vars_str = num2str(num_vars);
    num_files = length(file_info);
    num_files_str = num2str(num_files);
    v_count = 0;

    % Collate each variable across all files
    % Although slower than looping over files first, this approach will
    % use less memory
    for vid = 1:num_vars
        f_count = 1;  % first file is already read in
        vn = var_names(vid);

        v_count = v_count + 1;
        
        nd = ndims(Ycollated.(vn));
        concat_dim = nd;  % dimension to concat over

        for file = file_info(2:end)'
            f_count = f_count + 1;

            try
                % Wrap call to wait bar around try/catch in case user
                % accidentally closes the dialog
                var_msg = strcat("Reading ", num2str(v_count), "/", num_vars_str, " metrics/logs, ");
                file_msg = strcat("from file ", num2str(f_count), "/", num_files_str);
                waitbar((v_count*f_count)/(num_vars*num_files), wb, strcat(var_msg, file_msg));
            catch
            end
        
            fn = file.name;
            full_path = fullfile(folder, fn);

            [Ystruct, md] = readDistributed(full_path, vn, scenarios);

            if isempty(Ystruct.(vn))
                continue
            end

            if isempty(Ycollated.(vn))
                Ycollated.(vn) = Ystruct.(vn);
                continue
            end

            nd = ndims(Ycollated.(vn));

            sel = repmat({1}, 1, nd);
            sz = size(Ystruct.(vn));
            sz_len = length(size(Ystruct.(vn)));
            for i = 1:sz_len
                if (i ~= concat_dim)
                    sel(i) = {1:sz(i)};
                else
                    sel(i) = {md.record_start:md.record_end};
                end
            end
            
            if i == 5
                sel = sel(1:4);
            end

            Ycollated.(vn)(sel{:}) = Ystruct.(vn);
            
            clear Ystruct;
        end

        if contains(vn, ["__mean", "__std", "__median", "__std", "__min", "__max"])
            tmp = split(vn, "__");
            stat = tmp(2);
            stat_func = str2func(stat);

            if summarize
                % Otherwise just combine results into one giant result set
                % collated_mets.(ent).(stat) = concatMetrics(Y_collated, tmp_fn);
                if (contains(vn, "__min") || contains(vn, "__max"))
                    Ycollated.(vn) = squeeze(stat_func(Ycollated.(vn), [], 3));
                elseif contains(vn, "__std")
                    Ycollated.(vn) = squeeze(mean(Ycollated.(vn), 3));
                else
                    % mean/median
                    Ycollated.(vn) = squeeze(stat_func(Ycollated.(vn), 3));
                end
            end
        else
            % Process log entries
            if summarize
                nd = ndims(Ycollated.(vn));
                Ycollated.(vn) = squeeze(mean(Ycollated.(vn), nd));
            end
        end
    end

    try
        waitbar(1,wb,'Collating...');
    catch
    end
    
    fnames = string(fieldnames(Ycollated));

    % Get name of metric entries (without the suffix indicating the stats)
    split_fnames = arrayfun(@(x) split(x, "__"), fnames, 'UniformOutput', false);
    unique_entries = unique(string(cellfun(@(x) string(strjoin(x(1:end-1), "__")), split_fnames, 'UniformOutput', false)));
    unique_entries = unique_entries(strlength(unique_entries) > 0);
    
    % Include any logs
    unique_entries = [unique_entries; fnames(contains(fnames, ["_rankings", "_log"]))];
    
    collated_mets = struct();
    for ent = unique_entries'
        if ~ismember(strcat(ent, "__mean"), fnames)
            % add log entries
            collated_mets.(ent) = Ycollated.(ent);
            Ycollated.(ent) = [];

            continue
        end

        % Prep structure to hold results
        collated_mets.(ent) = struct();
        for stat = ["mean", "median", "std", "min", "max"]
            tmp_fn = strcat(ent, "__", stat);
            
            % Combine results into one giant result set
            collated_mets.(ent).(stat) = Ycollated.(tmp_fn);
            Ycollated.(tmp_fn) = [];
        end
    end

    try
        close(wb);
    catch
    end
end


function [result, md] = readDistributed(filename, target_var, scenarios)
% Helper to read ADRIA reef condition data chunked into separate files.
    arguments
        filename string
        target_var string
        scenarios = []
    end

    % Get information about NetCDF data source
    % file_info = ncinfo(filename);
    % md = getADRIARunMetadata(filename);
    
    % Open netcdf file once
    ncid = netcdf.open(filename, 'NC_NOWRITE');
    [~, nvars, ~, ~] = netcdf.inq(ncid);
    
    md = getADRIARunMetadata(ncid);
    
    % Extract variable names and datatypes
    is_group = false;
    if nvars > 0
        var_names = cell(nvars, 1);
        for i = 1:nvars
            [vn, ~, ~, ~] = netcdf.inqVar(ncid, i);
            var_names{i} = vn;
        end
    else
        is_group = true;
        run_ids = netcdf.inqGrps(ncid);
        var_ids = netcdf.inqVarIDs(run_ids(1));
        var_names = cell(length(var_ids), 1);
        for i = 1:length(var_ids)
            [var_names{i}, ~, ~, ~] = netcdf.inqVar(run_ids(1), var_ids(i));
        end
    end

    var_names = string(var_names);
    if any(contains(var_names, target_var))
        var_names = target_var;
    end

    if ~isempty(scenarios)
        scenarios = ismember(md.record_start:md.record_end, scenarios);
        if ~any(scenarios)
            % No matching scenarios in this file so return empty struct
            result = struct();
            
            if ismember(target_var, var_names)
                result.(target_var) = [];
            else
                for v = 1:length(var_names)
                    result.(var_names(v)) = [];
                end
            end
            
            return
        end
    end

    result = struct();

    % TODO: Handle older ungrouped datasets
    if ~is_group
        % Handle older result structure where results were ungrouped
        n_vars = length(var_names);
        
        nsims = md.n_sims;
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
                    % special case fog_log with ndim=4
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

    % Get group IDs
    group_ids = netcdf.inqGrps(ncid);
    if contains(var_names, target_var)
        % Extract a single variable
        var_names = var_names(contains(var_names, target_var));
    end
    
    num_vars = length(var_names);

    % Collate data
    num_groups = length(group_ids);
    for v_id = 1:num_vars
        v = var_names(v_id);

        for run_id = 1:num_groups
            if ~isempty(scenarios)
                if ~scenarios(run_id)
                    continue
                end
            end

            grp_id = group_ids(run_id);
            var_id = netcdf.inqVarID(grp_id, v);
            
            tmp = netcdf.getVar(grp_id, var_id, 'single');
            
            if ~any(contains(fieldnames(result),v))
                % Preallocate matrix
                
                % Get info on number of dimensions
                if v == "site_rankings"
                    tmp_d = [md.n_sites, 2, num_groups];
                    nd = 3;
                    scen_dim = 3;
                elseif contains(v, "_log")
                    if v == "seed_log"
                        tmp_d = [md.n_timesteps, 2, md.n_sites, num_groups];
                        nd = 4;
                        scen_dim = 4;
                    elseif v == "fog_log"
                        tmp_d = [md.n_timesteps, md.n_sites, num_groups];
                        nd = 3;
                        scen_dim = 3;
                    end
                else
                    [~, ~, dim_ids, ~] = netcdf.inqVar(grp_id, var_id);
                    tmp_d = zeros(1, length(dim_ids));
                    for i = 1:length(dim_ids)
                        dims = dim_ids(i);
                        [~, dl] = netcdf.inqDim(grp_id, dims);
                        tmp_d(i) = dl;
                    end

                    nd = ndims(tmp);
                    
                    % Preallocate matrix for results
                    switch nd
                        case {2,3}
                            scen_dim = nd + 1;
                            tmp_d = tmp_d(1:scen_dim);
                        case {4,5}
                            scen_dim = nd-1;
                            tmp_d = tmp_d(1:4);
                    end
                    
                    tmp_d(scen_dim) = num_groups;
                end

                result.(v) = zeros(tmp_d);
                
                % Create dimension indexer, as we don't know how big each
                % dimension is.
                if v ~= "site_rankings"
                    sel = repmat({1}, 1, nd);
                else
                    sel = repmat({1}, 1, 3);
                end
                
                for i = 1:length(tmp_d)
                    sel(i) = {1:tmp_d(i)};
                end
            end 

            sel{scen_dim} = run_id;
            
            if v == "site_rankings"
                sel{2} = 1;
                result.(v)(sel{:}) = siteRanking(tmp, "seed");
                
                sel{2} = 2;
                result.(v)(sel{:}) = siteRanking(tmp, "shade");
            else
                if v == "seed_log"
                    result.(v)(sel{:}) = mean(tmp, 5);
                elseif v == "fog_log"
                    result.(v)(sel{:}) = mean(tmp, 4);
                else
                    result.(v)(sel{:}) = tmp;
                end
            end

            clear tmp;
        end
        
%         if v == "site_rankings"
%             % Store as sparse matrix as site rankings are very large!
%             result.(v) = ndSparse(result.(v));
%         end
    end
    
    netcdf.close(ncid);
end


function md = getADRIARunMetadata(ncid)
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

ncdf_const = netcdf.getConstant('NC_GLOBAL');
md.record_start = netcdf.getAtt(ncid, ncdf_const, 'record_start');
md.record_end = netcdf.getAtt(ncid, ncdf_const, 'record_end');
md.n_sims = netcdf.getAtt(ncid, ncdf_const, 'n_sims');
md.n_reps = netcdf.getAtt(ncid, ncdf_const, 'n_reps');
md.n_timesteps = netcdf.getAtt(ncid, ncdf_const, 'n_timesteps');
md.n_sites = netcdf.getAtt(ncid, ncdf_const, 'n_sites');
md.n_species = netcdf.getAtt(ncid, ncdf_const, 'n_species');
end
