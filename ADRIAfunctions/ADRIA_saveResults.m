function ADRIA_saveResults(data, filename, dim_spec, nc_varname)
    % Save data to file in CSV, `.mat` or NetCDF format.
    %
    % If file is not specified, generates a filename based on date/time
    %
    % Inputs:
    %     data       : any, data to save
    %     filename   : str (optional), file name and location of file.
    %                    Defaults to `ADRIA_results_[current time].csv`
    %                    if nothing specified.
    %     dim_spec   : cell array (optional), name/dimensions of `data`.
    %                    Required for 'nc'.
    %                    e.g., `{'x_name', x_data, 'y_name', y_data}`
    %     nc_varname : str (optional), variable name to save data to in the
    %                    NetCDF file. Required for 'nc'.
    %
    % Example:
    %     data = rand(5,5)
    %
    %     % These are equivalent
    %     saveData(data, 'example')
    %     saveData(data, 'example.csv')
    %
    %     % Saving a 5x5 dimension array to NetCDF
    %     saveData(data, 'example.nc', {'x', 5, 'y', 5}, 'varname')
    warning("ADRIA_saveResults() is deprecated. Use saveData() instead.")
    if nargin < 3
        saveData(data, filename)
    else
        saveData(data, filename, dim_spec, nc_varname)
    end
end
