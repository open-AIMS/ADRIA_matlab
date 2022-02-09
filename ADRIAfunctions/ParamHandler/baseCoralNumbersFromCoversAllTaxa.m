function base_cover = baseCoralNumbersFromCoversAllTaxa(target_covers)

% Produce conversion vectors from coral covers to initial coral size 
% distribution in ADRIA for corymbose Acropora and small massives.
% When converting from different covers at different sites to base numbers
% in ADRIA, the function assumes that the size distribution within each 
%  coral species remains constant  (need to update later). 

% Input (float): 
% - cover pair (percentages in row vector) for the two coral taxa used by IPMF.

% Size distribution of IPMF corals in 2026 per 100m2
nIPMF_CorAcr_2026 = [200; 1000; 100; 50; 20; 10];
nIPMF_SmlMas_2026 = [1500; 650; 350; 20; 5; 1];
nLrgMas_2026 =  [200, 300, 100, 100, 20, 5]; 

% From coralSpec but only for size classes
colony_diam_means_from = [1; 3.5; 7.5; 15; 30; 60];
colony_area_m2_from = pi .* ((colony_diam_means_from ./ 2).^2) ./ (10^4);

a_arena = 100; % m2 of reef arena where corals grow, survive and reproduce

cover_factor = colony_area_m2_from ./ a_arena;

%Calculate initial_cover based on IPMF initial coral numbers
coverIPMF_CorAcr_2026 = nIPMF_CorAcr_2026 .* cover_factor;
coverIPMF_SmlMas_2026 = nIPMF_SmlMas_2026 .* cover_factor;
coverLrgMas_2026 = nLrgMas_2026 .* cover_factor;


totcoverIPMF_CorAcr_2026 = sum(coverIPMF_CorAcr_2026);
totcoverIPMF_SmlMas_2026 = sum(coverIPMF_SmlMas_2026);
totcoverLrgMas_2026 = sum(coverLrgMas_2026);


%Conversion vectors from cover to size distribution
cov2n_CorAcr = totcoverIPMF_CorAcr_2026 ./ nIPMF_CorAcr_2026;
cov2n_SmlMas = totcoverIPMF_SmlMas_2026 ./ nIPMF_SmlMas_2026;
cov2n_LrgMas = totcoverLrgMas_2026 ./ nLrgMas_2026;


% Initial values for Corymbose Acropora and Small Massives
% all other coral types should be set to 0.
% (needs to be repeated for all sites)

conversion_vector = zeros(6,6);
conversion_vector(:,1) = 0; %Enhanced Tab Acropora are zero at start
conversion_vector(:,2) = cov2n_CorAcr*2; %Half of IPMF's Acroporas are Tabular 
conversion_vector(:,3) = 0; %Enhanced Cor Acropora are zero at start
conversion_vector(:,4) = cov2n_CorAcr*2; %Half of IPMF's Acroporas are Corymbose
conversion_vector(:,5) = cov2n_SmlMas; %Keep as is
conversion_vector(:,6) = cov2n_LrgMas; %New


base_cover(1,:) = zeros(1,6);
base_cover(2,:) = ((target_covers(1) / 100) ./ conversion_vector(:,2) .* cover_factor)';
base_cover(3,:) = zeros(1,6);
base_cover(4,:) = ((target_covers(1) / 100) ./ conversion_vector(:,4) .* cover_factor)';
base_cover(5,:) = ((target_covers(2) / 100) ./ conversion_vector(:,5) .* cover_factor)';

% Preliminarily set start cover for Large Massive to 5 percent
base_cover(6,:) = ((5.0 / 100.0) ./ conversion_vector(:,6) .* cover_factor)';


assert(~all(any(isnan(base_cover))), "NaN found during conversion of coral numbers");


end