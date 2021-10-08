function store_mat = BBN_Compatible_Table_Func(Guided,PrSites,Seed1,Seed2,SRM,Aadpt,Natad,t_s,RCPs)
% RC 2021
% Uses output files 'Results(RCP).mat from runADRIAmain.mlx'
% to generate a suitable excel file structure to be transformed into a txt
% file for Netica BBN generation

% List of nodes that could be included in the BBN/ parameters to select (entered as parameter vectors)
%   Guided - 0 for unguided intervention, 1 for guided
%   PrSites - 1,2 or 3 for selection of site to intervene on
%   Seed1,Seed2 - seeding scenarios for 2 coral types
%   SRM - Shading levels
%   Aadpt - Assisted adaptation levels
%   Natad - Natural adaptatio levels
%   t_s - time slice size to analyse 
%   RCPs- user will enter as one or more of 26,60,85 separated by commas
%       (each of these .mat files should exist in the specified file path)

% cd to location of output files
    cd '/Users/rosecrocker/Documents/AIMS/1_ADRIA_9Aug21/ADRIAmain_scripts'

% can uncomment to use input table instead of func args
%     Nodes_to_include = {'Informed vs. Uninformed: (0,1):','Sites Prioritised (1,2,3):',...
%     'Seeding group 1 coral (%cover):','Seeding group 2 coral (%cover):','Cooling and Shading (DHW):',...
%     'Assisted Adaptation (DHW):','Natural Adaptation (DHW):','Time slice length (yrs):'...
%     'RCPs (26,60,85,6085):'};
%     title = 'Nodes/Scenarios to include in BBN (need to match files generated by runADRIAmain)';
%     definput = {'1','3','0.0000,0.0010','0.0000,0.0010','0,5','6,12','0','10','26,60,85'};
%     dims = [1 50];
%     answer = inputdlg(Nodes_to_include,title,dims,definput, "off");
%     Guided = str2num(answer{1}); % indicates whether deployment is guided (1) or unguided (0), or both (0,1)
%     PrSites = str2num(answer{2}); % group indicator for priority sites - 1,2 or 3
%     Seed1 = str2num(answer{3}); % seed Acropora - can be for different levels, see area calculations
%     Seed2 = str2num(answer{4});  % seed other corals - can be for different levels, see area calculations
%     SRM = str2num(answer{5}); % shade at one or different levels - unit is DHW 
%     Aadpt = str2num(answer{6}); % one or more levels of assisted adaptation - unit is DHW
%     Natad = str2num(answer{7}); % one or more levels of natural adaptation - unit is DHW per year
%     t_s  = str2num(answer{8}); % time slice length years
%     RCPs  = str2num(answer{9}); % RCP scenarios to compare

    % number of parameters
    n_g = numel(Guided);   
    n_pr = numel(PrSites);
    n_s1 = numel(Seed1);
    n_s2 = numel(Seed2);
    n_srm = numel(SRM);
    n_apt = numel(Aadpt);
    n_nat = numel(Natad);
   
    % Number of variables to be compared in the table to put in Netica
    % Order is years, RCP, guided, prsites, seed1, seed2, SRM, 
    % assist. adapt., nat. adapt.,coral cover (total cover output from ADIRA)
    n_var = 10; 
    st_year = 2025; % start year
    
    % timeslice and time vectors
    Time_slices = t_s:t_s:50;
    N_time = size(Time_slices,2); % no. of time slices
    
    % number of variable permutations (excluding no. of
    % simulations which is captured in the .mat file)
    N_perm = n_g*n_pr*n_s1*n_s2*n_srm*n_apt*n_nat*N_time;
    
    store_mat = [];
    for n = 1:length(RCPs)
        % Load results matrix
        Data = load(strcat('Results',num2str(RCPs(n)),'.mat'));
        N_sims = size(Data.TC,4); % no. of simulations

        % average total coral over coral sites and extract time slices of interest
        TC_temp = squeeze(mean(Data.TC,2)); 
        TC_temp(TC_temp>1) = 1;  %forcing outputs below 1 (100%)  - needs fixing in the code
        TC_temp = TC_temp(Time_slices,:,:,:);

        % number of parameter perms
        N = N_sims*N_perm; % *2 or *N_sites if we want to split sites into groups
        N_t = N/N_time;
        N_g = N_t/n_g;
        N_pr = N_g/n_pr;
        N_s1 = N_pr/n_s1;
        N_s2 = N_s1/n_s2;
        N_srm = N_s2/n_srm;
        N_apt = N_srm/n_apt;
        N_nat = N_apt/n_nat;

        % fill variables in correct permutation order
        temp_mat = nan(N,n_var);
        temp_mat(:,1) = repmat(RCPs(n),N,1);
        temp_mat(:,2) = reshape(repmat(Time_slices,N_t,1),N,N/(N_t*N_time));
        temp_mat(:,3) = reshape(repmat(Guided,N_g,N/(n_g*N_g)),N,1);
        temp_mat(:,4) = reshape(repmat(PrSites,N_pr,N/(n_pr*N_pr)),N,1);
        temp_mat(:,5) = reshape(repmat(Seed1,N_s1,N/(n_s1*N_s1)),N,1);
        temp_mat(:,6) = reshape(repmat(Seed2,N_s2,N/(n_s2*N_s2)),N,1);
        temp_mat(:,7) = reshape(repmat(SRM,N_srm,N/(n_srm*N_srm)),N,1);
        temp_mat(:,8) = reshape(repmat(Aadpt,N_apt,N/(n_apt*N_apt)),N,1);
        temp_mat(:,9) = reshape(repmat(Natad,N_nat,N/(n_nat*N_nat)),N,1);
        
        % We want time, parameters, sims order of stacking but this is not how
        % reshape automatically makes column vectors (it stacks from last
        % dim to first dim). So need to stack separately to match table.
        store_col = [];
        for t = 1:N_time
            for k = 1:(N_perm/N_time)
                % for each time select all sims for first to last
                % parameter permutation, stack as columns in order (t1:
                % p1 to pN) to (tK: p1 to pN).
                store_col = [store_col;squeeze(TC_temp(t,k,:))];
            end
        end
        
        % Then stack as a single column
        temp_mat(:,10) = store_col;
        store_mat = [store_mat;temp_mat];

    end
    
    table_to_save = array2table(store_mat,'VariableNames',{'RCP','Years',...
        'Guided','PrSites','Seed1','Seed2','SRM','AssistedAdapt','NaturalAdapt','CoralCover'});
    filename1 = 'ADRIA_BBN_Data.xlsx';
    writetable(table_to_save,filename1,'Sheet',1);
    
end