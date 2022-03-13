function collated_mets = gatherSummary(file_loc, target_var, summarize)
% Gather summary statistics of results saved across many NetCDF files.
% Should only used with result sets created by running ADRIA with
% `ai.runToDisk(___, summarize=true)`
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
        collated_res = {};
        if (target_var == "all") && ~ismember(target_var, var_names)                
            for i = b_start:md.record_end
                Y_collated(i) = {table2struct(Ytable(i - b_start + 1, :))};
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
            collated_mets.(logs) = ndSparse(mean(tmp, ndims(tmp)));
            clear tmp
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
    result = table();

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
        
        return
    end

    % Handle cases where results were grouped
    vars = file_info.Groups.Variables;
    nsims = md.n_sims;

    % Get group IDs
    group_ids = netcdf.inqGrps(ncid);
    
    if (target_var == "all") && ~contains(target_var, string({vars.Name}))
        % "all" is not in list of variables, so actually get everything

        % prep table first
        for v = 1:length(vars)
            result.(vars(v).Name) = cell(nsims, 1);
        end

        % Collate data
        num_groups = length(group_ids);
        for run_id = 1:num_groups
            grp_id = group_ids(run_id);
            var_ids = netcdf.inqVarIDs(grp_id);
    
            for v_pos = 1:length(var_ids)
                v_id = var_ids(v_pos);
                v = netcdf.inqVar(grp_id, v_id);

                result(run_id, v) = {netcdf.getVar(grp_id, v_id, 'single')};
            end
        end

%         for v = 1:length(vars)
%             var_name = vars(v).Name;
%             for run_id = 1:nsims
%                 entry = strcat("/", "run_", num2str(run_id), "/", var_name);
% 
%                 var_id = netcdf.inqVarID(ncid, entry);
%                 tmp = netcdf.getVar(ncid, var_id, 'single');
%                 
%                 switch ndims(tmp)
%                     case 5
%                         result(run_id, v) = {tmp(:, :, :, 1, :)};
%                     case 4
%                         result(run_id, v) = {tmp(:, :, 1, :)};
%                     case {2,3}
%                         result(run_id, v) = {tmp};
%                     otherwise
%                         error("Unexpected number of dims in result file");
%                 end
%             end
%             
%             tmp = [];  % clear tmp
%         end
    elseif contains(target_var, string({vars.Name}))
        % Single target variable
        result.(target_var) = cell(nsims, 1);

        % Collate data
        num_groups = length(group_ids);
        for run_id = 1:num_groups
            grp_id = group_ids(run_id);

            var_id = netcdf.inqVarID(grp_id, target_var);
            result(run_id, target_var) = {netcdf.getVar(grp_id, var_id, 'single')};

%             switch ndims(tmp)
%                 case 5
%                     result(run_id, target_var) = {tmp(:, :, :, 1, :)};
%                 case 4
%                     result(run_id, target_var) = {tmp(:, :, 1, :)};
%                 case {2,3}
%                     result(run_id, target_var) = {tmp};
%                 otherwise
%                     error("Unexpected number of dims in result file");
%             end
% 
%             tmp = [];
        end

%     elseif target_var == "all"
%         % single variable named "all"
%         result.(target_var) = repmat({0}, nsims, 1);
%         for run_id = 1:nsims
%             grp_name = strcat("run_", num2str(run_id));
%             entry = strcat('/', grp_name, '/', 'all');
%             
%             var_id = netcdf.inqVarID(ncid, entry);
%             tmp = netcdf.getVar(ncid, var_id, 'single');
% 
%             switch ndims(tmp)
%                 case 5
%                     result(run_id, 1) = {tmp(:, :, :, 1, :)};
%                 case 4
%                     result(run_id, 1) = {tmp(:, :, 1, :)};
%                 otherwise
%                     error("Unexpected number of dims in result file");
%             end
%         end
%         
%         tmp = [];
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
