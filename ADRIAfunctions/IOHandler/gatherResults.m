function Y_collated = gatherResults(file_loc, coral_params, metrics)
% Gather results for a given set of metrics from ADRIA runs spread across 
% many NetCDF files.
%
% Inputs:
%   file_loc     : str, directory location and filename prefix
%                   e.g., "./some_folder/file_prefix"
%   coral_params : table, coral parameters used in all runs
%   metrics      : cell, array of functions to apply. If none provided, 
%                    collates the raw results instead.
%
% Output:
%    Y_collated : cell, of structs for each run, with fieldnames for each metric.
    arguments
        file_loc string
        coral_params table
        metrics cell = {}
    end

    file_prefix = fullfile(file_loc);
    pat = strcat(file_prefix, '_*]].nc');
    target_files = dir(pat);

    num_files = length(target_files);

    % Store results in a cell array of structs
    Y_collated = repmat({0}, height(coral_params), 1);
    for i = 1:num_files
        f_dir = target_files(i).folder;
        fn = target_files(i).name;
        
        full_path = fullfile(f_dir, fn);
        [Ytable, md] = readDistributed(full_path);
        
        b_start = md.record_start;
        if isempty(metrics)
            % Collate raw results if no metrics specified
            b_end = md.record_end;
            Y_collated(b_start:b_end) = Ytable{:, :};
        else
            b_len = md.n_sims;
            for j = 1:b_len
                rec_id = (b_start - 1) + j;
                Y_collated{rec_id} = collectMetrics(Ytable{j, :}{:}, coral_params(rec_id, :), metrics);
            end
        end
    end
end


function [result, md] = readDistributed(filename)
% Helper to read ADRIA reef condition data chunked into separate files.

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
        result.(var_n) = repmat({0}, nsims, 1);
        tmp = ncread(filename, var_n);
        for i = 1:nsims
        	result(i, var_n) = {tmp(:, :, :, i, :)};
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
