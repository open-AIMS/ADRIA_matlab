% Example script illustrating running ADRIA scenarios in batches
rng(101)


%% Generate monte carlo samples

% Number of scenarios
N = 50;
n_reps = 50;  % Number of replicate RCP scenarios

ai = ADRIA();

%% Parameter prep
% Collect details of available parameters
combined_opts = ai.parameterDetails();
sim_constants = ai.criterias;

% Generate samples using simple monte carlo
% Create seeding selection table based on lower/upper parameter bounds

sample_table = table;
for p = 1:height(combined_opts)

        a = combined_opts.lower_bound(p);
        b = combined_opts.upper_bound(p);
        
        selection = (b - a).*rand(N, 1) + a;
        sample_table.(combined_opts.name(p)) = selection;
    
end
for p = 4:height(combined_opts)
    sample_table.(combined_opts.name(p)) = repmat(combined_opts.sample_defaults(p),N,1);
end

% for this example
sample_table.Guided(:) = [zeros(floor(length(sample_table.Guided(:))/2),1) ones(ceil(length(sample_table.Guided(:))/2),1)];
sample_table.Seed1(1:ceil(length(sample_table.Seed1(:))/2)) =  zeros(ceil(length(sample_table.Seed1(:))/2),1);
sample_table.Seed2(1:ceil(length(sample_table.Seed2(:))/2)) =  zeros(ceil(length(sample_table.Seed2(:))/2),1);
sample_table.wave_stress(:) = zeros(length(sample_table.wave_stress(:)),1);
sample_table.seed_priority(:) = zeros(length(sample_table.seed_priority(:)),1);

[~,~,coral_params] = ai.splitParameterTable(sample_table);

%% Load site specific data
ai.loadConnectivity('./Inputs/Moore/connectivity/2015');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

%% run ADRIA

Y = ai.run(sample_table,sampled_values=true,nreps=n_reps);
metric_results = collectMetrics(Y.Y, coral_params, ...
                    {@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% Store results in 2D matrix 
tmp_param_tbl = table2array(sample_table);
store_param_tbl = zeros(n_reps*N*25*366,7);
count = 1;
for l = 1:N
    for j = 1:n_reps
        for ns = 1:366
            for yr = 1:25
                store_param_tbl(count,:) = [yr ns tmp_param_tbl(l,2:3)...
                    metric_results.coralTaxaCover.total_cover(yr,ns,l,j),...
                    metric_results.coralEvenness(yr,ns,l,j),...
                    metric_results.shelterVolume(yr,ns,l,j)]; % year site seed CC Evenness SV
                count = count + 1;
            end
        end
    end
end

writematrix(store_param_tbl,'BBN_data_366_sites.csv')
