function base_cover = baseCoralNumbersFromCoversAllTaxa(target_covers)

% Produce conversion vectors from coral covers to initial coral size 
% distribution in ADRIA for corymbose Acropora and small massives.
% When converting from different covers at different sites to base numbers
% in ADRIA, the function assumes that the size distribution within each 
%  coral species remains constant  (need to update later). 

% Input (float): 
% - cover pair (proportions in row vector) for the two coral taxa.

% Size distribution of corals in 2026 per 100m2
nTabAcr_2026 = [100; 500; 50; 100; 25; 10];
nCorAcr_2026 = [100; 500; 50; 100; 25; 10];
nSmlMas_2026 = [1500; 650; 350; 350; 50; 1];
nLrgMas_2026 = [200; 300; 100; 100; 20; 5];


% From coralSpec but only for size classes
colony_diam_means_from = [1; 3.5; 7.5; 15; 30; 60];
colony_area_m2_from = pi .* ((colony_diam_means_from ./ 2).^2) ./ (10^4);

a_arena = 100.0; % m2 of reef arena where corals grow, survive and reproduce

cover_factor = colony_area_m2_from ./ a_arena;

%Calculate initial_cover based on IPMF initial coral numbers
coverTabAcr_2026 = nTabAcr_2026 .* cover_factor;
coverCorAcr_2026 = nCorAcr_2026 .* cover_factor;
coverSmlMas_2026 = nSmlMas_2026 .* cover_factor;
coverLrgMas_2026 = nLrgMas_2026 .* cover_factor;

totcoverTabAcr_2026 = sum(coverTabAcr_2026);
totcoverCorAcr_2026 = sum(coverCorAcr_2026);
totcoverSmlMas_2026 = sum(coverSmlMas_2026);
totcoverLrgMas_2026 = sum(coverLrgMas_2026);


% Conversion vectors from cover to size distribution
cov2n_TabAcr = totcoverTabAcr_2026 ./ nTabAcr_2026;
cov2n_CorAcr = totcoverCorAcr_2026 ./ nCorAcr_2026;
cov2n_SmlMas = totcoverSmlMas_2026 ./ nSmlMas_2026;
cov2n_LrgMas = totcoverLrgMas_2026 ./ nLrgMas_2026;

% Initial values for Corymbose Acropora and Small Massives
% all other coral types should be set to 0.
% (needs to be repeated for all sites)
conversion_vector = zeros(6, 6);
conversion_vector(:,2) = cov2n_TabAcr;
conversion_vector(:,4) = cov2n_CorAcr;
conversion_vector(:,5) = cov2n_SmlMas;
conversion_vector(:,6) = cov2n_LrgMas;

base_cover = ...
    [0, 0, 0, 0, 0, 0; ...           % Tabular Acropora Enhanced
     100, 500, 50, 100, 25, 10; ...  % Tabular Acropora Unenhanced
     0, 0, 0, 0, 0, 0; ...           % Corymbose Acropora Enhanced
     100, 500, 50, 100, 25, 10; ...  % Corymbose Acropora Unenhanced
     1500, 650, 350, 350, 50, 1; ... % small massives
     200, 300, 100, 100, 20, 5];      % large massives

com_and_small = (((target_covers / 100) ./ conversion_vector(:, 4:5)) .* cover_factor)';
tab_and_large = ((base_cover([2,6], :) / 100.0) ./ conversion_vector(:, [2,6])') .* cover_factor';

base_cover([4,5], :) = com_and_small;
base_cover([2,6], :) = tab_and_large;

assert(~all(any(isnan(base_cover))), "NaN found during conversion of coral numbers");

end