% ADRIAOptimisation collects shell environment variables for RCP and
% PrSites and runs an optimisation algorithm to find average total
% coral cover maximising values of the interventions

alg = 1; % alg_ind
% indicate which variables to optimise over out of [TC,E,S,CES,PES]
% 1 : include, 0 : don't include
% sum(opti_ind) >=1
opti_ind = [1 0 0 0 0]; 

% get shell variables
prsites = str2num(getenv('PrSites')); % PrSites
rcp = str2num(getenv('RCP'));; % RCP

% use default criteria weights
CrtWts = CriteriaWeights();  
%load parameter file
[params, ecol_parms] = ADRIAparms(); % environmental and ecological parameter values etc

% initialise parameters
% x0 = [Seed1,Seed2,SRM,Aadpt,Natad]
x0 = [0 0 0 0 0];

% objective function for simulated annealing function is negative (as
% solves the minimisation) and must have a single vector input and scalar
% output
if sum(opti_ind) == 1
    % if opti_ind = 1, perform a single objective optimisation for average
    % TC
    ObjectiveFunction = @(x) -1*ObjectiveFunc(x,alg,opti_ind,prsites,rcp,CrtWts,params,eco_parms);
    
    % upper bounds on x
    ub = [0.001,0.001,5,5,0.1];
    % lower bounds on x
    lb = [0,0,0,0,0];

    % begin optimisation algorithm
    x = simulannealbnd(ObjectiveFunction,x0,lb,ub);
    
else
    % if sum(opti_ind)>1  perform a multi-objective optimisation over the
    % specified outputs
    ObjectiveFunction = @(x) -1*ObjectiveFunc(x,alg,prsites,rcp,opti_ind,CrtWts,params,eco_parms);
    
    % upper bounds on x
    ub = [0.001,0.001,5,5,0.1];
    % lower bounds on x
    lb = [0,0,0,0,0];
    
    % no constraint equations for now
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    % no. of variables to optimise for = no. of interventions
    nvar = 5;
    
    % begin optimisation algorithm
    x = gamultiobj(ObjectiveFunction,x0,A,b,Aeq,beq,lb,ub);
end

% label file with key parameters
filename = sprintf('ADRIA_opt_out_RCP%2.0f_PrSites%1.0d_Alg%1.0d.csv',rcp,prsites,alg);
% save as csv
savematrix(x,filename)