% Example script illustrating differences in algorithm performance for the
% total coral cover metric (shows how algorithm choice could be optimised
% for a given intervention scenario)
nalgs = 4;
nmetrics = 3;
example_file = 'Inputs/MCDA_example.nc';
if isfile(example_file)
    % Load example data from file if pre-prepared
    alg_cont_TC = ncread(example_file, 'TC');
    alg_cont_E = ncread(example_file, 'E');
    alg_cont_S = ncread(example_file, 'S');
else
   
        %% Generate monte carlo samples

        % Number of scenarios
        N = 8;
        num_reps = 50;  % Number of replicate RCP scenarios
        % timesteps, n_algs, n_scenarios, n_metrics
         results = zeros(25, nalgs, N, nmetrics);
        % Collect details of available parameters
        inter_opts = interventionDetails();
        criteria_opts = criteriaDetails();

        % Create main table listing all available parameter options
        combined_opts = [inter_opts; criteria_opts];

        % Generate samples using simple monte carlo
        % Create selection table based on lower/upper parameter bounds
        p_sel = table;
        for p = 1:height(combined_opts)
            a = combined_opts.lower_bound{p};
            b = combined_opts.upper_bound{p};

            selection = (b - a).*rand(N, 1) + a;

            p_sel.(combined_opts.name{p}) = selection;
        end
    

        %% Parameter prep

        % Creating dummy permutations for core ADRIA parameters
        % (environmental and ecological parameter values etc)
        % This process will be replaced
        [params, ecol_params] = ADRIAparms();
        param_tbl = struct2table(params);
        ecol_tbl = struct2table(ecol_params);

        param_tbl = repmat(param_tbl, N, 1);
        ecol_tbl = repmat(ecol_tbl, N, 1);

        % Convert sampled values to ADRIA usable values
        % Necessary as samplers expect real-valued parameters (e.g., floats)
        % where as in practice ADRIA makes use of integer and categorical
        % parameters
        converted_tbl = convertScenarioSelection(p_sel, combined_opts);
       
        % Optional step: Extract unique scenarios
        [u_ss, u_rows, group_idx] = mapDuplicateScenarios(converted_tbl);
        
        % Separate parameters into components
        % (to be replaced with a better way of separating these...)
        IT = u_ss(:, 1:9);
        criteria_weights = u_ss(:, 10:end);

        % make sure all scenarios are guided and use every site each time
        IT.Guided = ones(size(IT.Guided));
        IT.PrSites = 3*ones(size(IT.PrSites));


        %% Load site specific data
        [F0, xx, yy, nsites] = ADRIA_siteTable('MooreSites.xlsx');
        [TP_data, site_ranks, strongpred] = ADRIA_TP('MooreTPmean.xlsx', params.con_cutoff);

        %% setup for the geographical setting including environmental input layers
        % Load wave/DHW scenario data
        % Generated with generateWaveDHWs.m
        % TODO: Replace these with wave/DHW projection scenarios instead
        fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(params.RCP), ".nc");
        wave_scen = ncread(fn, "wave");
        dhw_scen = ncread(fn, "DHW");

        %% Scenario runs
        % Currently running over unique interventions and criteria weights only for
        % a limited number of RCP scenarios.
        %
        % In actuality, this would be done for some combination of:
        % intervention * criteria * environment parameters * ecological parameter
        %     * wave_scen * dhw_scen * alg_ind * N_sims
        % where the unique combinations would be generated via some quasi-monte 
        % carlo sequence, or through some user-informed process.
        
        % Select random subset of RCP conditions WITHOUT replacement
        n_rep_scens = length(wave_scen);
        rcp_scens = datasample(1:n_rep_scens, num_reps, 'Replace', false);
        w_scen = wave_scen(:, :, rcp_scens);
        d_scen = dhw_scen(:, :, rcp_scens);
   for al = 1:nalgs
         % for each algorithm
        alg_ind = al;
        tic
        Y = runADRIA(IT, criteria_weights, param_tbl, ecol_tbl, ...
                         TP_data, site_ranks, strongpred, num_reps, ...
                         wave_scen, dhw_scen, alg_ind);
        tmp = toc;

        disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*num_reps), " simulations (", num2str(tmp/(N*num_reps)), " seconds per run)"))

        % store total coral cover for each scenario averaged over sites and
         % simulations
         results(:, al, :, 1) = mean(mean(Y.TC(:,:,:,:),4),2);
         results(:, al, :, 2) = mean(mean(Y.E(:,:,:,:),4),2);
         results(:, al, :, 3) = mean(mean(Y.S(:,:,:,:),4),2);
    end
    tmp = struct('TC',results(:,:,:,1),'E',results(:,:,:,2),'S',results(:,:,:,3 ));
    saveData(tmp,'Inputs/MCDA_example.nc');
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
count = 1;
for nn = 1:4
    for mm = 1:2
     for k =1:nalgs
        hold on
        subplot(2,4,count)
        plot(1:25,alg_cont_TC(:,k,count))
        legend('alg1','alg2','alg3')
        hold off
     end
     count = count+1;
    end
end

figure(2)
title('E comparison')
count = 1;
for nn = 1:4
    for mm = 1:2
     for k =1:nalgs
        hold on
        subplot(2,4,count)
        plot(1:25,alg_cont_E(:,k,count))
        legend('alg1','alg2','alg3')
        hold off
     end
     count = count+1;
    end
end

figure(3)
title('S comparison')
count = 1;
for nn = 1:4
    for mm = 1:2
     for k =1:nalgs
        hold on
        subplot(2,4,count)
        plot(1:25,alg_cont_S(:,k,count))
        legend('alg1','alg2','alg3')
        hold off
     end
     count = count+1;
    end
end

%%
temp_cont = [];
for alg = 1:3
    for t = 2:25
        filename = sprintf('DMCDA_vals_Alg%1.0f_time%2.0f.mat',alg,t);
        if isfile(filename)
            load(filename)
            temp_cont = [temp_cont; [repmat(alg,length(temp.seedsites),1), repmat(t,length(temp.seedsites),1), temp.seedsites,temp.shadesites]];
        end
    end
end