classdef ADRIA < handle
    properties
        interventions table
        criterias table
        corals table
        constants struct

        coral_spec table
    end

    properties (Access = private)
        TP_data  % site connectivity data
        site_ranks  % site rank
        strongpred  % strongest predecessor
    end

    properties (Dependent)
        raw_defaults
        raw_bounds

        sample_defaults
        sample_bounds
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
            fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(obj.constants.RCP), ".nc");
            wave_scens = ncread(fn, "wave");
            dhw_scens = ncread(fn, "DHW");

            % Select random subset of RCP conditions WITHOUT replacement
            n_rep_scens = length(wave_scens);
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

        function obj = loadConnectivity(obj, filename, conargs)
            % Load site connectivity data from a given file.
            arguments
               obj
               filename string
               conargs.cutoff {mustBeFloat} = NaN
            end

            if isnan(conargs.cutoff)
               cutoff = obj.constants.con_cutoff;
            else
               cutoff = conargs.cutoff;
            end

            [tp, sr, sp] = ...
               siteConnectivity(filename, cutoff);

            obj.TP_data = tp;
            obj.site_ranks = sr;
            obj.strongpred = sp;
        end

        function Y = run(obj, X, runargs)
            arguments
               obj
               X table
               runargs.sampled_values logical
               runargs.nreps {mustBeInteger}
            end
            
            nreps = runargs.nreps;

            [w_scens, d_scens] = obj.setup_waveDHWs(nreps);

            if runargs.sampled_values
                X = obj.convertSamples(X);
            end

            [interv, crit, coral] = obj.splitParameterTable(X);

            Y = runCoralADRIA(interv, crit, coral, obj.constants, ...
                     obj.TP_data, obj.site_ranks, obj.strongpred, nreps, ...
                     w_scens, d_scens);
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
            end
            
            nreps = runargs.nreps;

            [w_scens, d_scens] = obj.setup_waveDHWs(nreps);
            [~, n_sites, ~] = size(w_scens);

            if runargs.sampled_values
                X = obj.convertSamples(X);
            end

            % Quick fix - save as mat file as apparently saving structs in 
            % an open format is too hard for matlab :(
            sim_inputs = struct();
            sim_inputs.parameters = table2array(X);
            sim_inputs.constants = obj.constants;
            sim_inputs.n_reps = nreps;
            sim_inputs.n_timesteps = obj.constants.tf;
            sim_inputs.n_sites = n_sites;
            sim_inputs.n_species = length(obj.coral_spec.coral_id);

            fprefix = runargs.file_prefix;
            tmp_fn = strcat(fprefix, '_[[', num2str(1), '-', num2str(height(X)), ']]_inputs.mat');
            save(tmp_fn, 'sim_inputs')

            % Run ADRIA
            [interv, crit, coral] = obj.splitParameterTable(X);

            runCoralToDisk(interv, crit, coral, obj.constants, ...
                     obj.TP_data, obj.site_ranks, obj.strongpred, nreps, ...
                     w_scens, d_scens, fprefix, runargs.batch_size);
        end
        
        function Y = gatherResults(obj, file_loc, metrics)
            arguments
                obj
                file_loc string
                metrics cell = {}
            end
            % Gather results from a given file.
            seps = split(file_loc, "_[[");
            prefix = seps(1);
            
            input_file = dir(fullfile(strcat(prefix, "*_inputs.mat")));
            samples = load(fullfile(input_file.folder, input_file.name));
            params = samples.sim_inputs.parameters;
            [~, ~, coral] = obj.splitParameterTable(params);

            Y = gatherResults(file_loc, coral, metrics);
        end
    end
end
