function [x, fval] = multiObjOptimization(alg, out_names, fn, TP_data, site_ranks, strongpred, varargin)
% multiObjOptimization runs a multi-objective genetic optimisation algorithm 
% to maximise outputs specified in out_names with respect to the intervention 
% variables Seed1, Seed2, SRM, AsAdt, NatAdt
%
% Inputs :
%        if no inputs for prsites and/or rcp, uses standard parameters
%        Input order:
%        alg : indicates MCDA algorithm to be used
%              1 - Order Ranking
%              2 - TOPSIS
%              3 - VIKOR
%        out_names: indicates which outputs to optimise over as a cell structture of strings
%                   e.g. out_names = {'TC','CES','PES'};
%        varargin : default values used if not specified
%        varargin{1} : rcp (rcp scenario value 2.6,4.5,6.0,8.5)
%        varargin{2} : ES_vars (1*7 array with structure [evcult, strcult, evprov, 
%                      strprov,TCsatCult,TCsatProv,cf]
%        varargin{3} : Guided (1 if want to use MCDA algorithms to select
%                      sites (rather than randomised)
%
% Outputs :
%         x : [Seed1,Seed2,SRM,Aadpt,Natad] which maximise the chosen
%             ADRIA output metrics (will represent a pareto front if
%             multiple values are chosen to optimise over.
%         fval : the max value/optimal value of the chosen metrics

    % Perturb all available parameters
    i_params = interventionDetails();
    criteria_weights = criteriaDetails();
    all_params = [i_params; criteria_weights];

    nsites = 26;
    [params, ecol_parms] = ADRIAparms();

    % Filter to target interventions
    p_names = i_params.name;
    rules = false;

    for target = {'Seed1', 'Seed2', 'SRM', 'Aadpt', 'Natad'}
        rules = rules | (p_names == target);
    end
    
    if size(varargin, 1) == 0
        % if nothing provided, use defaults
        % already in params and i_params except for ES_vars
        ES_vars =  [0.5,0.5,0.2,0.8,0.5,0.5,1];
    elseif size(varargin, 1) == 1
        % set rcp to input
        params.RCP = varargin{1};
        % other params defaults
        ES_vars =  [0.5,0.5,0.2,0.8,0.5,0.5,1];
    elseif size(varargin, 1) == 2
         % set all params to input
        params.RCP = varargin{1};
        ES_vars =  varargin{2};
    elseif size(varargin, 1) == 3 && varargin{3} == 1
         % set all params to input
        params.RCP = varargin{1};
        ES_vars =  varargin{2};
        % use guided site seclection algorithm
        all_params.defaults{1}(1) = 1;
    end

    % Wave/DHW scenarios
    wave_scen = ncread(fn, "wave");
    dhw_scen = ncread(fn, "DHW");
    subset = i_params(rules, :);

    % Upper/Lower bounds of x
    lb = cell2mat(subset.lower_bound);
    ub = cell2mat(subset.upper_bound);

    % no. of variables to optimise for = no. of interventions
    nvar = 18;
    ObjectiveFunction = @(x) -1 * allParamMultiObjectiveFunc(x, alg, out_names, ...
        all_params, ...
        nsites, wave_scen, ...
        dhw_scen, params, ...
        ecol_parms, ...
        TP_data, site_ranks, ...
        strongpred, ES_vars);
    
    % no constraint equations for now
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % begin optimisation algorithm
    [x, fval] = gamultiobj(ObjectiveFunction, nvar, A, b, Aeq, beq, lb, ub);
    fval = -1 * fval;

end
