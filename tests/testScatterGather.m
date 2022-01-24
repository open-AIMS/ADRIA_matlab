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
N = 4;
num_reps = 3;  % Number of replicate RCP scenarios

ai = ADRIA();
rd = ai.raw_defaults;

combined_opts = ai.parameterDetails();

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
p_sel = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound(p);
    b = combined_opts.upper_bound(p);
    
    selection = (b - a).*rand(N, 1) + a;
    
    p_sel.(combined_opts.name{p}) = selection;
end

% Load site specific connectivity data
ai.loadConnectivity('Inputs/MooreTPmean.xlsx');

% Scenario runs

err = [];
try
    % Run scenarios, keeping results in memory
    Y_true = ai.run(p_sel, sampled_values=true, nreps=num_reps);

    file_prefix = strcat(tmp_dir, 'test');

    % Run scenarios saving data to files
    ai.runToDisk(p_sel, sampled_values=true, nreps=num_reps, ...
                    file_prefix=file_prefix, batch_size=2)
             
    assert(isfile(strcat(file_prefix, '_[[1-2]].nc')), "Partial result file not found!");

    % Collect all data
    collated = ai.gatherResults(file_prefix, {@coralTaxaCover});

    assert(isequal(Y_true, collated), "Results are not equal!")
    assert(all(all(collated.TC(:, :, 1, 1) ~= 0)), "Results were zeros!")

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

