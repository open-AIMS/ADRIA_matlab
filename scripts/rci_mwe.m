% Minimum working example for RCI issue (#76/#77)

rng(101)  % set random seed for reproducibility

N = 2;       % Number of scenarios
n_reps = 5;  % Number of replicate RCP scenarios

ai = ADRIA();

%% Parameter prep
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

% IPMF site selection specific options
% Disable certain aspects IPMF team are not concerned with
sample_table.Shadeyrs(:) = 0;
sample_table.Natad(:) = 0;

% JC informed values for criteria weighting
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


%% Load site specific data
ai.loadConnectivity('Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

%% Scenario runs

tic
res = ai.run(sample_table, sampled_values=true, nreps=n_reps, collect_logs=["site_rankings"]);
Y = res.Y;  % get raw results, ignoring seed/shade logs
% ai.runToDisk(sample_table, sampled_values=true, nreps=n_reps, ...
%     file_prefix='./test', batch_size=4);
tmp = toc;

[~, ~, coral_params] = ai.splitParameterTable(sample_table);

% If saving results to disk
% Y = ai.gatherResults('./test', {@coralTaxaCover});
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))


% ReefConditionIndex

RCI_test = ReefConditionIndex(Y, @coralEvenness, @shelterVolume, @coralTaxaCover, coral_params);

all(all(all(all(RCI_test == 0.1))))