function store_mat = BBN_Compatible_Table_Func(params,t_s,RCPs,algs, N_sims)
% RC 2021
% Uses output files 'Results(RCP)_alg(alg_ind).mat from runADRIAmain.mlx'
% to generate a suitable excel file structure to be transformed into a txt
% file for Netica BBN generation

% params is a N by 1 cell structure with the following matrix cells in order
% N is total no. of params

% List of nodes that could be included in the BBN/ parameters  
%   Guided - 0 for unguided intervention, 1 for guided
%   PrSites - 1,2 or 3 for selection of site to intervene on
%   Seed1, Seed2 - seeding scenarios for 2 coral types
%   SRM - Shading levels
%   Aadpt - Assisted adaptation levels
%   Natad - Natural adaptatio levels
%   Ndeplys - number of deployments used 
%   MA - 1,2 for Blue and Green management areas
%   RD_ass - 1,2,3,4 for A,B,C,D R&D assumptions

%  t_s - time slice size to analyse (scalar)

%  RCPs - one or more of 26,60,85 separated by commas in a matrix
%       (each of these .mat files should exist in the specified file path)
%  alg - one or more of 1,2,3 separated by commas in a matrix
%  nsims - no. of simulations used

%  TC - total coral cover (which is averaged over sites currently)
%  CultES - cultural ES
%  ProvES - provisional ES
%  dCultES - cultural ES, difference to counter-factual
%  dProvES -  provisional ES, difference to counter-factual
    
% Number of variables to be compared in the table to put in Netica
% Order is RCP, alg, years, sites,  guided, prsites, seed1, seed2, SRM, assist. adapt.,
% nat. adapt., Ndeplys, MA, RD_ass, coral cover, CultrES, ProvES 

    % total no. of columns in data table
    n_var = size(params,1) + 7; % + RCP,alg, years, sites, CC,C_ES and P_ES
    
    n = zeros(n_var-7,1);
    N_perm = 1;
    % number of parameters
    for l = 1:length(n)
        n(l) = numel(params{l});
        % number of parameter permutations
        N_perm  = N_perm*n(l);
    end
    % timeslice and time vectors
    Time_slices = t_s:t_s:50;
    N_time = size(Time_slices,2); % no. of time slices
    
    % sites vector
    Sites = 1:26;
    N_sites = size(Sites,2);
    
    % number of variable permutations (excluding no. of
    % simulations which is captured in the .mat file)
    %n_g*n_pr*n_s1*n_s2*n_srm*n_apt*n_nat*n_deply*n_ma*n_rd
    N_perm = N_perm*N_time*N_sites*N_sims;
    
    % number of parameter perms for individual params            
     N = zeros(n_var-4,1);
     N(1) = N_perm;
     N(2) =  N(1)/N_time;
     N(3) =  N(2)/N_sites;
     for h = 4:size(N,1)
          N(h) = N(h-1)/n(h-3);
     end

    
    store_mat = [];
    for j = 1:length(RCPs)
        for k = 1:length(algs)
            % Load results matrix
            Data = load(strcat('Results',num2str(RCPs(j)),'_alg',num2str(algs(k)),'.mat'));
            TC_temp = Data.TC;
            % Compute ES services translation
            ES = Corals_to_Ecosys_Services(Data);
            CultES = ES.CultES;
            ProvES = ES.ProvES;
%             CultES_temp = squeeze(mean(CultES,2));
%             ProvES_temp = squeeze(mean(ProvES,2));
            CultES_temp = CultES(Time_slices,:,:,:);
            ProvES_temp = ProvES(Time_slices,:,:,:);
            
            % average total coral over coral sites and extract time slices of interest
            %TC_temp = squeeze(mean(Data.TC,2)); 
            TC_temp(TC_temp>1) = 1;  %forcing outputs below 1 (100%)  - needs fixing in the code
            TC_temp = TC_temp(Time_slices,:,:,:);
         
            % fill variables in correct permutation order
            temp_mat = nan(N(1),n_var);
            temp_mat(:,1) = repmat(RCPs(j),N(1),1);
            temp_mat(:,2) = repmat(algs(k),N(1),1);
            temp_mat(:,3) = reshape(repmat(Time_slices,N(2),1),N(1),N(1)/(N(2)*N_time));
            temp_mat(:,4) = reshape(repmat(Sites,N(3),N(1)/(N(3)*N_sites)),N(1),1);
            for m = 5: n_var-3
                 temp_mat(:,m) = reshape(repmat(params{m-4},N(m-1),N(1)/(n(m-4)*N(m-1))),N(1),1);
            end


            % We want time, parameters, sims order of stacking but this is not how
            % reshape automatically makes column vectors (it stacks from last
            % dim to first dim). So need to stack separately to match table.
            store_col1 = [];
            store_col2 = [];
            store_col3 = [];
            for t = 1:N_time
                for l = 1:N_sites
                    for nn = 1:(N_perm/(N_time*N_sites*N_sims))
                        % for each time select all sims for first to last
                        % parameter permutation, stack as columns in order (t1:
                        % p1 to pN) to (tK: p1 to pN).
                        store_col1 = [store_col1;squeeze(TC_temp(t,l,nn,:))];
                        store_col2 = [store_col2;squeeze(CultES_temp(t,l,nn,:))];
                        store_col3 = [store_col3;squeeze(ProvES_temp(t,l,nn,:))];
                    end
                end
            end

            % Then stack as single columns
            temp_mat(:,end-2) = store_col1;
            temp_mat(:,end-1) = store_col2;
            temp_mat(:,end) = store_col3;
            store_mat = [store_mat;temp_mat];
        end

    end
    
    table_to_save = array2table(store_mat,'VariableNames',{'RCP','MCDAAlgs','Years','Sites',...
        'Guided','PrSites','Seed1','Seed2','SRM','AssistedAdapt','NaturalAdapt','CoralCover','CultES','ProvES'});
    filename1 = 'ADRIA_BBN_Data.csv';
    writetable(table_to_save,filename1);
    % ,'NdeploymentSites', ...
       % 'ManagementArea','RnD_Assumptions',
    
end

