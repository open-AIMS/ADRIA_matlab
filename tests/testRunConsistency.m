
%% Test result consistency across random parameters

% Test to check that ADRIA set up run using the "scatter-gather" pattern
% saves data externally in the expected format and that the data can be
% read back in without issue.
%
% This test is based on `examples/run_ADRIA_example.m`.
rng(101)

% Number of scenarios
N = 6;
num_reps = 50;  % Number of replicate RCP scenarios

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

% Avoid GA approach
p_sel.Guided(:) = randi([0 3], N, 1);

% Load site specific connectivity data
ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')

% Scenario runs
% define final collation function
mean_TC = @(x,p) mean(coralTaxaCover(x, p).total_cover, 4);

% Run scenarios, keeping results in memory
Y_true = ai.run(p_sel, sampled_values=true, nreps=num_reps);

[~, ~, coral_params] = ai.splitParameterTable(p_sel);
Yt_TC = collectMetrics(Y_true.Y, coral_params, {mean_TC});
Ytt = Yt_TC.mean_coralTaxaCover_x_p_total_cover_4;
Ytt = squeeze(mean(Ytt(end, :, :, :), 4));

% Run scenarios, keeping results in memory
Y_true = ai.run(p_sel, sampled_values=true, nreps=num_reps);

[~, ~, coral_params] = ai.splitParameterTable(p_sel);
Yt_TC = collectMetrics(Y_true.Y, coral_params, {mean_TC});
Ytt2 = Yt_TC.mean_coralTaxaCover_x_p_total_cover_4;
Ytt2 = squeeze(mean(Ytt2(end, :, :, :), 4));

assert(isequal(Ytt, Ytt2), "Results are not equal!")

%% Test consistency across specific MCDA algorithms

% Test to ensure results remain consistent when running simulations with
% identical parameter values with `ai.run()`.
%
% This test is based on `examples/run_ADRIA_example.m`.
rng(101)

% Number of scenarios
N = 8;
num_reps = 50;  % Number of replicate RCP scenarios

ai = ADRIA();
rd = ai.raw_defaults;

combined_opts = ai.parameterDetails();

p_sel = repmat(ai.raw_defaults, 8, 1);

% Avoid GA approach
% p_sel.Guided(:) = randi([0 3], N, 1);
p_sel.Guided(:) = [0; 1; 2; 3; 0; 1; 2; 3];

% Load site specific connectivity data
ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')

% Scenario runs
% define final collation function
mean_TC = @(x,p) mean(coralTaxaCover(x, p).total_cover, 4);

% Run scenarios, keeping results in memory
Y_true = ai.run(p_sel, sampled_values=true, nreps=num_reps);

[~, ~, coral_params] = ai.splitParameterTable(p_sel);
Yt_TC = collectMetrics(Y_true.Y, coral_params, {mean_TC});
Ytt = Yt_TC.mean_coralTaxaCover_x_p_total_cover_4;
Ytt = squeeze(mean(Ytt(end, :, :, :), 4));

% Run scenarios, keeping results in memory
Y_true = ai.run(p_sel, sampled_values=true, nreps=num_reps);

[~, ~, coral_params] = ai.splitParameterTable(p_sel);
Yt_TC = collectMetrics(Y_true.Y, coral_params, {mean_TC});
Ytt2 = Yt_TC.mean_coralTaxaCover_x_p_total_cover_4;
Ytt2 = squeeze(mean(Ytt2(end, :, :, :), 4));

assert(isequal(Ytt, Ytt2), "Results are not equal!")
