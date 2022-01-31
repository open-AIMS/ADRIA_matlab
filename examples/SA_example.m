%% Sensitivity analysis example
% Requires the SAFE toolbox (v1.1) to be added to path.
%

%% Parameter prep
inter_opts = interventionDetails();
criteria_opts = criteriaDetails();

% table of all parameters and related details
combined_opts = [inter_opts; criteria_opts];

% core ADRIA parameters
[params, ecol_params] = ADRIAparms(); %environmental and ecological parameter values etc

% MCDA algorithm choice (1 to 3)
alg_ind = 1;

%% Load site data
[F0, xx, yy, nsites] = ADRIA_siteTable('MooreSites.xlsx');
[TP_data, site_ranks, strongpred] = siteConnectivity('MooreTPmean.xlsx', params.con_cutoff);

%% ... generate parameter permutations ...
M = height(combined_opts);

xmin = cell2mat(combined_opts.lower_bound);
xmax = cell2mat(combined_opts.upper_bound);

distr_fun = 'unif';
distr_par = cell(M, 1);

for i=1:M; distr_par{i} = [xmin(i) xmax(i)]; end
x_labels = combined_opts.name;

target_output = "TC";

% number of elementary effects (total runs: r * (M+1))
% where r is the # of trajectories, M is the number of factors
r = 2;

sampler = 'lhs';  % latin hypercube sampling
design_type = 'radial';  % using radial design

% Generate samples using SAFE
X = OAT_sampling(r, M, distr_fun, distr_par, sampler, design_type);

% Convert sampled values for use in ADRIA
% (maps real values back to categoricals)
X_conv = convertScenarioSelection(X, combined_opts);

ninter = size(X, 1);

% Creating dummy permutations for core and ecological parameters
param_tbl = struct2table(params);
ecol_tbl = struct2table(ecol_params);

% Repeating constant values
param_tbl = repmat(param_tbl, ninter, 1);
ecol_tbl = repmat(ecol_tbl, ninter, 1);

%% Setup output
% Create temporary struct
tmp_s.TC = 0;
tmp_s.C = 0;
tmp_s.E = 0;
tmp_s.S = 0;

Y = repmat(tmp_s, ninter, 1);

%% Set up the geographical setting including environmental input layers
[wave_scen, dhw_scen] = setupADRIAsims(1, params, nsites);

% TODO: Replace these with wave/DHW projection scenarios instead

%% Scenario runs
% Currently running interventions and criteria weights only
%
% In actuality, this would be done for some combination of:
% intervention * criteria * environment parameters * ecological parameter
%     * wave_scen * dhw_scen * alg_ind * N_sims
% where the combinations would be generated via some quasi-monte carlo
% sequence

X_conv = table2array(X_conv);
IT = X_conv(:, 1:9);
criteria_weights = X_conv(:, 10:end);  % need better way of separating values...

tic
w_scen = wave_scen(:, :, 1);
d_scen = dhw_scen(:, :, 1);
parfor i = 1:ninter
    Y(i) = runADRIAScenario(IT(i, :), criteria_weights(i, :), ...
                            param_tbl(i, :), ecol_tbl(i, :), ...
                            TP_data, site_ranks, strongpred, nsites, ...
                            w_scen, d_scen, alg_ind);
end
tmp = toc;

disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(ninter), " sims (Average of ", num2str(tmp/ninter), " seconds per run)"))

%% post-processing
% collate data across all scenario runs

tf = params.tf;
processed = struct('TC', zeros(tf, nsites, ninter, 1), 'C', zeros(tf, 4, nsites, ninter, 1), 'E', zeros(tf, nsites, ninter, 1), 'S', zeros(tf, nsites, ninter, 1));
for i = 1:ninter
    processed.TC(:, :, i, :) = Y(i).TC;
    processed.C(:, :, :, i, :) = Y(i).C;
    processed.E(:, :, i, :) = Y(i).E;
    processed.S(:, :, i, :) = Y(i).S;
end

%% SA analysis

x_labels = humanReadableName(x_labels);
x_labels = cellstr(x_labels);

% ecosys_results = Corals_to_Ecosys_Services(processed);
% analyseADRIAresults1(ecosys_results);

% Need Y = N dimensional array of QoIs...
Y_TC = squeeze(mean(mean(processed.TC, 2), 1));

% [mu, sigma] = EET_indices(r, xmin', xmax', X, Y_TC, design_type);
% 
% % plot results
% EET_plot(mu, sigma, x_labels)


% Bootstrapped confidence intervals
nboot = 100;
[mu, sigma, EE, mu_sd, sigma_sd, mu_lb, sigma_lb, mu_ub, sigma_ub] = ...
    EET_indices(r, xmin', xmax', X, Y_TC, design_type, nboot);

% Plot boot strapped results
EET_plot(mu, sigma, x_labels, mu_lb, mu_ub, sigma_lb, sigma_ub)

% repeat computations using decreasing sample sizes to check for
% convergence
rr = [r/5:r/5:r];

