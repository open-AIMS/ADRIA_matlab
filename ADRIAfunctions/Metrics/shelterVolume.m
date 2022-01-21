function Y = shelterVolume(X, coral_params)
% Indicator of shelter capacity

% Inputs: 
%   X            : matrix, raw ADRIA results for a single simulation
%                  Dimensions: time, species, sites, interventions, sims 
%   coral_params : table, of coral parameters used for the given simulation

% Coral sizes and parameters needed to convert size to colony shelter volume  
var_names = coral_params.Properties.VariableNames;
colony_area_cm2 = coral_params{:, contains(var_names, "colony_area_cm2")}';

% Get unique coral names to determine number of corals
tmp = split(string(coral_params.Properties.VariableNames)', "__");
tmp = regexp(tmp(:, 1), "\_[0-9]", "split", "once");
tmp = vertcat(tmp{:, 1});
coral_names = unique(vertcat(tmp(:, 1)));
n_corals = length(coral_names);

sheltervolume_parameters = ...
        [-8.32, 1.50; %tabular from Urbina-Barretto 2021 
        -8.32, 1.50; %tabular from Urbina-Barretto 2021
        -7.37, 1.34; %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora 
        -7.37, 1.34; %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora 
        -9.69, 1.49; %massives from Urbina-Barretto 2021, assumed similar for encrusting and small massives 
        -9.69, 1.49]; %massives from Urbina-Barretto 2021,  assumed similar for large massives

% Extend to array for all groups and sizes 
sheltervolume_parameters = repelem(sheltervolume_parameters, n_corals, 1);

[ntsteps, nspecies, nsites] = size(X);

% Estimate log colony volume (litres) based on relationship 
% established by Urbina-Barretto 2021
logcolony_sheltervolume = sheltervolume_parameters(:,1) + sheltervolume_parameters(:,2) .* log10(colony_area_cm2);

%shelter_volume_colony_litres_per_cm2 = (exp(logcolony_sheltervolume));
shelter_volume_colony_litres_per_cm2 = (10.^(logcolony_sheltervolume));

% convert from litres per cm2 to m3 per ha
shelter_volume_colony_m3_per_ha = shelter_volume_colony_litres_per_cm2 * ...
                (10^-3) * 10^4 *10^4; 

% calculate shelter volume of groups and size classes and multiply with covers
sv = zeros(ntsteps, nspecies, nsites);
for sp = 1:36
    sv(:,sp,:) = shelter_volume_colony_m3_per_ha(sp).*X(:,sp,:);
end

% sum over groups and size classes to estimate total shelter volume per ha
Y = squeeze(sum(sv,2));
end


