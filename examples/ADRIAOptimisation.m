% ADRIAOptimisation collects shell environment variable for RCP and
% PrSites and runs a simulated annealing algorithm to find avergae totl
% coral cover maximising values of the interventions

alg = 1; % alg_ind

% get shell variables
prsites = str2num(getenv('PrSites')); % PrSites
rcp = str2num(getenv('RCP'));; % RCP

numvar = 1; % out_ind

% use default criteria weights
CrtWts = CriteriaWeights();  

% initialise parameters
% x0 = [Seed1,Seed2,SRM,Aadpt,Natad]
x0 = [0 0 0 0 0];

% objective function for simulated annealing function is negative (as
% solves the minimisation) and must have a single vector input and scalar
% output
ObjectiveFunction = @(x) -1*ObjectiveFunc(x,alg,prsites,rcp,numvar,CrtWts);

% upper bounds on x
ub = [0.001,0.001,5,5,0.1];
% lower bounds on x
lb = [0,0,0,0,0];

% begin optimisation algorithm
x = simulannealbnd(ObjectiveFunction,x0,lb,ub);

% label file with key parameters
filename = sprintf('ADRIA_opt_out_RCP%2.0f_PrSites%1.0d_Alg%1.0d.csv',rcp,prsites,alg);
% save as csv
savematrix(x,filename)