classdef ADRIA < handle
    properties
        interventions table
        criterias table
        corals table
        constants struct

        coral_spec table
    end

    properties (Access = private)
        TP_data     % site connectivity data
        site_ranks  % site rank
        strongpred  % strongest predecessor
        site_data   % table of site data (dpeth, carrying capacity, etc)
        init_coral_cov_col  % column name to derive initial coral cover from
    end

    properties (Dependent)
        raw_defaults
        raw_bounds

        sample_defaults
        sample_bounds
        
        init_coral_cover
    end

    methods (Access = private)
        function prop = getParameterTable(obj)
            % Helper accessor to extract parameter detail table.
            % Determines correct column automatically based on method name.
            st = dbstack;
            namestr = st(2).name;
            stack = string(split(namestr, "."));
            prop_name = stack(end);

            details = obj.parameterDetails();

            name_vals = details(:, ["name", prop_name]);
            prop = array2table(name_vals.(prop_name)', "VariableNames", name_vals.name');
        end

        function [w_scens, d_scens] = setup_waveDHWs(obj, n_reps)
            %% setup for the geographical setting including environmental input layers
            % Load wave/DHW scenario data
            % Generated with generateWaveDHWs.m
            % TODO: Replace these with wave/DHW projection scenarios instead
            fn = strcat("Inputs/example_wave_DHWs_RCP_expanded_", num2str(obj.constants.RCP), ".nc");
            wave_scens = ncread(fn, "wave");
            dhw_scens = ncread(fn, "DHW");

            % Select random subset of RCP conditions WITHOUT replacement
            [~, ~, n_rep_scens] = size(wave_scens);
            rcp_scens = datasample(1:n_rep_scens, n_reps, 'Replace', false);
            w_scens = wave_scens(:, :, rcp_scens);
            d_scens = dhw_scens(:, :, rcp_scens);
        end
    end
    methods
        %% Getter/setters
        function defaults = get.raw_defaults(obj)
            defaults = obj.getParameterTable();
        end

        function bounds = get.raw_bounds(obj)
            % Returns table of name, lower_bound, upper_bound
            details = obj.parameterDetails();
            bounds = details(:, ["name", "raw_bounds"]);

            for n = 1:height(details)
                bnds = details.raw_bounds(n, :);
                bounds.lower_bound(n) = bnds(1);
                bounds.upper_bound(n) = bnds(2);
            end

            bounds.raw_bounds = [];  % remove column
        end

        function defaults = get.sample_defaults(obj)
            defaults = obj.getParameterTable();
        end

        function bounds = get.sample_bounds(obj)
            % Returns table of name, lower_bound, upper_bound
            details = obj.parameterDetails();
            bounds = details(:, ["name", "lower_bound", "upper_bound"]);
        end
        
        function init_cover = get.init_coral_cover(obj)
            if isempty(obj.site_data) || isempty(obj.init_coral_cov_col)
                % If empty, default base covers will be used
                init_cover = [];
                return
            end
            
            % Create initial coral cover by size class based on input data
            prop_cover_per_site = obj.site_data(:, obj.init_coral_cov_col);
            nsites = height(obj.site_data);
            
            base_coral_numbers = ...
                [0, 0, 0, 0, 0, 0; ...          % Tabular Acropora Enhanced
                 0, 0, 0, 0, 0, 0; ...          % Tabular Acropora Unenhanced
                 0, 0, 0, 0, 0, 0; ...          % Corymbose Acropora Enhanced
                 200, 100, 100, 50, 30, 10; ... % Corymbose Acropora Unenhanced
                 200, 100, 200, 30, 0, 0; ...   % small massives
                 0, 0, 0, 0, 0, 0];             % large massives
            
            % target shape is nspecies * nsites
            init_cover = zeros(numel(base_coral_numbers), nsites);
            for row = 1:nsites
                x = baseCoralNumbersFromCovers(prop_cover_per_site{row, :});
                base_coral_numbers(4:5, :) = x;
                
                tmp = base_coral_numbers';
                init_cover(:, row) = tmp(:);
            end
            
            assert(all(any(isnan(init_cover)) == 0), "NaNs found in coral cover data")
        end

        %% object methods
        function obj = ADRIA(interv, crit, coral, constants, coral_spec)
           % Base constructor for ADRIA Input object.

            if nargin >= 4
                obj.interventions = interv;
                obj.criterias = crit;
                obj.corals = coral;
                obj.constants = constants;

                if nargin == 5
                   obj.coral_spec = coral_spec;
                else
                   obj.coral_spec = coralSpec();
                end
            elseif nargin == 0
                obj.interventions = interventionDetails();
                obj.criterias = criteriaDetails();
                obj.corals = coralDetails();
                obj.constants = simConstants();
                obj.coral_spec = coralSpec();
            else
                error("Unexpected number of component parameters.")
            end
        end

        function r = parameterDetails(obj)
            % Extract a table of perturbable parameter details.
            r = [obj.interventions; obj.criterias; obj.corals];
        end

        function r = defaultVals(obj)
            % Return default values as a table.
            x = parameterDetails(obj);
            r = x(:, ["name", "raw_defaults"]);
        end

        function [it, crit, coral] = splitParameterTable(obj, param_table)
            [it_r, crit_r, coral_r] = obj.componentIndices();

            it = param_table(:, it_r);
            crit = param_table(:, crit_r);
            coral = param_table(:, coral_r);
        end

        function [it, crit, coral] = splitDefaultVals(obj)
            [it_r, crit_r, coral_r] = obj.componentIndices();

            % Table of default values separated into their components
            x = obj.defaultVals();

            it = x(it_r, :);
            crit = x(crit_r, :);
            coral = x(coral_r, :);
        end

        function tbl = convertSamples(obj, X)
            % Convert sample values back to ADRIA expected values
            tbl = convertScenarioSelection(X, obj.parameterDetails());
        end

        function [it_r, crit_r, coral_r] = componentIndices(obj)
            it_s = 1;
            it_e = height(obj.interventions);

            crit_s = it_e + 1;
            crit_e = crit_s + height(obj.criterias) - 1;

            coral_s = crit_e + 1;
            coral_e = coral_s + height(obj.corals) - 1;

            it_r = it_s:it_e;
            crit_r = crit_s:crit_e;
            coral_r = coral_s:coral_e;
        end

        function obj = loadConnectivity(obj, fileset, conargs)
            % Load site connectivity data from a given file or set of files.
            %
            % If `fileset` is a path to file, loads the file directly. 
            % If it is a path to a folder, then loads the all files found
            % within and aggregates with the function specified with
            % `agg_func`
            %
            % Example:
            %     % load single dataset
            %     ai.loadConnectivity("./example/x.csv")
            %
            %     % load and aggregate multiple datasets using their mean
            %     ai.loadConnectivity("./example", agg_func=@mean)
            arguments
               obj
               fileset string
               conargs.agg_func function_handle
               conargs.cutoff {mustBeFloat} = NaN
            end

            if isnan(conargs.cutoff)
               cutoff = obj.constants.con_cutoff;
            else
               cutoff = conargs.cutoff;
            end

            [tp, sr, sp] = siteConnectivity(fileset, cutoff);

            obj.TP_data = tp;
            obj.site_ranks = sr;
            obj.strongpred = sp;
        end
        
        function loadSiteData(obj, filename, init_coral_cov_col)
            % Load data on site carrying capacity, depth and connectivity
            % from indicated CSV file.
            
            % readtable("Inputs/Moore/site_data/MooreReefCluster_Spatial.csv")
            arguments
                obj
                filename
                % TODO: Fix hardcoded column selection! (note `k` column is hard set below too)
                init_coral_cov_col = ["Acropora2026", "Goniastrea2026"]
                % max_coral_col = "k"  % column to load max coral cover from
            end
            
            if strlength(init_coral_cov_col) > 0
                obj.init_coral_cov_col = init_coral_cov_col;
            end 
            
            sdata = readtable(filename);
            tmp_s = sdata(:, [["site_id", "area", "k", init_coral_cov_col, "sitedepth", "recom_connectivity"]]);
            
            % Set any missing coral cover data to 0
            tmp_s{any(ismissing(tmp_s{:, init_coral_cov_col}),2), init_coral_cov_col} = 0;
            
            obj.site_data = tmp_s;
            obj.site_data = sortrows(obj.site_data, "recom_connectivity");
        end

        function Y = run(obj, X, runargs)
            arguments
               obj
               X table
               runargs.sampled_values logical
               runargs.nreps {mustBeInteger}
               runargs.collect_logs string = [""]  % valid options: seed, shade, site_rankings
            end
            
            if isempty(obj.site_data)
                error("Site data not loaded! Preload with `loadSiteData()`");
            end
            
            if isempty(obj.TP_data)
                error("Connectivity data not loaded! Preload with `loadConnectivity()`");
            end
            
            nreps = runargs.nreps;

            % QUICK ADJUSTMENT FOR FEB 2022 DELIVERABLE
            % NEEDS TO BE CLEANED UP.
            % Load DHW time series for each site
            % Wave data is all zeros (ignore mortality due to wave damage
            % and cyclones).
            % [w_scens, d_scens] = obj.setup_waveDHWs(nreps);
            tf = obj.constants.tf;
            d_scens = load("dhwRCP45.mat").dhw(1:tf, :, 1:nreps);
            [~, nsites, ~] = size(d_scens);
            w_scens = zeros(tf, nsites, nreps);

            if runargs.sampled_values
                X = obj.convertSamples(X);
            end

            [interv, crit, coral] = obj.splitParameterTable(X);

            Y = runCoralADRIA(interv, crit, coral, obj.constants, ...
                     obj.TP_data, obj.site_ranks, obj.strongpred, ...
                     obj.init_coral_cover, nreps, ...
                     w_scens, d_scens, obj.site_data, runargs.collect_logs);
        end
        
        function runToDisk(obj, X, runargs)
            % Run ADRIA, storing results to file.
            arguments
               obj
               X table
               runargs.sampled_values logical
               runargs.nreps {mustBeInteger}
               runargs.file_prefix string
               runargs.batch_size {mustBeInteger} = 500
               runargs.collect_logs string = [""]  % valid options: seed, shade, site_rankings
            end
            
            nreps = runargs.nreps;
            
            % QUICK ADJUSTMENT FOR FEB 2022 DELIVERABLE
            % NEEDS TO BE CLEANED UP.
            % Load DHW time series for each site
            % Wave data is all zeros (ignore mortality due to wave damage
            % and cyclones).
            % [w_scens, d_scens] = obj.setup_waveDHWs(nreps);
            % [~, n_sites, ~] = size(w_scens);

            tf = obj.constants.tf;
            d_scens = load("dhwRCP45.mat").dhw(1:tf, :, 1:nreps);
            [~, n_sites, ~] = size(d_scens);
            w_scens = zeros(tf, n_sites, nreps);

            if runargs.sampled_values
                X = obj.convertSamples(X);
            end

            fprefix = runargs.file_prefix;
            tmp_fn = strcat(fprefix, '_[[', num2str(1), '-', num2str(height(X)), ']]_inputs.nc');
            
            if exist(tmp_fn, "file")
                error("Input file already exists. Aborting runs to avoid overwriting.")
            end
            
            tmp = struct('input_parameters', table2array(X));
            saveData(tmp, tmp_fn, compression=4);
            nccreate(tmp_fn, "constants");
            nccreate(tmp_fn, "metadata");
            
            all_fields = string(fieldnames(obj.constants));
            for i = 1:length(all_fields)
                af = all_fields(i);
                ncwriteatt(tmp_fn, "constants", af, obj.constants.(af));
            end

            ncwriteatt(tmp_fn, "metadata", "n_reps", nreps);
            ncwriteatt(tmp_fn, "metadata", "n_timesteps", obj.constants.tf);
            ncwriteatt(tmp_fn, "metadata", "n_sites", n_sites);
            ncwriteatt(tmp_fn, "metadata", "n_species", length(obj.coral_spec.coral_id));

            % Run ADRIA
            [interv, crit, coral] = obj.splitParameterTable(X);

            runCoralToDisk(interv, crit, coral, obj.constants, ...
                     obj.TP_data, obj.site_ranks, obj.strongpred, ...
                     obj.init_coral_cover, nreps, w_scens, d_scens, ...
                     obj.site_data, runargs.collect_logs, ...
                     fprefix, runargs.batch_size);
        end
        
        function Y = gatherResults(obj, file_loc, metrics, target_var)
            arguments
                obj
                file_loc string
                metrics cell = {}  % collect raw results with no transformations if nothing specified
                target_var string = "all"  % apply metrics to raw results if nothing specified
            end
            % Gather results from a given file.
            seps = split(file_loc, "_[[");
            prefix = seps(1);
            
            input_file = dir(fullfile(strcat(prefix, "*_inputs.nc")));
            fn = fullfile(input_file.folder, input_file.name);
            % samples = load(fullfile(input_file.folder, input_file.name));
            samples = ncread(fn, "input_parameters");
            
            % Reconstruct input table
            param_details = obj.parameterDetails();
            var_types = replace(param_details.ptype', "float", "double");
            var_types = replace(var_types, "integer", "int64");
            var_names = param_details.name';
            input_table = table('Size', size(samples), ...
                                'VariableTypes', var_types, ...
                                'VariableNames', var_names);
            input_table{:, :} = samples;
            clear samples;  % remove from memory

            [~, ~, coral] = obj.splitParameterTable(input_table);

            Y = gatherResults(file_loc, coral, metrics, target_var);
        end
        
        function updated = setParameterValues(obj, values, opts)
            % Update a parameter table with new values.
            % Number of new values has to be >= number of rows in target
            % table.
            %
            % If the target table has less rows than updated value matrix
            % then the target table will be replaced with repeating
            % the first row N times to match size of new values.
            %
            % Columns can be ignored by providing a string (or string
            % array) of column names to ignore.
            %
            % NOTE: This method assumes column orders match after ignored
            %       columns are removed
            arguments
                obj
                values  % matrix of updated parameter values
                opts.p_table table = table() % table to update (uses raw defaults if not provided)
                opts.ignore string = "" % string, or string array, of columns to ignore
                opts.partial logical = false  % partial match on list of columns to ignore (e.g., "natad" will match "coral_1_natad")
            end
            
            if istable(values)
                % Convert to matrix
                values = values{:, :};
            end

            if isempty(opts.p_table)
                p_table = obj.raw_defaults;
            else
                p_table = opts.p_table;
            end

            % Match lengths
            n = height(values);
            if n ~= height(p_table)
                p_table = repelem(p_table(1, :), n, 1);
            end

            % Fill target table with updated values
            if strlength(opts.ignore) > 0
                p_names = p_table.Properties.VariableNames;
                
                if ~opts.partial
                    [~, idx] = ismember(p_names, opts.ignore);
                else
                    idx = contains(p_names, opts.ignore);
                end

                p_table{:, ~idx} = values;
                
            else
                p_table{:, :} = values;
            end

            updated = p_table;
        end
    end
end
