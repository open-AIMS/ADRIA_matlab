%% Example showcasing how to plot violin plots for a set of ADRIA runs
rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values
param_table = ai.raw_defaults;
% Get the coral parameters, which are not modified for this example
[~, ~, coral_params] = ai.splitParameterTable(param_table);
% just consider 25 years
ai.constants.tf = 25;
%% 3. Modify table as desired...
param_table.Guided = 1;
param_table.Seed1 = 2000;
param_table.Seed2 = 2000;
param_table.SRM = 4;
param_table.Aadpt = 4;
param_table.Seedfreq = 0;

%% Run ADRIA

% Load site specific data
ai.loadConnectivity('./Inputs/Moore/connectivity/2015/moore_d2_2015_transfer_probability_matrix_wide.csv',cutoff=0.1);
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

% number of replicates
n_reps = 50;
ai.loadDHWData('./Inputs/Moore/DHWs/dhwRCP45.mat', n_reps);

% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps);
Y = res.Y;  % get raw results

%% Calculate metrics to plot violin plots

% Collect metrics
metric_results = collectMetrics(Y, coral_params, ...
                    {@coralSpeciesCover});
% Coral cover
covs = metric_results.coralSpeciesCover;

%% Plotting using Violinplot-Matlab Toolbox (available at https://github.com/bastibe/Violinplot-Matlab)

% plot years against coral cover (averaged over species and time)
cov_mat = squeeze(mean(mean(covs,2),3))';
% years lables as cell of strings
cat_yrs = cell(1,25);
for l = 1:25
    cat_yrs{l} = num2str(2000+l);
end
% plot using violinplot function
violinplot(cov_mat, cat_yrs)
title(gca,'Average coral cover per year')

%% Plotting using al_goodplot (available at https://au.mathworks.com/matlabcentral/fileexchange/91790-al_goodplot-boxblot-violin-plot)

% create vector of years
pos_yrs = 2000:2025;
% extract 25 unique colours for plotting
cols = turbo(25);
% plot using al_goodplot function
 al_goodplot(cov_mat,pos_yrs,0.5,cols)
title(gca,'Average coral cover per year')

%% Compare with intervention case
param_table.Guided = 0;
param_table.Seed1 = 0;
param_table.Seed2 = 0;
param_table.SRM = 0;
param_table.Natad = 0;
param_table.Seedfreq = 0;
param_table.Seedyrs = 0;
param_table.Shadeyrs = 0;
%% Run ADRIA
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps);
Y_cf = res.Y;  % get raw results

%% Calculate metrics to plot violin plots

% Collect metrics
metric_results = collectMetrics(Y_cf, coral_params, ...
                    {@coralSpeciesCover});
% Coral cover
covs_cf = metric_results.coralSpeciesCover;

%% Plot comparisons between intervention and counterfactual
cov_cf_mat = squeeze(mean(mean(covs_cf,2),3))';
figure()
hold on
al_goodplot(cov_cf_mat(:,1:2:end),pos_yrs(1:2:end),0.5,[152/255,0,76/255],'left')
al_goodplot(cov_mat(:,1:2:end),pos_yrs(1:2:end),0.5,[0,76/255,153/255],'right')
