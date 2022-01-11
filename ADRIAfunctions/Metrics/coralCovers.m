function Y = coralCovers(X,taxa_id)
%
% Converts outputs from coralScenario to relative cover of the four different coral taxa 
% Input: coralScenario results, array. Dimensions: time, species, sites, interventions, sims 

%% Total coral cover (relative)
TC = squeeze(sum(X,2)); %sum over all species and size classes

%% Preliminary estimates using only three species 
% 1: Total coral cover (relative)
% 
TC = squeeze(sum(X,2)); %sum over all species and size classes

C1 = X(:,taxaIndex(1,taxa_id),:,:,:)+X(:,taxaIndex(2,taxa_id),:,:,:);
%X(:,1:6,:,:,:) + X(:,7:12,:,:,:); %Adding enhanced to unenhanced tabular Acropora
C2 = X(:,taxaIndex(3,taxa_id),:,:,:) + X(:,taxaIndex(4,taxa_id),:,:,:);
%X(:,13:18,:,:,:) + X(:,19:24,:,:,:); %Adding %enhanced to unenhanced corymbose Acropora 
C3 = X(:,taxaIndex(5,taxa_id),:,:,:);
%X(:,25:30,:,:,:); %Encrusting and small massives 
C4 = X(:,taxaIndex(6,taxa_id),:,:,:);
%X(:,31:36,:,:,:); %Large massives 

%% Cover of juvenile corals (< 5cm diameter)
juv_groups = X(:, 1:6:end, :, :, :) + X(:, 2:6:end, :, :, :);
juv_all = squeeze(sum(juv_groups,2));


large_corals = X(:, 5:6:end, :, :, :) + X(:, 6:6:end, :, :, :); 
large_all = squeeze(sum(large_corals,2));

Y.total_cover = TC;
Y.tab_acr = C1;
Y.cor_acr = C2;
Y.sml_enc = C3;
Y.lrg_mas = C4;
Y.juveniles = juv_all;
Y.large = large_all;
end
