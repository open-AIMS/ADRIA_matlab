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
%   target_var   : str, variable to collate (returns everything if not
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

    % Store results in a cell array of structs
    % ds = datastore(target_files, "FileExtensions", ".nc", "Type", "file", "ReadFcn", @readDistributed);
    i = 1;
    for file = file_info'
        fn = file.name;
        full_path = fullfile(folder, fn);
        [Ytable, md] = readDistributed(full_path, target_var);
        
        b_start = md.record_start;
        b_len = md.n_sims;
        Ytmp = repmat({0}, height(b_len), 1);
        if isempty(metrics)
            % Collate raw results if no metrics specified
            for j = 1:b_len
                t = struct();
                t.(target_var) = Ytable{j, :}{1};  % Extract from individual cell values
                Ytmp{j, :} = t;
            end
        else
            cp_subset = coral_params(b_start:b_start+(b_len-1), :);
            parfor j = 1:b_len
                Ytmp{j} = collectMetrics(Ytable{j, :}{:}, cp_subset(j, :), metrics);
            end
        end
        
        Y_collated(b_start:(b_start+b_len)-1) = Ytmp;
        
        i = i + 1;
    end
    
    Y_collated = Y_collated';
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
    var_names = string({fileInfo.Variables.Name});
    
    n_vars = length(var_names);
    result = table();
    nsims = md.n_sims;
    for v = 1:n_vars
        var_n = var_names{v};
        if var_n ~= target_var
            % skip logs for now...
            % we'd need to restructure the return type to be a struct
            % or add a flag indicating what result set (raw or logs) is 
            % desired...
            continue
        end
        result.(var_n) = repmat({0}, nsims, 1);
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
