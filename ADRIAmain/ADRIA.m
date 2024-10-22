classdef ADRIA < handle
    properties
        interventions table
        criterias table
        corals table
        constants struct
        coral_spec table
    end

    properties (SetAccess = private, GetAccess=public)
        TP_data     % site connectivity data
        site_ranks  % site rank
        strongpred  % strongest predecessor
        site_data   % table of site data (dpeth, carrying capacity, etc)
        init_coral_cov_col  % column name to derive initial coral cover from
        init_coral_cover  % initial coral cover dataset
        connectivity_site_ids  % Site IDs as specified by the connectivity dataset (indicates order of `TP_data`)
        removed_sites  % indices of sites that were removed. Used to align site_data, DHW, connectivity, etc.
        dhw_scens  % DHW scenarios
        wave_scens % wave scenarios
    end

    properties (Dependent)
        raw_defaults
        raw_bounds

        sample_defaults
        sample_bounds
        
        % init_coral_cover
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

        %% object methods
        function obj = ADRIA(init_args)
            % Base constructor for ADRIA Input object.
            arguments
                init_args.connectivity = ""  % path to connectivity data
                init_args.conn_cutoff {mustBeFloat} = NaN  % relies on value defined in sim_constants if not provided
                init_args.conn_agg_func = @mean  % aggregation method if indicated location is a folder of files
                init_args.site_data = ""
                init_args.coral_k_col string = "k"  % max coral cover column
                init_args.dhw = ""  % path to DHW data
                init_args.wave = ""  % path to wave data
                init_args.n_reps = 20  % num. replicates to use
            end
            
            obj.interventions = interventionDetails();
            obj.criterias = criteriaDetails();
            obj.corals = coralDetails();
            obj.constants = simConstants();
            obj.coral_spec = coralSpec();

            if init_args.site_data ~= ""
                obj.loadSiteData(init_args.site_data, init_args.coral_k_col);
            end
            
            if init_args.connectivity ~= ""
                obj.loadConnectivity(init_args.connectivity, ...
                                     cutoff=init_args.conn_cutoff, ...
                                     agg_func=init_args.conn_agg_func);
            end

            if init_args.dhw ~= ""
                obj.loadDHWData(init_args.dhw, init_args.n_reps);
            end
            
            if init_args.wave ~= ""
                obj.loadWaveData(init_args.wave, init_args.n_reps);
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
        
        function pd = idConstants(obj)
            % Get index of constant parameters from parameter details
            % table.
            param_details = obj.parameterDetails();
            xmin = param_details.lower_bound;
            xmax = param_details.upper_bound;
            pd = xmin == xmax;
        end

        function tbl = convertSamples(obj, X)
            % Convert sample values back to ADRIA expected values
            tbl = convertScenarioSelection(X, obj.parameterDetails());
        end

        function [it_r, crit_r, coral_r] = componentIndices(obj)
            % Helper method to identify start/end locations of model
            % component parameters for interventions, criteria, and corals.
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
        
        function loadSiteData(obj, filename, k_col)
            % Load data on site carrying capacity, depth and corresponding
            % connectivity ids from given CSV file.

            arguments
                obj
                filename
                k_col = "k"  % column to load max coral cover from
            end
            
            sdata = readtable(filename);
            tmp_s = sdata(:, ["reef_siteid", "area", k_col, "sitedepth", "recom_connectivity", "lat", "long"]);

            % Sort site data by reef id
            obj.site_data = sortrows(tmp_s, "reef_siteid");
        end

        function obj = loadConnectivity(obj, fileset, conargs)
            % Load site connectivity data from a given file or set of files.
            %
            % If `fileset` is a path to file, loads the file directly. 
            % If it is a path to a folder, then loads the all files found
            % within and aggregates with the function specified with
            % `agg_func`
            %
            % Note: `site_data` must be loaded beforehand.
            %
            % Example:
            %     % load single dataset
            %     ai.loadConnectivity("./example/x.csv")
            %
            %     % load and aggregate multiple datasets using their mean
            %     ai.loadConnectivity("./example", agg_func=@mean)
            %
            %     % load with a different cutoff value
            %     ai.loadConnectivity("./example/x.csv", cutoff=0.05)
            arguments
               obj
               fileset string
               conargs.agg_func function_handle = @mean
               conargs.cutoff {mustBeFloat} = NaN
               conargs.swap = false
            end
            
            if isempty(obj.site_data)
                error("Load site data before loading connectivity. This is to ensure datasets all align.")
            end

            if isnan(conargs.cutoff)
               cutoff = obj.constants.con_cutoff;
            else
               cutoff = conargs.cutoff;
            end

            [tp, sr, sp, site_ids, removed] = siteConnectivity(fileset, cutoff, conargs.agg_func, ...
                                                      conargs.swap, string(obj.site_data{:, "recom_connectivity"}));

            obj.TP_data = tp;
            obj.site_ranks = sr;
            obj.strongpred = sp;
            obj.connectivity_site_ids = site_ids;
            obj.removed_sites = removed;

            if ~isempty(removed)
                % Remove indicated site from site table
                obj.site_data = obj.site_data(setdiff(1:end, obj.removed_sites), :);
            end
        end

        function loadCoralCovers(obj, cc_fn)
            % Load initial coral cover data
            if endsWith(cc_fn, ".mat")
                obj.init_coral_cover = load(cc_fn).covers;
            elseif endsWith(cc_fn, ".nc")
                obj.init_coral_cover = ncread(cc_fn, "covers");
            end
            
            if ~isempty(obj.removed_sites)
                obj.init_coral_cover = obj.init_coral_cover(:, setdiff(1:end, obj.removed_sites));
            end
        end

        function loadDHWData(obj, dhw_fn, nreps)
            % Load DHW data
            if endsWith(dhw_fn, ".mat")
                d_scens = load(dhw_fn).dhw(1:obj.constants.tf, :, 1:nreps);
            elseif endsWith(dhw_fn, ".nc")
                d_scens = ncread(dhw_fn, "DHW");
                d_scens = d_scens(1:obj.constants.tf, :, 1:nreps);
            end
            
            if ~isempty(obj.removed_sites)
                d_scens = d_scens(:, setdiff(1:end, obj.removed_sites), :);
            end

            obj.dhw_scens = d_scens;
        end

        function loadWaveData(obj, wave_fn, nreps)
            % Load wave data
            %
            if endsWith(wave_fn, ".mat")
                w_scens = load(wave_fn).wave(1:obj.constants.tf, :, 1:nreps);
            elseif endsWith(wave_fn, ".nc")
                w_scens = ncread(wave_fn, "wave");
                w_scens = w_scens(1:obj.constants.tf, :, 1:nreps);
            end
            
            if ~isempty(obj.removed_sites)
                w_scens = w_scens(:, setdiff(1:end, obj.removed_sites), :);
            end

            obj.wave_scens = w_scens;
        end


        function store_rankings = siteSelection(obj, criteria, tstep, nreps,...
                                                alg, sslog)
            arguments
                obj
                criteria table
                tstep {mustBeInteger}
                nreps {mustBeInteger}
                alg {mustBeInteger}
                sslog struct
            end
            
            % Check site data and connectivity loaded
            if isempty(obj.site_data)
                error("Site data not loaded! Preload with `loadSiteData()`");
            end
            
            if isempty(obj.TP_data)
                error("Connectivity data not loaded! Preload with `loadConnectivity()`");
            end

            % Site Data
            site_d = obj.site_data;
            sr = obj.site_ranks;
            strong_pred = obj.strongpred;
            area = site_d.area;
            % Weights for connectivity , waves (ww), high cover (whc) and low
            wtwaves = criteria.wave_stress; % weight of wave damage in MCDA
            wtheat = criteria.heat_stress; % weight of heat damage in MCDA
            wtconshade = criteria.shade_connectivity; % weight of connectivity for shading in MCDA
            wtconseed = criteria.seed_connectivity; % weight of connectivity for seeding in MCDA
            wthicover = criteria.coral_cover_high; % weight of high coral cover in MCDA (high cover gives preference for seeding corals but high for SRM)
            wtlocover = criteria.coral_cover_low; % weight of low coral cover in MCDA (low cover gives preference for seeding corals but high for SRM)
            wtpredecseed = criteria.seed_priority; % weight for the importance of seeding sites that are predecessors of priority reefs
            wtpredecshade = criteria.shade_priority; % weight for the importance of shading sites that are predecessors of priority reefs
            risktol = criteria.deployed_coral_risk_tol; % risk tolerance
            depth_min = criteria.depth_min;
            depth_offset = criteria.depth_offset;
    
            % Filter out sites outside of desired depth range
            max_depth = depth_min + depth_offset;
            depth_criteria = (site_d.sitedepth > -max_depth) & (site_d.sitedepth < -depth_min);
            depth_priority = site_d{depth_criteria, "recom_connectivity"};
    
            max_cover = site_d.k/100.0; % Max coral cover at each site

            nsiteint = obj.constants.nsiteint;
            nsites = length(max_cover);
            w_scens = obj.wave_scens;
            dhw_scen = obj.dhw_scens;

            sumcover = sum(site_d{:,obj.init_coral_cov_col},2); 
            sumcover = sumcover/100.0;

            store_rankings = zeros(nreps,length(depth_priority),3);

            for l = 1:nreps
                % site_id, seeding rank, shading rank
                rankings = [depth_priority, zeros(length(depth_priority), 1), zeros(length(depth_priority), 1)];
                prefseedsites = zeros(1,nsiteint);
                prefshadesites = zeros(1,nsiteint);
                dhw_step = dhw_scen(tstep,:,l);
                heatstressprob = dhw_step';

                w_step = w_scens(tstep,:,l);
                damprob = w_step';
                dMCDA_vars = struct('site_ids', depth_priority, 'nsiteint', nsiteint, 'prioritysites', obj.constants.prioritysites, ...
                    'strongpred', strong_pred, 'centr', sr.C1, 'damprob', damprob, 'heatstressprob', heatstressprob, ...
                    'sumcover', sumcover,'maxcover', max_cover, 'area',area,'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
                    'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', ...
                    wtpredecseed, 'wtpredecshade', wtpredecshade);
                [~, ~, ~,~, rankings] = ADRIA_DMCDA(dMCDA_vars,alg,sslog,prefseedsites,prefshadesites,rankings);
                store_rankings(l,:,:) = rankings;
            end
        end

        function Y = run(obj, X, runargs)
            arguments
               obj
               X table
               runargs.sampled_values logical
               runargs.nreps {mustBeInteger}
               runargs.collect_logs string = [""]  % valid options: seed, shade, site_rankings
               runargs.odefunc function_handle = @ode23 % solver for solving ecological odes
               runargs.odeopts struct = struct('reltol',1e-4,'abstol',1e-7) % tolerance values for ode
            end

            if isempty(obj.site_data)
                error("Site data not loaded! Preload with `ai.loadSiteData()`");
            end
            
            if isempty(obj.TP_data)
                error("Connectivity data not loaded! Preload with `ai.loadConnectivity()`");
            end
            
            if isempty(obj.dhw_scens)
                error("DHW data not loaded! Preload with `ai.loadDHWData()`");
            end
            
            nreps = runargs.nreps;
            nsites = height(obj.site_data);
            tf = obj.constants.tf;
            
            d_scens = obj.dhw_scens;
            if isempty(d_scens)
                warning("No DHW scenarios loaded! Running simulations with heat stress deactivated.")
                d_scens = zeros(tf, nspecies, nsites);
            end
            
            w_scens = obj.wave_scens;    
            if isempty(w_scens)
                warning("No wave scenarios loaded! Running simulations with wave stress deactivated.")
                w_scens = zeros(tf, nsites, nreps);
            end

            if runargs.sampled_values
                X = obj.convertSamples(X);
            end

            [interv, crit, coral] = obj.splitParameterTable(X);

            Y = runCoralADRIA(interv, crit, coral, obj.constants, ...
                     obj.TP_data, obj.site_ranks, obj.strongpred, ...
                     obj.init_coral_cover, nreps, ...
                     w_scens, d_scens, obj.site_data, runargs.collect_logs, ...
                     runargs.odefunc,runargs.odeopts);
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
               runargs.metrics cell = {}  % metrics to collect
               runargs.summarize logical = false  % to summarize metric results or not
               runargs.collect_logs string = [""]  % valid options: seed, shade, site_rankings
               runargs.odefunc function_handle = @ode23 % solver for solving ecological odes
               runargs.odeopts struct = struct('reltol',1e-4,'abstol',1e-7) % tolerance values for ode
            end

            n_reps = runargs.nreps;
            n_sites = height(obj.site_data);
            tf = obj.constants.tf;
            
            d_scens = obj.dhw_scens;
            if isempty(d_scens)
                warning("No DHW scenarios loaded! Running simulations with heat stress deactivated.")
                d_scens = zeros(tf, nspecies, n_sites);
            end
            
            w_scens = obj.wave_scens;    
            if isempty(w_scens)
                warning("No wave scenarios loaded! Running simulations with wave stress deactivated.")
                w_scens = zeros(tf, n_sites, n_reps);
            end

            if runargs.sampled_values
                X = obj.convertSamples(X);
            end

            fprefix = runargs.file_prefix;
            tmp_fn = strcat(fprefix, '_[[', num2str(1), '-', num2str(height(X)), ']]_inputs.nc');
            
            if exist(tmp_fn, "file")
                warning("Input file already exists. Aborting runs to avoid overwriting.")
                return
            end
            
            tmp = struct('input_parameters', table2array(X));
            saveData(tmp, tmp_fn, compression=4);
            nccreate(tmp_fn, "constants");
            nccreate(tmp_fn, "metadata");
            
            all_fields = string(fieldnames(obj.constants));
            for i = 1:length(all_fields)
                af = all_fields(i);
                
                try
                    ncwriteatt(tmp_fn, "constants", af, obj.constants.(af));
                catch err
                    if ~(strcmp(err.identifier, 'MATLAB:invalidType'))
                        rethrow(err);
                    end
                    
                    % Integer values sometimes gets interpreted as logical
                    % which the netCDF writer cannot handle
                    if contains(err.message, "its type was logical")
                        ncwriteatt(tmp_fn, "constants", af, int8(obj.constants.(af)));
                    else
                        rethrow(err);
                    end
                end
            end

            ncwriteatt(tmp_fn, "metadata", "n_reps", n_reps);
            ncwriteatt(tmp_fn, "metadata", "n_timesteps", obj.constants.tf);
            ncwriteatt(tmp_fn, "metadata", "n_sites", n_sites);
            ncwriteatt(tmp_fn, "metadata", "n_species", length(obj.coral_spec.coral_id));

            % Run ADRIA
            [interv, crit, coral] = obj.splitParameterTable(X);

            runCoralToDisk(interv, crit, coral, obj.constants, ...
                     obj.TP_data, obj.site_ranks, obj.strongpred, ...
                     obj.init_coral_cover, n_reps, w_scens, d_scens, ...
                     obj.site_data, runargs.collect_logs, ...
                     fprefix, runargs.batch_size, runargs.metrics, runargs.summarize, ...
                     runargs.odefunc,runargs.odeopts);
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

        function Y = gatherSummary(obj, file_loc, opts)
            % Gather summarized result sets from batch runs.
            arguments
                obj
                file_loc string
                opts.target_var string = "all"
                opts.scenarios = [];
                opts.summarize logical = false
            end
            
            if isempty(opts.scenarios)
                warning("Targeted scenario option was empty, so collecting all scenarios run...")
            end

            Y = gatherSummary(file_loc, target_var=opts.target_var, scenarios=opts.scenarios, summarize=opts.summarize);
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
                values  % matrix/table of updated parameter values
                opts.p_table table = table() % Optional: table to update (uses raw defaults if not provided)
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
