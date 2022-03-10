function collated_mets = gatherSummary(file_loc, target_var, summarize)
% Gather summary statistics of results saved across many NetCDF files.
%
% Inputs:
%   file_loc   : str, directory location and filename prefix
%                  e.g., "./some_folder/file_prefix"
%   target_var : str, variable to collate (returns all results if not
%                  specified)
%   summarize  : logical, to generate a single set of summary stats (true), or
%                  to keep summary stats separate for each scenario (false; the default)
%
% Output:
%    collated_mets : struct, of summary stats for each metric across time (tf) and space (nsites).
    arguments
        file_loc string
        target_var string = "all"  % collate raw results if nothing specified.
        summarize logical = false % whether or not to collapse everything along time, or to keep individual scenarios
    end

    file_prefix = fullfile(file_loc);
    pat = strcat(file_prefix, '_*]].nc');
    file_info = dir(pat);
    folder = file_info.folder;

    % Get relevant input set
    input_md_fi = dir(strcat(file_prefix, "*]]_inputs.nc"));
    inputs = extractInputsUsed(strcat(input_md_fi.folder, "/", input_md_fi.name));
    N = height(inputs);
    clear inputs;

    % Store results in a cell array of structs
    % ds = datastore(target_files, "FileExtensions", ".nc", "Type", "file", "ReadFcn", @readDistributed);
    Y_collated = cell(N, 1);
    for file = file_info'
        fn = file.name;
        full_path = fullfile(folder, fn);
        
        [Ytable, md] = readDistributed(full_path, target_var);
        
        b_start = md.record_start;
        var_names = string(Ytable.Properties.VariableNames);
        if (target_var == "all") && ~ismember(target_var, var_names)                
            for i = b_start:md.record_end
                x = i - b_start + 1;
                Y_collated(i) = {table2struct(Ytable(x, :))};
            end
        end
    end
    
    fnames = string(fieldnames(Y_collated{1}));
    
    % Get name of metric entries (without the suffix indicating the stats)
    split_fnames = arrayfun(@(x) split(x, "__"), fnames, 'UniformOutput', false);
    unique_entries = unique(string(cellfun(@(x) string(strjoin(x(1:end-1), "__")), split_fnames, 'UniformOutput', false)));
    unique_entries = unique_entries(strlength(unique_entries) > 0);

    % Include ADRIA logs that aren't summary stats
    collated_mets = struct();
    log_entries = fnames(~contains(fnames, ["mean", "std", "median", "std", "min", "max"]));
    if ~isempty(log_entries)
        for logs = log_entries'
            % Get the average across all replicates
            tmp = concatMetrics(Y_collated, logs);
            collated_mets.(logs) = mean(tmp, ndims(tmp));
        end
    end

    for ent = unique_entries'
        if ~contains(strcat(ent, "__", "mean"), fnames)
            % skip non-summarized entries (e.g., site selection logs)
            continue
        end

        % Prep structure to hold results
        collated_mets.(ent) = struct();

        for stat = ["mean", "median", "std", "min", "max"]
            stat_func = str2func(stat);
            tmp_fn = strcat(ent, "__", stat);
            if summarize
                if ismember(stat, ["min", "max"])
                    collated_mets.(ent).(stat) = squeeze(stat_func(concatMetrics(Y_collated, tmp_fn), [], 3));
                elseif stat == "std"
                    collated_mets.(ent).(stat) = squeeze(stat_func(concatMetrics(Y_collated, tmp_fn), 0, 3));
                else
                    % mean/median
                    collated_mets.(ent).(stat) = squeeze(stat_func(concatMetrics(Y_collated, tmp_fn), 3));
                end
                
                continue
            end
            
            % Otherwise just combine results into one giant result set
            collated_mets.(ent).(stat) = concatMetrics(Y_collated, tmp_fn);
        end
    end
end


function [result, md] = readDistributed(filename, target_var)
% Helper to read ADRIA reef condition data chunked into separate files.
    arguments
        filename string
        target_var string
    end

    % Get information about NetCDF data source
    fileInfo = ncinfo(filename);
    md = getADRIARunMetadata(filename);

    % Extract variable names and datatypes
    try
        var_names = string({fileInfo.Variables.Name});
        is_group = false;
    catch ME
        if strcmp("MATLAB:structRefFromNonStruct", ME.identifier)
            is_group = true;
        else
            rethrow(ME)
        end
    end
    
    nsims = md.n_sims;
    result = table();

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

            tmp = ncread(filename, var_n);
            dim_len = ndims(tmp);
            switch dim_len
                case 5
                    parfor i = 1:nsims
                        result(i, var_n) = {tmp(:, :, :, i, :)};
                    end
                case 4
                    parfor i = 1:nsims
                        result(i, var_n) = {tmp(:, :, i, :)};
                    end
                otherwise
                    error("Unexpected number of dims in result file");
            end
        end
        
        return
    end

    % Handle cases where results were grouped
    vars = fileInfo.Groups.Variables;
    nsims = md.n_sims;
    
    if (target_var == "all") && ~contains(target_var, string({vars.Name}))
        % "all" is not in list of variables, so actually get everything

        % prep table first
        for v = 1:length(vars)
            var_name = vars(v).Name;
            result.(var_name) = cell(nsims, 1);
        end

        parfor v = 1:length(vars)
            var_name = vars(v).Name;
            for run_id = 1:nsims
                grp_name = strcat("run_", num2str(run_id));

                entry = strcat('/', grp_name, '/', var_name);
                tmp = ncread(filename, entry);
                
                switch ndims(tmp)
                    case 5
                        result(run_id, v) = {tmp(:, :, :, 1, :)};
                    case 4
                        result(run_id, v) = {tmp(:, :, 1, :)};
                    case {2,3}
                        result(run_id, v) = {tmp};
                    otherwise
                        error("Unexpected number of dims in result file");
                end
            end
        end
    elseif contains(target_var, string({vars.Name}))
        % Single target variable
        result.(target_var) = repmat({0}, nsims, 1);
        parfor run_id = 1:nsims
            grp_name = strcat("run_", num2str(run_id));
            entry = strcat('/', grp_name, '/', target_var);
            tmp = single(ncread(filename, entry));

            switch ndims(tmp)
                case 5
                    result(run_id, 1) = {tmp(:, :, :, 1, :)};
                case 4
                    result(run_id, 1) = {tmp(:, :, 1, :)};
                case {2,3}
                    result(run_id, 1) = {tmp};
                otherwise
                    error("Unexpected number of dims in result file");
            end
        end
    elseif target_var == "all"
        % single variable named "all"
        result.(target_var) = repmat({0}, nsims, 1);
        parfor run_id = 1:nsims
            grp_name = strcat("run_", num2str(run_id));
            entry = strcat('/', grp_name, '/', 'all');
            tmp = ncread(filename, entry);

            switch ndims(tmp)
                case 5
                    result(run_id, 1) = {tmp(:, :, :, 1, :)};
                case 4
                    result(run_id, 1) = {tmp(:, :, 1, :)};
                otherwise
                    error("Unexpected number of dims in result file");
            end
        end
    end
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
