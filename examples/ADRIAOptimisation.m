function [x,fval] = ADRIAOptimisation(alg,opti_ind,varargin)
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
    
    if size(varargin,1) == 0
        % get shell variables
        prsites = str2double(getenv('PrSites'));
        rcp = str2double(getenv('RCP'));
    else
        prsites = varargin{1};
        rcp = varargin{2};
    end
    % use default criteria weights
    CrtWts = CriteriaWeights();  
    % load parameter file
    [params, ecol_parms] = ADRIAparms(); % environmental and ecological parameter values etc

    % initialise parameters (could later randomise this)
    % x0 = [Seed1,Seed2,SRM,Aadpt,Natad]
    x0 = [0 0 0 0 0];

    if sum(opti_ind) == 1
        % if opti_ind = 1, perform a single objective optimisation for
        % chosen output (obj is negative as default is the minimisation)
        ObjectiveFunction = @(x) -1*ObjectiveFunc(x,CrtWts,params,ecol_parms,alg,prsites,rcp,opti_ind);

        % upper bounds on x
        ub = [0.001,0.001,6,6,0.1];
        % lower bounds on x
        lb = [0,0,0,0,0];

        % begin optimisation algorithm
        [x, fval] = simulannealbnd(ObjectiveFunction,x0,lb,ub);
        fval = -1*fval;

    else
        % if sum(opti_ind)>1  perform a multi-objective optimisation over the
        % specified outputs
        ObjectiveFunction = @(x) -1*ObjectiveFunc(x,CrtWts,params,ecol_parms,alg,prsites,rcp,opti_ind);

        % upper bounds on x
        ub = [0.001,0.001,6,6,0.1];
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
        [x, fval] = gamultiobj(ObjectiveFunction,nvar,A,b,Aeq,beq,lb,ub);
        fval = -1*fval;
    end
    % label file with key parameters
    filename = sprintf('ADRIA_opt_out_RCP%2.0f_PrSites%1.0d_Alg%1.0d.csv',rcp,prsites,alg);
    % add filename appendage if specified
    if nargin == 5
        filename = strcat(varargin{4},filename);
    end
    % save as structure
    s = struct('interv',x,'output',fval);
    save(filename,'s')
end