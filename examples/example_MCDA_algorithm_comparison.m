% Example script illustrating differences in algorithm performance for the
% total coral cover metric (shows how algorithm choice could be optimised
% for a given intervention scenario)
nalgs = 3;
nmetrics = 4;
timef = 25;
% Number of scenarios
N = 8;
example_file1 = 'Inputs/MCDA_example_TC.nc';
example_file2 = 'Inputs/MCDA_example_Ev.nc';
example_file3 = 'Inputs/MCDA_example_SV.nc';
example_file4 = 'Inputs/MCDA_example_Ju.nc';
metric = {@coralTaxaCover,@coralEvenness,@shelterVolume};

if isfile(example_file1)
    % Load example data from file if pre-prepared
    alg_cont_TC = ncread(example_file1, 'TC');
    alg_cont_Ev = ncread(example_file2, 'Ev');
    alg_cont_SV = ncread(example_file3, 'SV');
    alg_cont_Ju = ncread(example_file4, 'Ju');

    figure(1)
   title('TC comparison')
    for count = 1:N
         %for k =1:nalgs+1            
            subplot(2,4,count)
            hold on
            plot(1:timef,alg_cont_TC(:,1,count),'r')
            plot(1:timef,alg_cont_TC(:,2,count),'b')
            plot(1:timef,alg_cont_TC(:,3,count),'g--')
            plot(1:timef,alg_cont_TC(:,4,count),'m')
            %plot(1:25,alg_cont_TC(:,5,count),'--')
           % title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
            hold off
        % end
    end
    figure(2)
   title('Ev comparison')
    for count = 1:N
         %for k =1:nalgs+1            
            subplot(2,4,count)
            hold on
            plot(1:timef,alg_cont_Ev(:,1,count),'r')
            plot(1:timef,alg_cont_Ev(:,2,count),'b')
            plot(1:timef,alg_cont_Ev(:,3,count),'g--')
            plot(1:timef,alg_cont_Ev(:,4,count),'m')
            %plot(1:25,alg_cont_TC(:,5,count),'--')
           % title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
            hold off
        % end
    end
   figure(3)
   title('SV comparison')
    for count = 1:N
         %for k =1:nalgs+1            
            subplot(2,4,count)
            hold on
            plot(1:timef,alg_cont_SV(:,1,count),'r')
            plot(1:timef,alg_cont_SV(:,2,count),'b')
            plot(1:timef,alg_cont_SV(:,3,count),'g--')
            plot(1:timef,alg_cont_SV(:,4,count),'m')
            %plot(1:25,alg_cont_TC(:,5,count),'--')
           % title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
            hold off
        % end
    end
       figure(4)
   title('Ju comparison')
    for count = 1:N
         %for k =1:nalgs+1            
            subplot(2,4,count)
            hold on
            plot(1:timef,alg_cont_Ju(:,1,count),'r')
            plot(1:timef,alg_cont_Ju(:,2,count),'b')
            plot(1:timef,alg_cont_Ju(:,3,count),'g--')
            plot(1:timef,alg_cont_Ju(:,4,count),'m')
            %plot(1:25,alg_cont_TC(:,5,count),'--')
           % title(sprintf('(%1.4f, %1.3f, %1.0f, %2.0f, %1.3f)',IT.Seed1(count),IT.Seed2(count),IT.SRM(count),IT.Aadpt(count),IT.Natad(count)));
            hold off
        % end
    end
else
   
        %% Generate monte carlo samples
        num_reps = 25;  % Number of replicate RCP scenarios
        % timesteps, n_algs, n_scenarios, n_metrics
        results = zeros(timef, nalgs+1, N,nmetrics);
        ai = ADRIA();
        
        % Collect details of available parameters
        combined_opts = ai.parameterDetails();
        % Get default parameters
        ai.constants.tf = timef;
        ai.constants.nsiteint = 15;
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
        ai.loadConnectivity('./Inputs/Moore/connectivity/2015/moore_d2_2015_transfer_probability_matrix_wide.csv',cutoff=0.1);
                
        ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);
        
        ai.loadDHWData(sprintf('./Inputs/Moore/DHWs/dhwRCP%2.0f.mat',ai.constants.RCP), num_reps); 
        %% Scenario runs
        % set all criteria weights and seed yrs/ shade yrs to be the same
         p_sel.Seedyrs(:) = 10*ones(length(p_sel.Seedyrs(:)),1);
         p_sel.Shadeyrs(:) = ones(length(p_sel.Shadeyrs(:)),1);
         p_sel.coral_cover_high(:) = ones(length(p_sel.coral_cover_high(:)),1);
         p_sel.coral_cover_low(:) = ones(length(p_sel.coral_cover_low(:)),1);
         p_sel.wave_stress(:) = ones(length(p_sel.wave_stress(:)),1);
         p_sel.heat_stress(:) = ones(length(p_sel.heat_stress(:)),1);
         p_sel.shade_connectivity(:) = ones(length(p_sel.shade_connectivity(:)),1);
         p_sel.seed_connectivity(:) = ones(length(p_sel.seed_connectivity(:)),1);
         p_sel.shade_priority(:) = ones(length(p_sel.shade_priority(:)),1);
         p_sel.seed_priority(:) = ones(length(p_sel.seed_priority(:)),1);
         p_sel.SRM(:) = ones(length(p_sel.SRM(:)),1);
         p_sel.Aadpt(:) = 4*ones(N,1);
         p_sel.Natad(:) = 0.25*ones(N,1);
         p_sel.Seedfreq(:) = ones(length(p_sel.Seedfreq(:)),1);
         p_sel.Shadefreq(:) = ones(length(p_sel.Shadefreq(:)),1);
          p_sel.Seedyr_start(:) = 2*ones(length(p_sel.Seedyr_start(:)),1);
         p_sel.Shadeyr_start(:) = 2*ones(length(p_sel.Shadeyr_start(:)),1);
         p_sel.seed_priority(:) = ones(length(p_sel.seed_priority(:)),1);
        p_sel.deployed_coral_risk_tol(:) = ones(length(p_sel.deployed_coral_risk_tol(:)),1);

   for al = 0:nalgs
       % for each algorithm
        p_sel.Guided(:) = al*ones(length(p_sel.Guided(:)),1);
        tic
        Y = ai.run(p_sel,sampled_values = false, nreps = num_reps);
        tmp = toc;
        disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*num_reps), " simulations (", num2str(tmp/(N*num_reps)), " seconds per run)"))

        out = collectMetrics(Y.Y,coral_params,metric);
        TC = out.coralTaxaCover.total_cover;  
        Ev = out.coralEvenness;
        SV = out.shelterVolume;;
        Ju = out.coralTaxaCover.juveniles;
        results(:,al+1,:,1) = squeeze(mean(mean(TC,2),4));
        results(:,al+1,:,2) = squeeze(mean(mean(Ev,2),4)); 
        results(:,al+1,:,3) = squeeze(mean(mean(SV,2),4)); 
        results(:,al+1,:,4) = squeeze(mean(mean(Ju,2),4)); 
   end
    filenameTC='Inputs/MCDA_example_TC.nc';
    filenameEv='Inputs/MCDA_example_Ev.nc';
    filenameSV='Inputs/MCDA_example_SV.nc';
    filenameJu='Inputs/MCDA_example_Ju.nc';
    nccreate(filenameTC,'TC','Dimensions',{'time',timef,'algs',nalgs+1,'pars',N});
    ncwrite(filenameTC,'TC',results(:,:,:,1));
    nccreate(filenameEv,'Ev','Dimensions',{'time',timef,'algs',nalgs+1,'pars',N});
    ncwrite(filenameEv,'Ev',results(:,:,:,2));    
    nccreate(filenameSV,'SV','Dimensions',{'time',timef,'algs',nalgs+1,'pars',N});
    ncwrite(filenameSV,'SV',results(:,:,:,3));
    nccreate(filenameJu,'Ju','Dimensions',{'time',timef,'algs',nalgs+1,'pars',N});
    ncwrite(filenameJu,'Ju',results(:,:,:,4));
end

%% plotting comparisons
% each subplot is a randomised intervention scenario (row in the table IT)
% shows how average coral cover by year varies with site selection
% algorithm chosen
% the algorithm achieving the average highest coral cover for an individual
% scenario varies significantly, and hence should be probably be optimised
% for


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
