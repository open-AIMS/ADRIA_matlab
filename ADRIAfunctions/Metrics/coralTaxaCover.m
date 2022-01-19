function Y = coralTaxaCover(X, ~)
% Converts outputs from coralScenario to relative cover of the four different coral taxa
%
%
% Input: 
%   X : array, of coralScenario results
%       Dimensions: time, species, sites, interventions, sims
% Output:
%   Y : struct, of matrices

%% Total coral cover (relative)
TC = squeeze(sum(X,2)); %sum over all species and size classes

C1 = X(:,coralTaxaIndex(1),:,:,:) + X(:,coralTaxaIndex(2),:,:,:);  % enhanced to unenhanced tabular Acropora
C2 = X(:,coralTaxaIndex(3),:,:,:) + X(:,coralTaxaIndex(4),:,:,:); % enhanced to unenhanced corymbose Acropora 
C3 = X(:,coralTaxaIndex(5),:,:,:);  % Encrusting and small massives 
C4 = X(:,coralTaxaIndex(6),:,:,:);  % Large massives 

%% Cover of juvenile corals (< 5cm diameter)
juv_groups = X(:, coralClassIndex(1), :, :, :) + X(:, coralClassIndex(2), :, :, :);
juv_all = squeeze(sum(juv_groups,2));

large_corals = X(:, coralClassIndex(5), :, :, :) + X(:, coralClassIndex(6), :, :, :); 
large_all = squeeze(sum(large_corals,2));

Y.total_cover = TC;
Y.tab_acr = C1;
Y.cor_acr = C2;
Y.sml_enc = C3;
Y.lrg_mas = C4;
Y.juveniles = juv_all;
Y.large = large_all;
end
