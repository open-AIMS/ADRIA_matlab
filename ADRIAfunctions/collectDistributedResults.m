function Y_collated = collectDistributedResults(file_prefix, N, n_reps, opts)
% Collects results from ADRIA runs spread across many NetCDF files.
%
% Inputs:
%   file_prefix : str, prefix applied to filenames
%   N           : int, number of expected scenarios
%   n_reps      : int, number of expected replicates
%   dir_name    : str, (optional) directory to search
%                   Default: current working directory
%   n_species   : int, (optional) number of species considered. Default: 4
%
% Output:
%    Y_collated : struct,
%          - TC [n_timesteps, n_sites, N, n_reps]
%          - C  [n_timesteps, n_sites, N, n_species, n_reps]
%          - E  [n_timesteps, n_sites, N, n_reps]
%          - S  [n_timesteps, n_sites, N, n_reps]
    arguments
        file_prefix string
        N {mustBeInteger}
        n_reps {mustBeInteger}
        opts.dir_name string = './'
        opts.n_species {mustBeInteger} = 4
    end

    dir_name = opts.dir_name;
    n_species = opts.n_species;
    
    file_prefix = strcat(dir_name, file_prefix);
    pat = strcat(file_prefix, '_*.nc');
    target_files = dir(pat);
    
    num_files = length(target_files);
    
    % TODO: ensure num_files == (N * n_reps)
    msg = ['Mismatch between number of detected files ' ...
           'and provided scenario combinations.' newline ...
           strcat('Expected: ', N) newline ...
           strcat('Found: ', num2str(num_files))];
    assert(N == num_files, msg)

    for i = 1:num_files
        f_dir = target_files(i).folder;
        fn = target_files(i).name;
        run_id = extract(fn, '_' + digitsPattern);
        run_id = num2cell(sscanf(run_id{1}, '_%i')');
        
        full_path = strcat(f_dir, '/', fn);
        
        % Get variable names to loop over
        var_names = {ncinfo(full_path).Variables.Name};
        n_vars = length(var_names);
        
        if ~exist('tmp_s', 'var')
            tmp_read = ncread(full_path, var_names{1});
            [nsteps, nsites, sim_len, rep_len] = size(tmp_read);
            
            tmp_s.TC = zeros(nsteps, nsites, N, n_reps);
            tmp_s.C = zeros(nsteps, n_species, nsites, N, n_reps);
            tmp_s.E = zeros(nsteps, nsites, N, n_reps);
            tmp_s.S = zeros(nsteps, nsites, N, n_reps);
        end

        for v = 1:n_vars
            var_n = var_names(v);
            if ~(var_n{1} == "C")
                tmp_s.(var_n{1})(:, :, run_id{:}, :) = ncread(full_path, var_n{1});
            else
                tmp_s.C(:, :, :, run_id{:}, :) = ncread(full_path, 'C');
            end
        end
    end
    
    Y_collated = tmp_s;
end