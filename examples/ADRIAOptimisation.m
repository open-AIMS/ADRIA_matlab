%function [x,fval] = ADRIAOptimisation(alg,opti_ind,varargin)
    % ADRIAOptimisation takes variables for RCP and
    % PrSites and runs an optimisation algorithm to maximise outputs with
    % respect to the intervention variables Seed1, Seed2, SRM, AsAdt,
    % NatAdt
    % Inputs :
    %        if 2 inputs, will use shell variables for PrSites and RCP
    %        if > 2 inputs, will use these as PrSites and RCP
    %        Input order:
    %        alg : indicates MCDA algorithm to be used 
    %              1 - Order Ranking
    %              2 - TOPSIS
    %              3 - VIKOR
    %        opti_ind : indicates which outputs to optimise over out of [TC,E,S,CES,PES]
    %              1 - include, 0 - don't include, sum(opti_ind) >=1
    %              ex., opti_ind = [1 0 0 0 0] optimises for average TC only
    %        varargin{1} : prsites (1,2,3)
    %        varargin{2} : rcp (rcp scenario value 2.6,4.5,6.0,8.5)
    %        varargin{3} : optional appendage to filename (e.g. run no. etc)
    % Outputs :   
    %         x : [Seed1,Seed2,SRM,Aadpt,Natad] which maximise the chosen
    %             ADRIA output metrics (will represent a pareto front if
    %             multiple values are chosen to optimise over.
    %         fval : the max value/optimal value of the chosen metrics 
    
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


        % no. of variables to optimise for = no. of interventions
        %nvar = 5;


        % begin optimisation algorithm
    %    [x, fval] = gamultiobj(ObjectiveFunction,nvar,A,b,Aeq,beq,lb,ub);
     %   fval = -1*fval;
    %end
    % label file with key parameters
   % filename = sprintf('ADRIA_opt_out_RCP%2.0f_PrSites%1.0d_Alg%1.0d.csv',rcp,prsites,alg);
    % add filename appendage if specified
    %if nargin == 5
       % filename = strcat(varargin{4},filename);
   % end
    % save as structure
   % s = struct('interv',x,'output',fval);
   % save(filename,'s')
%end

% label file with key parameters
filename = sprintf('ADRIA_opt_out_RCP%2.0f_PrSites%1.0d_Alg%1.0d.csv',rcp,prsites,alg);

% Save as CSV
saveData(x, filename, 'csv')

