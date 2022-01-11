function out_metrics = allParamMultiObjectiveFunc(x, ai, modified_params, Nreps, tgt_names)
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
     modified_params(1,'Seed1' )= {(1)};
     modified_params(1,'Seed2') = {x(2)};
     modified_params(1,'SRM') = {x(3)};
     modified_params(1,'Natad') = {x(4)};
     modified_params(1,'Aadapt') = {x(5)};
     
     Y = ai.run(modified_params, sampled_values = false, nreps = Nreps);
     
     
     out_metrics = zeros(Nreps,length(tgt_names));
     for m = 1:length(tgt_names)
         % total coral cover
         if strcmp(tgt_names{m},'TC')
             out_metrics(m)= mean(Y.all,'all');
             %eveness
         elseif strcmp(tgt_names{m},'E')
             [~,E] = coralEvennessADRIA(Y);
             out_metrics(m) = mean(E,'all');
             %shelter volume
         elseif strcmp(tgt_names{m},'SV')
             SV = shelterVolumeADRIA(Y,ai.corals);
             out_metrics(m) = mean(SV,'all');
             % density of juvinile corals
         elseif strcmp(tgt_names{m},'DJ')
             DJ = Y.all(:,1:6:end,:)+ Y.all(:,2:6:end,:);
             DJ = squeeze(sum(DJ,2));
             out_metrics(m) = mean(DJ,'all');
         end
     end

end
