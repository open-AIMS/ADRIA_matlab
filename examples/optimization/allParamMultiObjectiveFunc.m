function out_metrics = allParamMultiObjectiveFunc(x, ai, modified_params, Nreps, func_names)
    % Objective function that runs a single ADRIA simulation for all
    % parameters, allowing variable parameter inputs for interventions.
    %
    % Gives a vector of total average outputs in the order of tgt_names.
    
    % Input : 
    %     x             : array, perturbed parameters
    %     ai           : ADRIA class object
    %     tgt_names      : cell of strs, name of output to optimize (TC, E, S, CES, PES)
    %     modified_params : table, ADRIA parameter details, as modified in
    %                       multiObjOptimisation
    %
    % Output : 
    %     out_metrics : average output metrics (specified by tgt_name) over
    %                   time/sites/corals

    %% Convert sampled values back to ADRIA expected values
     modified_params(1,'Seed1' )= {x(1)};
     modified_params(1,'Seed2') = {x(2)};
     modified_params(1,'SRM') = {x(3)};
     modified_params(1,'Natad') = {x(4)};
     modified_params(1,'Aadapt') = {x(5)};
     modified_params(1,'Seedyrs') = {x(6)};
     modified_params(1,'Shadeyrs') = {x(7)};
     
     Y = ai.run(modified_params, sampled_values = false, nreps = Nreps);
     [~, ~, coral_params] = ai.splitParameterTable(modified_params);
     
     % Collect metrics
     metric_results = collectMetrics(Y, coral_params,func_names);
     out_metrics = zeros(1,length(func_names));
     
     for m = 1:length(func_names)
         switch func2str(func_names{m})
             case 'coralTaxaCover'
                  out_metrics(m)= mean(metric_results.(func2str(func_names{m})).total_cover,'all');
             otherwise
                 out_metrics(m)= mean(metric_results.(func2str(func_names{m})),'all');
         end
     end
end
