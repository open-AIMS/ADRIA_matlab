%% Example script illustrating running and collecting summary results

rng(101)


%% Generate monte carlo samples

% Number of scenarios
N = 8;
n_reps = 10;  % Number of replicate RCP scenarios

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

% Set MCDA algorithm choice to `2` as we only want to use TOPSIS 
% for this example
sample_table.Guided(:) = 2;

%% Load site specific data
ai.loadConnectivity('./Inputs/Moore/connectivity/2015');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

%% Scenario runs

% Only collect specific metric results
% The last entry is an example of how one might create a custom aggregator
desired_metrics = {@(x, p) coralTaxaCover(x, p).total_cover, ...
                   @coralEvenness, ...
                   @coralSpeciesCover, ...
                   @shelterVolume, ...
                   };

tic
ai.runToDisk(sample_table, sampled_values=true, nreps=n_reps, ...
    file_prefix='./Outputs/example_multirun', batch_size=4, ...
    collect_logs=["site_rankings"], metrics=desired_metrics, summarize=true);

tmp = toc;
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))

% Y = ai.gatherResults('./Outputs/example_multirun', desired_metrics);
Y = ai.gatherSummary('./Outputs/example_multirun');

% Plot summary trajectories
plotTrajectory(Y.coralTaxaCover_x_p_total_cover, title="Total Coral Cover");
plotTrajectory(Y.coralEvenness, title="Evenness");
plotTrajectory(Y.coralSpeciesCover, title="Species Cover");
plotTrajectory(Y.shelterVolume, title="Shelter Volume");
