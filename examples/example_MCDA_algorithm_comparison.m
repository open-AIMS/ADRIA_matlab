% Example script illustrating differences in algorithm performance for the
% total coral cover metric (shows how algorithm choice could be optimised
% for a given intervention scenario)
nalgs = 3;
nmetrics = 1;

% Number of scenarios
N = 1;
example_file = 'Inputs/MCDA_example.nc';
metric = {@coralSpeciesCover};
%{@coralTaxaCover};

if isfile(example_file)
    % Load example data from file if pre-prepared
    alg_cont_TC = ncread(example_file, 'TC');
else
   
        %% Generate monte carlo samples

        num_reps = 50;  % Number of replicate RCP scenarios
        % timesteps, n_algs, n_scenarios, n_metrics
        results = zeros(25, nalgs, N, nmetrics);
        ai = ADRIA();
        
        param_table = ai.raw_defaults;
        param_table.Guided = 1;
        param_table.Seed1 = 15000;
        param_table.Seed2 = 50000;
        % Collect details of available parameters
        %combined_opts = ai.parameterDetails();
        % Get default parameters
        
        sim_constants = ai.constants;
        ai.constants.RCP = 60;
        % Generate samples using simple monte carlo
        % Create selection table based on lower/upper parameter bounds
%         p_sel = table;
%         for p = 1:height(combined_opts)
%             a = combined_opts.lower_bound(p);
%             b = combined_opts.upper_bound(p);
% 
%             selection = (b - a).*rand(N, 1) + a;
% 
%             p_sel.(combined_opts.name(p)) = selection;
%         end
%     
%         [~, ~, coral_params] = ai.splitParameterTable(ai.raw_defaults);
        %% Parameter prep

        % Load site specific data
        ai.loadConnectivity('MooreTPmean.xlsx');
 
        %% Scenario runs
        % Currently running over unique interventions and criteria weights only for
        % a limited number of RCP scenarios.
%         p_sel.Guided(:) = 1*ones(length(p_sel.Guided(:)),1);
%         p_sel.PrSites(:) = 3*ones(length(p_sel.PrSites(:)),1);
%         p_sel.Seedyrs(:) = 5*ones(length(p_sel.Seedyrs(:)),1);
%         p_sel.Shadeyrs(:) = 12*ones(length(p_sel.Shadeyrs(:)),1);
   for al = 1:nalgs
         % for each algorithm
        %alg_ind = al;
        param_table.alg_ind = al;
        %p_sel.alg_ind(:) = al*ones(length(p_sel.alg_ind(:)),1);
        tic
        Y = ai.run(param_table,sampled_values = false, nreps = num_reps);
        tmp = toc;
        disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*num_reps), " simulations (", num2str(tmp/(N*num_reps)), " seconds per run)"))
        out = collectMetrics(squeeze(Y),coral_params,metric);
        % store total coral cover for each scenario averaged over sites and
         % simulations
         TC = out.coralSpeciesCover;
         results(:, al, :) = squeeze(mean(TC(:,1,:),3));
         %mean(mean(TC(:,:,:,:),4),2);
  %       results2(:, al, :) = mean(mean(TC(:,:,:,:),4),2);
   end
    filename='Inputs/MCDA_example.nc';
    nccreate(filename,'TC','Dimensions',{'time',25,'algs',nalgs,'pars',N});
    ncwrite(filename,'TC',results);
end

%% plotting comparisons
% each subplot is a randomised intervention scenario (row in the table IT)
% shows how average coral cover by year varies with site selection
% algorithm chosen
% the algorithm achieving the average highest coral cover for an individual
% scenario varies significantly, and hence should be probably be optimised
% for
figure(1)
title('TC comparison')

for count = 1:N
     for k =1:nalgs
        hold on
        subplot(5,10,count)
        plot(1:25,alg_cont_TC(:,k,count))
       % title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
        hold off
     end
end

figure(2)
for count = 1:N
        hold on
        subplot(5,10,count)
        plot(1:25,alg_cont_TC(:,3,count)-alg_cont_TC(:,1,count))
        %title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
       % ylim([0,0.3])
        hold off
end

