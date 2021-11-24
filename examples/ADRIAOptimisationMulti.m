function [x,fval] = ADRIAOptimisationMulti(alg,out_names,varargin)
    % ADRIAOptimisation takes variables for RCP and
    % PrSites and runs an optimisation algorithm to maximise outputs with
    % respect to the intervention variables Seed1, Seed2, SRM, AsAdt,
    % NatAdt
    % Inputs :
    %        if no inputs for prsites and/or rcp, uses standard parameters
    %        Input order:
    %        alg : indicates MCDA algorithm to be used 
    %              1 - Order Ranking
    %              2 - TOPSIS
    %              3 - VIKOR
    %        out_names: indicates which outputs to optimise over as a cell structture of strings
    %                   e.g. out_names = {'TC','CES','PES'};
    %        varargin{1} : prsites (1,2,3)
    %        varargin{2} : rcp (rcp scenario value 2.6,4.5,6.0,8.5)
    %        varargin{3} : optional appendage to filename (e.g. run no. etc)
    % Outputs :   
    %         x : [Seed1,Seed2,SRM,Aadpt,Natad] which maximise the chosen
    %             ADRIA output metrics (will represent a pareto front if
    %             multiple values are chosen to optimise over.
    %         fval : the max value/optimal value of the chosen metrics 
    
    % Perturb all available parameters
    i_params = interventionDetails();
    criteria_weights = criteriaDetails();
    all_params = [i_params; criteria_weights];

    [TP_data, site_ranks, strongpred] = ADRIA_TP('Inputs/MooreTPmean.xlsx', 0.1);
    nsites = 26;

    [params, ecol_parms] = ADRIAparms();

    % Filter to target interventions
    p_names = i_params.name;
    rules = false;
    
    for target = {'Seed1', 'Seed2', 'SRM', 'Aadpt', 'Natad'}
        rules = rules | (p_names == target);
    end
    
    if size(varargin,1) == 1
        prsites = varargin{1};
        i_params.prsites = prsites;
    elseif size(varargin,1) == 2
         prsites = varargin{1};
         rcp = varargin{2};
         % set rcp to desired value
         params.RCP = rcp;
         i_params.prsites = prsites;
    end
    
    % Wave/DHW scenarios
    fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(rcp), ".nc");
    wave_scen = ncread(fn, "wave");
    dhw_scen = ncread(fn, "DHW");
    subset = i_params(rules, :);

    % Initialise parameters
    x0 = cell2mat(subset.defaults);

    % Upper/Lower bounds of x
    lb = cell2mat(subset.lower_bound);
    ub = cell2mat(subset.upper_bound);

    % objective function for simulated annealing function is negative (as
    % solves the minimisation) and must have a single vector input and scalar
    % output
    % no. of variables to optimise for = no. of interventions
    nvar = 5;
    ObjectiveFunction = @(x) -1*AllParamObjectiveFuncMulti(x, alg, out_names, ...
                                                            all_params, ...
                                                            nsites, wave_scen, ...
                                                            dhw_scen, params, ...
                                                            ecol_parms, ...
                                                            TP_data, site_ranks, strongpred);
        if size(out_name) == 1
            % begin optimisation algorithm
            [x, fval] = simulannealbnd(ObjectiveFunction,x0,lb,ub);
            fval = -1*fval;

        else
            % no constraint equations for now
            A = [];
            b = [];
            Aeq = [];
            beq = [];

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
        %s = struct('interv',x,'output',fval);
        %save(filename,'s')
        
        % Save as CSV
        saveData(x, filename, 'csv')
end

