%% Example showcasing how to define and run specific scenarios

rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values

% Getting the default values for all parameters
param_table = ai.raw_defaults;


%% 3. Modify table as desired...

% Desired parameter combinations
guided = [0; 1; 2; 3];
assistadapt = [0; 4; 8];
natadapt = [0.0; 0.2];

% Create a matrix of all the possible combinations of the values defined
% above.
[gg, ag, ng] = ndgrid(guided, assistadapt, natadapt);
all_combs = [gg(:), ag(:), ng(:)];

% Hard set the number of target corals (40K a year over 10 years)
% Two types of corals, so 20K each, per year.
param_table.Seed1(:) = 20000;
param_table.Seed2(:) = 20000;
param_table.Seedyrs(:) = 10;

% The `+1` is for the counterfactual
num_combinations = length(all_combs) + 1;

% Repeat the parameter table for the number of runs we want to do
param_table = repmat(param_table, num_combinations, 1);

% Set up the counterfactual
param_table{1, "Guided"} = 0;
param_table{1, "Aadpt"} = 0;
param_table{1, "Natad"} = 0;
param_table{1, "Seed1"} = 0;
param_table{1, "Seed2"} = 0;

% We start at 2 to keep the first simulation as the the counterfactual
% (all default values, except seeding/shading off)
for i = 2:num_combinations
    param_table{i, ["Guided", "Aadpt", "Natad"]} = all_combs(i-1, :);
end

%% Run ADRIA

% We want to run for 50 years
ai.constants.tf = 50;

n_reps = 50;  % num DHW/Wave/RCP replicates

% Load site specific data
ai.loadConnectivity('Inputs/Moore/connectivity/2015/');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

% Where result files will be written out to.
file_location_prefix = './Outputs/fri_deliv_2022-02-04';
n_batches = 5;

tic
% Run a single simulation with `n_reps` replicates
% saving to files in the above indicated location to save memory
ai.runToDisk(param_table, sampled_values=true, nreps=n_reps, ...
    file_prefix=file_location_prefix, batch_size=n_batches, collect_logs=["site_rankings"]);

% Collect the desired metrics from the result files
desired_metrics = {@coralTaxaCover, ...
                   @coralEvenness, ...
                   @coralSpeciesCover, ...
                   @shelterVolume, ...
                   @(x, p) mean(coralTaxaCover(x, p).total_cover, 4)};
Y = ai.gatherResults(file_location_prefix, desired_metrics);

% Get the logged site rankings as well
Y_rankings = ai.gatherResults(file_location_prefix, {}, "MCDA_rankings");

tmp = toc;

N = length(Y) * n_batches * n_reps;
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N), " simulations (", num2str(tmp/(N)), " seconds per run)"))


%% Collect metrics

% Get the mean total coral cover at end of simulation time across all
% simulations.
% Note the name of the custom function has been transformed from its 
% function name to a representative string (brackets/dots to underscores).
mean_TC = concatMetrics(Y, "mean_coralTaxaCover_x_p_total_cover_4");
mean_TC = squeeze(mean(mean_TC(end, :, :, :), 4));


% Total coral cover
TC = concatMetrics(Y, "coralTaxaCover.total_cover");

% Coral cover per species
covs = concatMetrics(Y, "coralSpeciesCover");

% Evenness
E = concatMetrics(Y, "coralEvenness");

% Extract juvenile corals (< 5 cm diameter)
BC = concatMetrics(Y, "coralTaxaCover.juveniles");

% Calculate coral shelter volume per ha
SV_per_ha = concatMetrics(Y, "shelterVolume");

%% Retrieve depth filtered sitesa for plotting
depth_min = 5;
depth_offset = 5;
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id","k",["Acropora2026","Goniastrea2026"],"sitedepth","recom_connectivity"]]);
site_data = sortrows(site_data, "recom_connectivity");
max_depth = depth_min+depth_offset;
depth_criteria = (site_data.sitedepth >-max_depth)&(site_data.sitedepth<-depth_min);
depth_priority = site_data{depth_criteria,"recom_connectivity"};

%% Create BBN table

% Table with node headings yr, site, Seed1, Seed2, NatAd, As Adt., Total Cover,
% E, SV
nnodes = 9;
nyrs = 50;
nsites = length(depth_priority);
Nint = 25;
store_table = zeros((nyrs/2)*Nint*nsites,nnodes);
count = 0;
batch_size = 5;
for l = 1:2:nyrs
    for s = 1:nsites
        for m = 1:n_batches
            for n = 1:batch_size
                 count = count +1;
                 store_table(count,1) = l;
                 store_table(count,2) = depth_priority(s);
                 store_table(count,3) = param_table.Seed1(m);
                 store_table(count,4) = param_table.Seed2(m);
                 store_table(count,5) = param_table.Natad(m);
                 store_table(count,6) = param_table.Aadpt(m);
                 store_table(count,7) = squeeze(mean(Y{m}.mean_coralTaxaCover_x_p_total_cover_4(yr,depth_priority(s),n,:),4));
                 store_table(count,8) = squeeze(mean(Y{m}.mean_coralEvenness(yr,depth_priority(s),n,:),4));
                 store_table(count,9) = squeeze(mean(Y{m}.mean_shelterVolume(yr,depth_priority(s),n,:),4));
            end
        end
    end
end

%% Create BBN
nodeNames = {'Yr','Site','Seed1','Seed2','NatAd','AsAdt','Coral Cover','Evenness','Shelter Vol.'};
ParentCell = cell(1,nnodes);
for c = 1:nnodes-3
    ParentCell{c} = [];
end
for c = nnodes-2:nnodes
    ParentCell{c} = [1:nnodes-3];
end

R = bn_rankcorr(ParentCell,store_table,1,1,nodeNames);

%% Begin inferences
% Rose histograms
% seeding scenario
inf_cells = [1 3:nnodes-3];
increArray = 0:10:50;
increArray(1) = 1;
nodePos = 1;
knownVars = [20000,20000,0.2,4];
F_1 = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);
% counterfactual
knownVars = [0,0,0,0];
F_c = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);
% plot as Rose histograms
figure(1)

% Spatially ploted probabilities