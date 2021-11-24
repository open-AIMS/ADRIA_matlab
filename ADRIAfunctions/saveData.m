function saveData(data, filename, dim_spec, nc_varname)
    % Save data to file in CSV, `.mat` or NetCDF format.
    %
    % If file is not specified, generates a filename based on date/time.
    %
    % If NetCDF format is specified, attempts to create a new NetCDF file
    % and field/variable (specified by `nc_varname`). If the file already
    % exists, then the new variable is created. This function does not
    % support overwriting existing variables and so variable names must be
    % unique.
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
    valid_formats = {'mat', 'csv', 'nc'};

    if exist('filename', 'var')
        tmp = split(filename, '.');

        if length(tmp) == 1
            % if no extension is provided, default to `.csv`
            fmt = 'csv';
            filename = strcat(filename, '.', fmt);
            fprintf('Format not specified. Saving results to %s \n', filename);
        else
            % Check that specified format is supported
            fmt = tmp(end);

            msg = strcat('Unknown format "', fmt, '" specified. Specify one of: ');
            valid_fmts = ' ' + strjoin(string(valid_formats), ' ');
            file_msg = msg + valid_fmts;

            if ~ismember(fmt, valid_formats)
                error(file_msg)
            end
        end
    else
        % filename not provided
        fmt = 'csv';
        right_now = datetime(now, 'ConvertFrom', 'datenum');
        right_now = replace(string(right_now), ' ', '_');
        right_now = replace(right_now, ':', '');

        filename = strcat('ADRIA_results_', right_now, '.', fmt);

        fprintf('File name not provided. Saving results to %s \n', filename);
    end

    if strcmpi(fmt, 'mat')
        save(filename, 'data');
    elseif strcmpi(fmt, 'csv')
        writematrix(data, filename);
    elseif strcmpi(fmt, 'nc')
        if ~exist('dim_spec', 'var')
            error('No data dimension details provided.');
        end

        if ~exist('nc_varname', 'var')
            nc_varname = 'data';
        end

        nccreate(filename, nc_varname, 'Dimensions', dim_spec);
        ncwrite(filename, nc_varname, data);
    else
        error(file_msg)
    end
end
