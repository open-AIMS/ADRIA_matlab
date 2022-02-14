%% Ensure metric summaries have correct dimensions

% Script to extract metrics from simulations save to disk for Feb 28
% deliverable

rng(101)

% Set up temporary directory for test
right_now = datetime(now, 'ConvertFrom', 'datenum');
right_now = replace(string(right_now), ' ', '_');
right_now = replace(right_now, ':', '');

parent_dir = 'tmp_test';
tmp_dir = strcat(parent_dir, '/', right_now, '/');
mkdir(tmp_dir)

file_prefix = strcat(tmp_dir, "metric_summary_test");

% Number of scenarios
N = 4;
n_reps = 5;  % Number of replicate RCP scenarios

ai = ADRIA();

% Collect details of available parameters
combined_opts = ai.parameterDetails();
ai.constants.tf = 50;

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
sample_table = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound(p);
    b = combined_opts.upper_bound(p);
    
    selection = (b - a).*rand(N, 1) + a;
    
    sample_table.(combined_opts.name(p)) = selection;
end

% Set MCDA algorithm choice to `2` as we only want to use TOPSIS 
% for this example
sample_table.Guided(:) = 2;

ai.loadConnectivity('../Inputs/Moore/connectivity/2015');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

ai.runToDisk(sample_table, sampled_values=true, nreps=n_reps, ...
    file_prefix=file_prefix, batch_size=4, collect_logs=["site_rankings"]);

input_table = extractInputsUsed(strcat(file_prefix, "_[[1-4]]_inputs.nc"));
[~, ~, coral_params] = ai.splitParameterTable(input_table);

% Collect the desired metrics from the result files
desired_metrics = {@coralEvenness, ...
                   @shelterVolume, ...
                   @(x, p) coralTaxaCover(x, p).total_cover, ...
                   @(x, p) coralTaxaCover(x, p).juveniles, ...
                   };
Y = ai.gatherResults(file_prefix, desired_metrics);

% Get the logged site rankings as well
Y_rankings = ai.gatherResults(file_prefix, {}, "MCDA_rankings");

% Total coral cover
TC = concatMetrics(Y, "coralTaxaCover_x_p_total_cover");

% Extract juvenile corals (< 5 cm diameter)
juv = concatMetrics(Y, "coralTaxaCover_x_p_juveniles");

% Evenness
evenness = concatMetrics(Y, "coralEvenness");

% Calculate coral shelter volume per ha
SV_per_ha = concatMetrics(Y, "shelterVolume");

RCI = ReefConditionIndex(evenness, SV_per_ha, TC, juv);

% Collate summary stats
x = struct('TC', TC, 'SV_per_ha', SV_per_ha, 'evenness', evenness, ...
           'juv', juv, 'RCI', RCI);

met_summaries = summarizeMetrics(x);

fields = fieldnames(x);
stats = ["mean" "median" "min" "max" "std"];

msg = "Unexpected number of dimensions found in metric summaries! Issues were found with: ";
problem_stats = string([]);
for f_id = 1:length(fields)
    fn = fields{f_id};
    
    num_stats = length(stats);
    st = 0;
    for s = 1:num_stats
        st = st + ndims(met_summaries.(fn).(stats(s)));
    end
    
    if (st / num_stats) ~= 3
        problem_stats(f_id) = fn;
    end
end

problem_stats = rmmissing(problem_stats);

% Raise error if any fields have an unexpected number of dimensions
if ~isempty(problem_stats)
    error(strcat(msg, problem_stats));
end

try
    % clean up test files/folder
    rmdir(parent_dir, 's');
catch
    warning("Clean up of temporary result directory errored...")
end
