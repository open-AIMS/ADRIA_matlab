function saveData(data, filename, nc_settings)
    % Save data to file in CSV, `.mat` or NetCDF format.
    %
    % If filename is not specified, generates a filename based on date/time.
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
    %                        e.g., `{'x_name', 10, 'y_name', 5}`
    %                    - compression : int, compression level to use
    %                        0 to 9, where 0 is no compression, and 9 is
    %                        maximum compression.
    %                        Defaults to 4.
    %                    - group : string, optional group name to save
    %                        under
    %                    If a struct is provided as data, attempts to
    %                    infer variable names and dimensions from fields.
    %
    % Example:
    %     data = rand(5,5)
    %
    %     % These are equivalent
    %     saveData(data, 'example')
    %     saveData(data, 'example.csv')
    %
    %     % Saving a 5x5 dimension array to NetCDF
    %     saveData(data, 'example.nc', var_name='out', ...
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
        nc_settings.attributes struct = struct()
        nc_settings.compression {mustBeInteger} = 6
        nc_settings.group string = ""
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
        save(filename, 'data', '-v7.3');
    elseif strcmpi(fmt, 'csv')
        writematrix(data, filename);
    elseif strcmpi(fmt, 'nc')
        c_level = nc_settings.compression;

        if ~isstruct(data)
            try
                dim_spec = nc_settings.dim_spec;
            catch err
                disp("Dimension specification not provided");
                rethrow(err)
            end
            nc_varname = nc_settings.var_name;
            
            nccreate(filename, nc_varname, 'Dimensions', dim_spec, ...
                     'DeflateLevel', c_level);
            ncwrite(filename, nc_varname, data);
        else
            f_names = string(fieldnames(data));
            n_vars = length(f_names);
            group_name = string(nc_settings.group);
            for i = 1:n_vars
                tmp_fn = string(f_names{i});  % fieldname
                t_data = data.(tmp_fn);

                if strlength(group_name) > 0
                    if ~startsWith(group_name, '/')
                        grp_fn = strcat('/', group_name, '/', tmp_fn);
                        dim_name = tmp_fn;
                    else
                        grp_fn = strcat(group_name, '__', tmp_fn);
                        dim_name = split(group_name, "/");
                        dim_name = dim_name(end);
                    end
                else
                    grp_fn = tmp_fn;
                    dim_name = tmp_fn;
                end

                dtype = class(t_data);
                switch dtype
                    case {'double', 'single'}
                        [x, y, z, v, w] = size(t_data);

                        nccreate(filename, grp_fn, 'Dimensions', ...
                            {strcat(dim_name, "_x"), x, strcat(dim_name, "_y"), y, ...
                             strcat(dim_name, "_z"), z, strcat(dim_name, "_v"), v, ...
                             strcat(dim_name, "_w"), w}, 'DeflateLevel', c_level, 'Format', 'netcdf4');
                        ncwrite(filename, grp_fn, t_data);
                    case {'char', 'string'}
                        vlen = length(t_data);
                        nccreate(filename, grp_fn,...
                            'Datatype', dtype,...
                            'Dimensions', {strcat(dim_name, "_x"), vlen},...
                            'format', ncfiletype);
                        ncwrite(filename, grp_fn, t_data);
                    case 'struct'
                        new_settings = nc_settings;
                        new_settings.group = grp_fn;
                        
                        saveData(t_data, filename, group=grp_fn);
                end
            end
        end
        
        attributes = nc_settings.attributes;
        if ~isempty(attributes)
            fns = string(fieldnames(attributes));
            for f = 1:length(fns)
                fn = fns(f);
                ncwriteatt(filename, '/', fn, attributes.(fn))
            end
        end
    else
        error(file_msg)
    end
end
