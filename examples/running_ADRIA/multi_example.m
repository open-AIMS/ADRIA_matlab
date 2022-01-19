% Example script illustrating running multiple ADRIA scenarios
rng(101)

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
ai.loadConnectivity('MooreTPmean.xlsx');

%% Scenario runs

tic
Y = ai.run(sample_table, sampled_values=true, nreps=n_reps);
% ai.runToDisk(sample_table, sampled_values=true, nreps=n_reps, ...
%     file_prefix='./test', batch_size=4);
tmp = toc;

% If saving results to disk
% Y = ai.gatherResults('./test', {@coralTaxaCover});
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))


% Collect metrics
[~, ~, coral_params] = ai.splitParameterTable(sample_table);
metric_results = collectMetrics(Y, coral_params, ...
                    {@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

covs = metric_results.coralSpeciesCover;

% Evenness
E = metric_results.coralEvenness;

%% Extract juvenile corals (< 5 cm diameter)
BC = metric_results.coralTaxaCover.juveniles;

%% Calculate coral shelter volume per ha
SV_per_ha = metric_results.shelterVolume;

%% Plot coral covers over time and sites
figure; 
LO = tiledlayout(2,3, 'TileSpacing','Compact');

% Tile 1
nexttile
plot(squeeze(covs(:,1,:)));
title('Enhanced Tab Acr')

% Tile 2
nexttile
plot(squeeze(covs(:,2,:)));
title('Unenhanced Tab Acr')

% Tile 3
nexttile
plot(squeeze(covs(:,3,:)))
title('Enhanced Cor Acr')

% Tile 4
nexttile
plot(squeeze(covs(:,4,:)))
title('Unenhanced Cor Acr')

% Tile 5
nexttile
plot(squeeze(covs(:,5,:)))
title('Small massives')

% Tile 6
nexttile
plot(squeeze(covs(:,6,:)))
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
