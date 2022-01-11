function Y = shelterVolume(X, coral_params)

% Calculates evenness across functional coral groups in ADRIA

% Inputs: 
% results from@coralScenarioarray, array. Dimensions: time, species, sites, interventions, sims 
% coralParams, structure

% Coral sizes and parameters needed to convert size to colony shelter volume  
colony_area_cm2 = coral_params.colony_area_cm2;
sheltervolume_parameters = ...
        [-8.32, 1.50; %tabular from Urbina-Barretto 2021 
        -8.32, 1.50; %tabular from Urbina-Barretto 2021
        -7.37, 1.34; %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora 
        -7.37, 1.34; %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora 
        -9.69, 1.49; %massives from Urbina-Barretto 2021, assumed similar for encrusting and small massives 
        -9.69, 1.49]; %massives from Urbina-Barretto 2021,  assumed similar for large massives

% Extend to array for all groups and sizes 
sheltervolume_parameters = repelem(sheltervolume_parameters, 6,1);
    
    nspecies = size(X,2);
    ncoralgroups = nspecies/6;
    nsizeclasses = size(X,2)/6;
    ntsteps = size(X,1);
    nsites = size(X,3);

% Estimate log colony volume (litres) based on relationship 
% established by Urbina-Barretto 2021
logcolony_sheltervolume = sheltervolume_parameters(:,1) + ... 
        sheltervolume_parameters(:,2).*log10(colony_area_cm2);

%shelter_volume_colony_litres_per_cm2 = (exp(logcolony_sheltervolume));
shelter_volume_colony_litres_per_cm2 = (10.^(logcolony_sheltervolume));

% convert from litres per cm2 to m3 per ha
shelter_volume_colony_m3_per_ha = shelter_volume_colony_litres_per_cm2 * ...
                (10^-3) * 10^4 *10^4; 

%calculate shelter volume of groups and size classes and multiply with covers
sv = zeros(ntsteps, nspecies, nsites);
for sp = 1:36
    sv(:,sp,:) = shelter_volume_colony_m3_per_ha(sp).*X(:,sp,:);
end
%sum over groups and size classes to estimate total shelter volume per ha
Y = squeeze(sum(sv,2));
end


