function [conversion_vector, base_covers]  = baseCoralNumbersFromCovers(target_covers)

% Produce conversion vectors from coral covers to initial coral size 
% distribution in ADRIA for corymbose Acropora and small massives.
% When converting from different covers at different sites to base numbers
% in ADRIA, the function assumes that the size distribution within each 
%  coral species remains constant  (need to update later). 

% Input (float): 
% - cover pair (proportions in row vector) for the two coral taxa.

% Size distribution of IPMF corals in 2026 per 100m2
nIPMF_CorAcr_2026 = [200; 1000; 100; 200; 45; 20];
nIPMF_SmlMas_2026 = [1500; 650; 350; 350; 50; 1];

% From coralSpec but only for size classes
colony_diam_means_from = [1; 3.5; 7.5; 15; 30; 60];
colony_area_m2_from = pi .* ((colony_diam_means_from ./ 2).^2) ./ (10^4);

a_arena = 100; % m2 of reef arena where corals grow, survive and reproduce

%Calculate initial_cover based on IPMF initial coral numbers
coverIPMF_CorAcr_2026 = nIPMF_CorAcr_2026 .* colony_area_m2_from ./ a_arena;
coverIPMF_SmlMas_2026 = nIPMF_SmlMas_2026 .* colony_area_m2_from ./ a_arena;

totcoverIPMF_CorAcr_2026 = sum(coverIPMF_CorAcr_2026);
totcoverIPMF_SmlMas_2026 = sum(coverIPMF_SmlMas_2026);

%Conversion vectors from cover to size distribution
cov2n_CorAcr = totcoverIPMF_CorAcr_2026 ./ nIPMF_CorAcr_2026;
cov2n_SmlMas = totcoverIPMF_SmlMas_2026 ./ nIPMF_SmlMas_2026;

conversion_vector(:,1) = cov2n_CorAcr;
conversion_vector(:,2) = cov2n_SmlMas;

base_covers = target_covers./ conversion_vector;
end