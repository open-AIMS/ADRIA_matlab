function [x, fval] = multiObjOptimization(alg, rcp, Nreps, filename, func_names)
% Inputs :
%        alg : indicates MCDA algorithm to be used
%              1 - Order Ranking
%              2 - TOPSIS
%              3 - VIKOR
%        rcp: indicates rcp scenario
%        Nreps : number of runs for climate scenario simulation
%        filename : filename to load connectivity data from
%        tgt_names : cell of strings indicating which outputs to optimise
%                    over (must contain at least 2 strings, otherwise use
%                    single output optimisation function objOptimisation).
%                           - 'TC' : total coral cover
%                           - 'E' : Evenness
%                           - 'SV' : Shelter Volume
%                           - 'DJ' : Density of juvenile corals
%
% Outputs :
%         x : [Seed1,Seed2,SRM,Aadpt,Natad] which maximise the chosen
%             ADRIA output metrics (will represent a pareto front if
%             multiple values are chosen to optimise over.
%         fval : the max value/optimal value of the chosen metrics     

     % create ADRIA class
     ai = ADRIA();
     % load connectivity data
     ai.loadConnectivity(filename,cutoff = 0.1);
      
     % define parameters which will not be perturbed during optimisation
     modified_params = ai.raw_defaults;
     modified_params(1,'Guided') = {alg};
     modified_params(1,'PrSites') = {3};
     ai.constants.RCP = rcp;

    % define multi-objective function
    ObjectiveFunction = @(x) -1 * allParamMultiObjectiveFunc(x, ai, modified_params, Nreps, func_names);
    
    % number of parameters being optimised over
     nvar = 7;
     
    % no constraint equations for now
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    % use parameter lower and upper bounds in ai to define lb and ub
    lb = ai.raw_bounds.lower_bound(4:10);
    ub = ai.raw_bounds.upper_bound(4:10);
    
    % begin optimisation algorithm
    [x, fval] = gamultiobj(ObjectiveFunction, nvar, A, b, Aeq, beq, lb, ub);
    fval = -1 * fval;

end
