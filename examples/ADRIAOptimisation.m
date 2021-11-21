% ADRIAOptimisation collects shell environment variable for RCP and
% PrSites and runs a simulated annealing algorithm to find avergae totl
% coral cover maximising values of the interventions

alg = 1;  % Use Order Ranking

% get shell variables
prsites = str2num(getenv('PrSites')); % PrSites
rcp = str2num(getenv('RCP')); % RCP
out_name = 'TC'; % out_ind

% Use default criteria weights
criteria_opts = criteriaDetails();
CrtWts = cell2mat(criteria_opts.defaults)';

% Perturb subset of intervention options
i_params = interventionDetails();

% Filter to target interventions
p_names = i_params.name;
rules = false;
for target = {'Seed1', 'Seed2', 'SRM', 'Aadpt', 'Natad'}
    rules = rules | (p_names == target);
end

subset = i_params(rules, :);

% Initialise parameters
x0 = cell2mat(subset.defaults);

% Upper/Lower bounds of x
lb = cell2mat(subset.lower_bound);
ub = cell2mat(subset.upper_bound);

[params, ecol_parms] = ADRIAparms();

% objective function for simulated annealing function is negative (as
% solves the minimisation) and must have a single vector input and scalar
% output
ObjectiveFunction = @(x) -1*ObjectiveFunc(x,alg,prsites,rcp,out_name,CrtWts, params, ecol_parms);

% begin optimisation algorithm
x = simulannealbnd(ObjectiveFunction,x0,lb,ub);

% label file with key parameters
filename = sprintf('ADRIA_opt_out_RCP%2.0f_PrSites%1.0d_Alg%1.0d.csv',rcp,prsites,alg);

% Save as CSV
saveData(x, filename, 'csv')