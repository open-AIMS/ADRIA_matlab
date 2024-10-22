% Example script illustrating running multiple ADRIA scenarios
% with sampled values

rng(101)  % set random seed for consistency

%% Generate monte carlo samples

% Number of scenarios
N = 8;
n_reps = 3;  % Number of replicate RCP scenarios

ai = ADRIA();

%% Parameter prep
% Collect details of available parameters
combined_opts = ai.parameterDetails();
sim_constants = ai.constants;

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
% NOTE: This is for example purposes only. In practice, a more
%       appropriate sampling method should be adopted.
sample_table = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound(p);
    b = combined_opts.upper_bound(p);
    
    selection = (b - a).*rand(N, 1) + a;
    
    sample_table.(combined_opts.name(p)) = selection;
end

% Set MCDA algorithm choice to `2` as we only want to use TOPSIS 
% for this example
% sample_table.Guided(:) = 2;
sample_table.Guided(:) = randi([1, 3], N, 1);

%% Load site specific data
ai.loadConnectivity('Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);
ai.loadDHWData('./Inputs/Moore/DHWs/dhwRCP45.mat', n_reps);

%% Scenario runs

tic
res = ai.run(sample_table, sampled_values=true, nreps=n_reps, collect_logs=["site_rankings"]);
Y = res.Y;  % get raw results, ignoring seed/shade logs
% ai.runToDisk(sample_table, sampled_values=true, nreps=n_reps, ...
%     file_prefix='./test', batch_size=4);
tmp = toc;

% If saving results to disk
% Y = ai.gatherResults('./test', {@coralTaxaCover});
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))


%% Collect metrics
[~, ~, coral_params] = ai.splitParameterTable(sample_table);
metric_results = collectMetrics(Y, coral_params, ...
                    {@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

% Coral cover per species
covs = metric_results.coralSpeciesCover;

% Evenness
E = metric_results.coralEvenness;

% Extract juvenile corals (< 5 cm diameter)
BC = metric_results.coralTaxaCover.juveniles;

% Calculate coral shelter volume per ha
SV_per_ha = metric_results.shelterVolume;

%% Site rankings
figure;
barh(siteRanking(res.site_rankings, "shade"));

%% Plot coral covers over time and sites
figure; 
LO = tiledlayout(2,3, 'TileSpacing','Compact');

% Tile 1
nexttile
plot(mean(squeeze(covs(:,1,:,:,:)), [3,4]));
title('Enhanced Tab Acr')

% Tile 2
nexttile
plot(mean(squeeze(covs(:,2,:,:,:)), [3,4]));
title('Unenhanced Tab Acr')

% Tile 3
nexttile
plot(mean(squeeze(covs(:,3,:,:,:)), [3,4]));
title('Enhanced Cor Acr')

% Tile 4
nexttile
plot(mean(squeeze(covs(:,4,:,:,:)), [3,4]));
title('Unenhanced Cor Acr')

% Tile 5
nexttile
plot(mean(squeeze(covs(:,5,:,:,:)), [3,4]));
title('Small massives')

% Tile 6
nexttile
plot(mean(squeeze(covs(:,6,:,:,:)), [3,4]));
title('Large massives')

xlabel(LO,'Years')
ylabel(LO,'Cover (prop)')
            
%% Plot reef condition metrics over time and sites
figure; 
LO2 = tiledlayout(2,2, 'TileSpacing','Compact');

% Tile 1
nexttile
plot(mean(metric_results.coralTaxaCover.total_cover, [3,4]));
title('Total Coral Cover')
ylabel('Cover, prop')

% Tile 2
nexttile
plot(mean(E, [3,4]));
title('Coral Evenness')
ylabel('E, prop')

% Tile 3
nexttile
plot(mean(BC, [3,4]))
title('Juvenile Corals (<5 cm diam)')
ylabel('Cover, prop')

% Tile 4
nexttile
plot(mean(SV_per_ha, [3,4]))
title('Shelter Volume per ha')
ylabel('Volume, m3 / ha') 

xlabel(LO2,'Years')
%ylabel(LO,'Cover (prop)')
