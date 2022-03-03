%% Test total cover
ai = ADRIA();
n_reps = 3;

ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')
ai.loadDHWData('../Inputs/Moore/DHWs/dhwRCP45.mat', n_reps);

X = ai.sample_defaults;
X.Guided = 2;

Y = ai.run(X, sampled_values=true, nreps=n_reps);
Y = Y.Y;  % get raw results, ignoring seed/shade logs

[~, ~, coral_params] = ai.splitParameterTable(X);

met = collectMetrics(Y, coral_params, {@coralTaxaCover});

assert(all(met.coralTaxaCover.total_cover < 1.0, 'all'), 'Non-relative cover found!');

%% Test RCI (not all 0.1)

rng(101)  % set random seed for reproducibility

N = 2;       % Number of scenarios
n_reps = 5;  % Number of replicate RCP scenarios

ai = ADRIA();

% Parameter prep
% Collect details of available parameters
combined_opts = ai.parameterDetails();
sim_constants = ai.constants;

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
sample_table = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound(p);
    b = combined_opts.upper_bound(p);
    
    selection = (b - a).*rand(N, 1) + a;
    
    sample_table.(combined_opts.name(p)) = selection;
end

sample_table.Guided(:) = 2;

sample_table.Shadeyrs(:) = 0;
sample_table.Natad(:) = 0;

sample_table.coral_cover_high(:) = 0;
sample_table.coral_cover_low(:) = 1;
sample_table.seed_connectivity(:) = 1;
sample_table.shade_connectivity(:) = 0;
sample_table.wave_stress(:) = 0;
sample_table.heat_stress(:) = 1;
sample_table.seed_priority(:) = 0;
sample_table.shade_priority(:) = 0;
sample_table.deployed_coral_risk_tol(:) = 0;
sample_table.depth_min(:) = 5;
sample_table.depth_offset(:) = 5;

ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);
ai.loadDHWData('../Inputs/Moore/DHWs/dhwRCP45.mat', n_reps);

res = ai.run(sample_table, sampled_values=true, nreps=n_reps, collect_logs=["site_rankings"]);
Y = res.Y;

[~, ~, coral_params] = ai.splitParameterTable(sample_table);

E = coralEvenness(Y);
SV = shelterVolume(Y, coral_params);
TC_a = coralTaxaCover(Y);
TC = TC_a.total_cover;
juv = TC_a.juveniles;

% ReefConditionIndex
RCI_test = ReefConditionIndex(TC, E, SV, juv);

assert(~all(all(all(all(RCI_test == 0.1)))), "All results were 0.1!")


%% Test single scenario RCI result
ai = ADRIA();
ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')

sample_table = ai.sample_defaults;
sample_table.Guided = 2;
n_reps = 1;
res = ai.run(sample_table, sampled_values=true, nreps=n_reps);
Y = res.Y;  % get raw results, ignoring seed/shade logs

[~, ~, coral_params] = ai.splitParameterTable(sample_table);

E = coralEvenness(Y);
SV = shelterVolume(Y, coral_params);
TC_a = coralTaxaCover(Y);
TC = TC_a.total_cover;
juv = TC_a.juveniles;

% ReefConditionIndex
RCI_test = ReefConditionIndex(TC, E, SV, juv);

