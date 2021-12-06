function saveData(data, filename, nc_settings)
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
    % Note: If NetCDF is specified and `data` is a struct,
    %    this function will attempt to create an entry for each item
    %    and infer its dimensions (up to 5) and name (using the struct
    %    fieldnames).
    %
    % Inputs:
    %     data       : any, data to save
    %     filename   : str (optional), file name and location of file.
    %                    Defaults to `ADRIA_results_[current time].csv`
    %                    if nothing specified.
    %     nc_settings: Named Arguments (optional, required for `.nc`).
    %                    - var_name : string, name of variable
    %                    - dim_spec : cell, of variable dimensions
    %                        e.g., `{'x_name', x_data, 'y_name', y_data}`
    %                    - compression : int, compression level to use
    %                        0 to 9, where 0 is no compression, and 9 is
    %                        maximum compression.
    %                        Defaults to 4.
    %
    % Example:
    %     data = rand(5,5)
    %
    %     % These are equivalent
    %     saveData(data, 'example')
    %     saveData(data, 'example.csv')
    %
    %     % Saving a 5x5 dimension array to NetCDF
    %     saveData(data, 'example.nc', var_name='out', 
    %              dim_spec={'x', 5, 'y', 5}, compression=4)
    %
    %     % Saving a struct to NetCDF
    %     % Supports up to 5 dimensions per variable
    %     tmp = struct('x', rand(2,2), 'y', rand(2,2,2,2))
    %     saveData(tmp, 'example.nc', compression=8)
    arguments
        data
        filename string
        nc_settings.var_name string
        nc_settings.dim_spec cell
        nc_settings.compression {mustBeNumeric} = 4
    end
        
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
        c_level = nc_settings.compression;

        if ~isstruct(data)
            if ~exist('dim_spec', 'var')
                error('No data dimension details provided.');
            end

            if ~exist('nc_varname', 'var')
                nc_varname = 'data';
            end
            
            nccreate(filename, nc_varname, 'Dimensions', dim_spec, ...
                     'DeflateLevel', c_level);
            ncwrite(filename, nc_varname, data);
        else
            f_names = fieldnames(data);
            n_vars = length(f_names);
            for i = 1:n_vars
                tmp_fn = f_names{i};
                t_data = data.(tmp_fn);
                [x, y, z, v, w] = size(t_data);

                nccreate(filename, tmp_fn, 'Dimensions', ...
                    {[tmp_fn '_x'], x, [tmp_fn '_y'], y, ...
                     [tmp_fn '_z'], z, [tmp_fn '_v'], v, ...
                     [tmp_fn '_w'], w}, 'DeflateLevel', c_level)
                ncwrite(filename, tmp_fn, t_data)
            end
        end

        
    else
        error(file_msg)
    end
end
