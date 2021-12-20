% Test to check that ADRIA set up run using the "scatter-gather" pattern
% saves data externally in the expected format and that the data can be
% read back in without issue.
%
% This test is based on `examples/run_ADRIA_example.m`.
rng(101)

% Set up temporary directory for test
right_now = datetime(now, 'ConvertFrom', 'datenum');
right_now = replace(string(right_now), ' ', '_');
right_now = replace(right_now, ':', '');

parent_dir = 'tmp_test';
tmp_dir = strcat(parent_dir, '/', right_now, '/');
mkdir(tmp_dir)

% Number of scenarios
N = 2;
num_reps = 3;  % Number of replicate RCP scenarios

% Collect details of available parameters
inter_opts = interventionDetails();
criteria_opts = criteriaDetails();

% Create main table listing all available parameter options
combined_opts = [inter_opts; criteria_opts];

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
p_sel = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound{p};
    b = combined_opts.upper_bound{p};
    
    selection = (b - a).*rand(N, 1) + a;
    
    p_sel.(combined_opts.name{p}) = selection;
end


% Creating dummy permutations for core ADRIA parameters
% (environmental and ecological parameter values etc)
% This process will be replaced
[params, ecol_params] = ADRIAparms();
param_tbl = struct2table(params);
ecol_tbl = struct2table(ecol_params);

param_tbl = repmat(param_tbl, N, 1);
ecol_tbl = repmat(ecol_tbl, N, 1);

% Convert sampled values to ADRIA usable values
% Necessary as samplers expect real-valued parameters (e.g., floats)
% where as in practice ADRIA makes use of integer and categorical
% parameters
converted_tbl = convertScenarioSelection(p_sel, combined_opts);

% Separate parameters into components
% (to be replaced with a better way of separating these...)
interv_scens = converted_tbl(:, 1:9);  % intervention scenarios
criteria_weights = converted_tbl(:, 10:end);

% use order-ranking for example
alg_ind = 1;


% Load site specific data
[F0, xx, yy, nsites] = ADRIA_siteTable('Inputs/MooreSites.xlsx');
[TP_data, site_ranks, strongpred] = siteConnectivity('Inputs/MooreTPmean.xlsx', params.con_cutoff);

% Setup for the geographical setting including environmental input layers
% Load wave/DHW scenario data
% Generated with generateWaveDHWs.m
% TODO: Replace these with wave/DHW projection scenarios instead
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(params.RCP), ".nc");
wave_scens = ncread(fn, "wave");
dhw_scens = ncread(fn, "DHW");

% Select random subset of RCP conditions WITHOUT replacement
n_rep_scens = length(wave_scens);
rcp_scens = datasample(1:n_rep_scens, num_reps, 'Replace', false);
w_scens = wave_scens(:, :, rcp_scens);
d_scens = dhw_scens(:, :, rcp_scens);

% Scenario runs
% Currently running over unique interventions and criteria weights only for
% a limited number of RCP scenarios.
%
% In actuality, this would be done for some combination of:
% intervention * criteria * environment parameters * ecological parameter
%     * wave_scen * dhw_scen * alg_ind * N_sims
% where the unique combinations would be generated via some quasi-monte 
% carlo sequence, or through some user-informed process.

err = [];
try
    % Run scenarios, keeping results in memory
    Y_true = runADRIA(interv_scens, criteria_weights, param_tbl, ecol_tbl, ...
                      TP_data, site_ranks, strongpred, num_reps, ...
                      w_scens, d_scens, alg_ind);

    file_prefix = strcat(tmp_dir, 'test');

    % Run scenarios saving data to files
    runADRIA(interv_scens, criteria_weights, param_tbl, ecol_tbl, ...
                 TP_data, site_ranks, strongpred, num_reps, ...
                 w_scens, d_scens, alg_ind, file_prefix, N);
             
    assert(isfile(strcat(file_prefix, '_[[1-2]].nc')), "Partial result file not found!");

    % Collect all data
    collated = collectDistributedResults('test', N, num_reps, ...
                                         dir_name=tmp_dir, n_species=4);

    assert(isequal(Y_true, collated), "Results are not equal!")
    assert(all(all(collated.TC(:, :, 1, 1) ~= 0)), "Results were zeros!")
    
    
%     Ys = zeros(N, nsites, 4);  % where 4 is number of metrics
%     for i = 1:N
%         offset = 0;
%         for j = 1:nsites
%             % average across all time, all env scenarios (DHW/wave) for site j, scenario i
%             Ys(i, j, 1) = mean(collated.TC(:, j, i, :), 'all');
%             Ys(i, j, 2) = mean(mean(collated.C(:, :, j, i, :)), 'all');
%             Ys(i, j, 3) = mean(collated.E(:, j, i, :), 'all');
%             Ys(i, j, 4) = mean(collated.S(:, j, i, :), 'all');
%         end
%     end
catch err
end

try
    % clean up test files/folder
    rmdir(parent_dir, 's');
catch
    warning("Clean up of temporary result directory errored...")
end

if ~isempty(err)
    rethrow(err)
end

