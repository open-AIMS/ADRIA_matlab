function Y_collated = collectDistributedResults(file_prefix, N, n_reps, opts)
% Collects results from ADRIA runs spread across many NetCDF files.
% This implementation assumes there is sufficient memory available to hold
% the resulting data set.
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
        opts.n_species {mustBeInteger} = 36
    end

    dir_name = opts.dir_name;
    n_species = opts.n_species;

    file_prefix = fullfile(dir_name, file_prefix);
    pat = strcat(file_prefix, '_*.nc');
    target_files = dir(pat);

    num_files = length(target_files);

    msg = ['Mismatch between number of detected files ' ...
           'and provided scenario combinations.' newline ...
           strcat('Expected: ', num2str(N)) newline ...
           strcat('Found: ', num2str(num_files))];
    if ~(N == num_files)
        warning(msg);
    end

    for i = 1:num_files
        f_dir = target_files(i).folder;
        fn = target_files(i).name;

        % Get range of runs stored in file
        % TODO: This metadata could be stored within the file itself.
        run_id = extract(fn, '_[[' + digitsPattern + '-' + digitsPattern + ']]');
        run_id = num2cell(sscanf(run_id{1}, '_[[%i-%i]]')');
        batch_range = run_id{1}:run_id{2};

        full_path = fullfile(f_dir, fn);

        % Get variable names to loop over
        var_names = {ncinfo(full_path).Variables.Name};
        n_vars = length(var_names);

        if ~exist('Y_collated', 'var')
            tmp_read = ncread(full_path, var_names{1});
            [nsteps, nsites, ~, ~] = size(tmp_read);
            
            Y_collated.TC = zeros(nsteps, nsites, N, n_reps);
            Y_collated.C = zeros(nsteps, n_species, nsites, N, n_reps);
            Y_collated.E = zeros(nsteps, nsites, N, n_reps);
            Y_collated.S = zeros(nsteps, nsites, N, n_reps);
        end

        for v = 1:n_vars
            var_n = var_names{v};
            if ~(var_n == "C")
                Y_collated.(var_n)(:, :, batch_range, :) = ncread(full_path, var_n);
            else
                Y_collated.C(:, :, :, batch_range, :) = ncread(full_path, 'C');
            end
        end
    end
end