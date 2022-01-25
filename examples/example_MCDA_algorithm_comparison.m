% Example script illustrating differences in algorithm performance for the
% total coral cover metric (shows how algorithm choice could be optimised
% for a given intervention scenario)
nalgs = 4;
nmetrics = 1;

% Number of scenarios
N = 1;
example_file = 'Inputs/MCDA_example.nc';
metric = {@coralSpeciesCover};

if isfile(example_file)
    % Load example data from file if pre-prepared
    alg_cont_TC = ncread(example_file, 'TC');
else
   
        %% Generate monte carlo samples

        num_reps = 50;  % Number of replicate RCP scenarios
        % timesteps, n_algs, n_scenarios, n_metrics
        results = zeros(25, nalgs+1, N, num_reps);
        results2 = zeros(25, nalgs+1, N);
        ai = ADRIA();
        
%         param_table = ai.raw_defaults;
%         param_table.Guided = 1;
%         param_table.Seed1 = 15000;
%         param_table.Seed2 = 50000;
        % Collect details of available parameters
        combined_opts = ai.parameterDetails();
        % Get default parameters
        
        sim_constants = ai.constants;
        ai.constants.RCP = 45;
        % Generate samples using simple monte carlo
        % Create selection table based on lower/upper parameter bounds
         p_sel = table;
         for p = 1:height(combined_opts)
             a = combined_opts.lower_bound(p);
             b = combined_opts.upper_bound(p);
 
             selection = (b - a).*rand(N, 1) + a;
 
             p_sel.(combined_opts.name(p)) = selection;
         end
     
         [~, ~, coral_params] = ai.splitParameterTable(ai.raw_defaults);
        %% Parameter prep

        % Load site specific data
        ai.loadConnectivity('MooreTPmean.xlsx');
 
        %% Scenario runs
        % set all criteria weights and seed yrs/ shade yrs to be the same
         p_sel.Seedyrs(:) = ones(length(p_sel.Seedyrs(:)),1);
         p_sel.Shadeyrs(:) = ones(length(p_sel.Shadeyrs(:)),1);
% 
         p_sel.coral_cover_high(:) = ones(length(p_sel.coral_cover_high(:)),1);
         p_sel.coral_cover_low(:) = ones(length(p_sel.coral_cover_low(:)),1);
         p_sel.wave_stress(:) = ones(length(p_sel.wave_stress(:)),1);
         p_sel.heat_stress(:) = ones(length(p_sel.heat_stress(:)),1);
         p_sel.shade_connectivity(:) = ones(length(p_sel.shade_connectivity(:)),1);
         p_sel.seed_connectivity(:) = ones(length(p_sel.seed_connectivity(:)),1);
         p_sel.shade_priority(:) = ones(length(p_sel.shade_priority(:)),1);
         p_sel.seed_priority(:) = ones(length(p_sel.seed_priority(:)),1);
         p_sel.SRM(:) = zeros(length(p_sel.SRM(:)),1);
         %p_sel.Aadpt(:) = zeros(length(p_sel.Aadpt(:)),1);
        p_sel.deployed_coral_risk_tol(:) = ones(length(p_sel.deployed_coral_risk_tol(:)),1);

   for al = 0:nalgs
       % for each algorithm
        p_sel.Guided(:) = al*ones(length(p_sel.Guided(:)),1)+1;
        tic
        Y = ai.run(p_sel,sampled_values = true, nreps = num_reps);
        tmp = toc;
        disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*num_reps), " simulations (", num2str(tmp/(N*num_reps)), " seconds per run)"))
        for m = 1:N
            for l = 1:num_reps
                out = collectMetrics(squeeze(Y(:,:,:,m,l)),coral_params,metric);
                TC = out.coralSpeciesCover;
                results(:, al+1, m,l) = squeeze(mean(mean(TC,2),3));
                
            end
            results2(:, al+1, m) = mean(results(:, al+1, m,:),4);
            
        end
        % store total coral cover for each scenario averaged over sites and
         % simulations
        
   end
    filename='Inputs/MCDA_example.nc';
    nccreate(filename,'TC','Dimensions',{'time',25,'algs',nalgs+1,'pars',N,'num_reps',num_reps});
    ncwrite(filename,'TC',results2);
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
     %for k =1:nalgs+1
        
        subplot(5,5,count)
        hold on
        plot(1:25,alg_cont_TC(:,1,count))
        plot(1:25,alg_cont_TC(:,2,count))
        plot(1:25,alg_cont_TC(:,3,count),'--')
        plot(1:25,alg_cont_TC(:,4,count))
        plot(1:25,alg_cont_TC(:,5,count),'--')
       % title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
        hold off
    % end
end

%figure(2)
% for count = 1:N
%         hold on
%         subplot(5,10,count)
%         plot_distribution_prctile(1:25,squeeze(alg_cont_TC(:,2,count,:)-alg_cont_TC(:,1,count,:))',Color=[255/255,51/255,51/255]) % Red
%         plot_distribution_prctile(1:25,squeeze(alg_cont_TC(:,3,count,:)-alg_cont_TC(:,1,count,:))',Color=[255/255,255/255,51/255]) % Yellow
%         plot_distribution_prctile(1:25,squeeze(alg_cont_TC(:,4,count,:)-alg_cont_TC(:,1,count,:))',Color=[51/255,153/255,255/255]) % Bule
%         plot_distribution_prctile(1:25,squeeze(alg_cont_TC(:,5,count,:)-alg_cont_TC(:,1,count,:))',Color=[51/255,255/255,153/255]) % Green
%         %plot(1:25,alg_cont_TC(:,4,count)-alg_cont_TC(:,1,count))
%         %title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
%        % ylim([0,0.3])
%         hold off
% end


% figure(3)
% for count = 1:N
%         hold on
%         subplot(5,10,count)
%         ax = gca;
%         al_goodplot(squeeze(alg_cont_TC(:,2,count,:)-alg_cont_TC(:,1,count,:))',1:25,ax)%,0.5,[255/255,51/255,51/255]); % Red
%         al_goodplot(squeeze(alg_cont_TC(:,3,count,:)-alg_cont_TC(:,1,count,:))',1:25,ax,0.5,[255/255,255/255,51/255]); % Yellow
%         al_goodplot(squeeze(alg_cont_TC(:,4,count,:)-alg_cont_TC(:,1,count,:))',1:25,ax,0.5,[51/255,153/255,255/255]); % Bule
%         al_goodplot(squeeze(alg_cont_TC(:,5,count,:)-alg_cont_TC(:,1,count,:)),1:25,ax,0.5,[51/255,255/255,153/255]); % Green
%         %plot(1:25,alg_cont_TC(:,4,count)-alg_cont_TC(:,1,count))
%         %title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
%        % ylim([0,0.3])
%         hold off
% end
