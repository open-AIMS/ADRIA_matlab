function result = readDistributed(filename, func)
% Read ADRIA reef condition data chunked into separate files.
% Data is parsed through the provided function handle (`func`).

    % Get information about NetCDF data source
    fileInfo = ncinfo(filename);
    md = getADRIARunMetadata(filename);

    % Extract variable names and datatypes
    var_names = string({fileInfo.Variables.Name});
    
    n_vars = length(var_names);
    
    result = table();
    for v = 1:n_vars
        var_n = var_names{v};

        tmp = ncread(filename, var_n);
        result.(var_n) = func(tmp, md);
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
