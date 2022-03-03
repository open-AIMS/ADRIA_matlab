function Y_collated = gatherResults(file_loc, coral_params, metrics, target_var)
% Gather results for a given set of metrics from ADRIA runs spread across 
% many NetCDF files.
%
% Inputs:
%   file_loc     : str, directory location and filename prefix
%                   e.g., "./some_folder/file_prefix"
%   coral_params : table, coral parameters used in all runs
%   metrics      : cell, array of functions to apply. If none provided, 
%                    collates the raw results instead.
%   target_var   : str, variable to collate (returns raw results if not
%                    specified)
%
% Output:
%    Y_collated : cell, of structs for each run, with fieldnames for each metric.
    arguments
        file_loc string
        coral_params table
        metrics cell = {}  % Collate results with no transformation if nothing specified.
        target_var string = "all"  % collate raw results if nothing specified.
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
    Y_collated = repmat({0}, N, 1);
    for file = file_info'
        fn = file.name;
        full_path = fullfile(folder, fn);
        
        [Ytable, md] = readDistributed(full_path, target_var);
        
        b_start = md.record_start;
        b_len = md.n_sims;
        if isempty(metrics)
            subset = b_start:(b_start+b_len-1);
            Ytmp = repmat({0}, height(b_len), 1);

            % Collate raw results if no metrics specified
            for j = 1:b_len
                % Extract from individual cell values
                Ytmp{j, :} = struct(target_var, Ytable{j, :}{1});
            end
            
            Y_collated(subset) = Ytmp;
            % Y_collated(subset) = {struct(target_var, Ytable{:, :}{:})};
        else
            var_names = string(Ytable.Properties.VariableNames);
            if (target_var == "all") && ~ismember(target_var, var_names)
                result_var_names = string(Ytable.Properties.VariableNames);
                for v = 1:length(var_names)
                    vname = var_names(v);
                    for j = 1:b_len
                        if ismember(vname, result_var_names)
                            Y_collated(b_start-1+j) = {table2struct(Ytable(j, var_names))};
                        else
                            Y_collated(b_start-1+j) = {collectMetrics(...
                                Ytable.(vname){j}, ...
                                coral_params(b_start-1+j, :), ...
                                metrics)};
                        end
                    end
                end
            else
                for j = 1:b_len
                    Y_collated(b_start-1+j) = {collectMetrics(...
                        Ytable.(target_var){j}, ...
                        coral_params(b_start-1+j, :), ...
                        metrics)};
                end
            end
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
            if var_n ~= target_var
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
                    for i = 1:nsims
                        result(i, var_n) = {tmp(:, :, :, i, :)};
                    end
                case 4
                    for i = 1:nsims
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
    
    if (target_var == "all") && ~ismember(target_var, string({vars.Name}))
        for v = 1:length(vars)
            var_name = vars(v).Name;
            result.(var_name) = repmat({0}, nsims, 1);
            for run_id = 1:nsims
                grp_name = strcat("run_", num2str(run_id));

                entry = strcat('/', grp_name, '/', var_name);
                tmp = ncread(filename, entry);
                
                switch ndims(tmp)
                    case 5
                        result(run_id, var_name) = {tmp(:, :, :, 1, :)};
                    case 4
                        result(run_id, var_name) = {tmp(:, :, 1, :)};
                    case 3
                        result(run_id, var_name) = {tmp};
                    otherwise
                        error("Unexpected number of dims in result file");
                end
            end
        end
    elseif ismember(target_var, string({vars.Name}))
        result.(target_var) = repmat({0}, nsims, 1);
        for run_id = 1:nsims
            grp_name = strcat("run_", num2str(run_id));
            entry = strcat('/', grp_name, '/', target_var);
            tmp = ncread(filename, entry);

            switch ndims(tmp)
                case 5
                    result(run_id, target_var) = {tmp(:, :, :, 1, :)};
                case 4
                    result(run_id, target_var) = {tmp(:, :, 1, :)};
                case 3
                    result(run_id, target_var) = {tmp};
                otherwise
                    error("Unexpected number of dims in result file");
            end
        end
    elseif target_var == "all"
        result.(target_var) = repmat({0}, nsims, 1);
        for run_id = 1:nsims
            grp_name = strcat("run_", num2str(run_id));
            entry = strcat('/', grp_name, '/', 'all');
            tmp = ncread(filename, entry);

            switch ndims(tmp)
                case 5
                    result(run_id, "all") = {tmp(:, :, :, 1, :)};
                case 4
                    result(run_id, "all") = {tmp(:, :, 1, :)};
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
