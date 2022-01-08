function Y = shelterVolumeADRIA(covers, coral_params)
%Inputs:  X.all; array, Dimensions: time, species, sites, interventions, sims 
%  covers: structure
%  covers.all: array.     Dims: timesteps, species, sites, interventions, sims 
%  covers.tab_acr: array. Dims: timesteps, sizes, sites, interventions, sims 
%  covers.cor_acr: array. Dims: timesteps, sizes, sites, interventions, sims 
%  covers.sml_enc: array. Dims: timesteps, sizes, sites, interventions, sims 
%  covers.lrg_mas: array. Dims: timesteps, sizes, sites, interventions, sims
%  covers.TC = TC; array. Dims: timesteps, sizes, sites, interventions, sims 

% Calculates evenness across functional coral groups in ADRIA
colony_diameter_edges = coral_params.size_cm(1:6); 
colony_diameter_edges_to = [colony_diameter_edges(2:end);120]; %column vector
colony_diameter_means_to = colony_diameter_edges + (colony_diameter_edges_to - ...
                            colony_diameter_edges)/2;
% colony diameter converted to planar areas (cm2)
colony_areas_cm2 = pi*((0.5*colony_diameter_means_to).^2);
%extend to column vector for all groups and sizes 
colony_areas_cm2 = repmat(colony_areas_cm2, 6,1);   

sheltervolume_parameters = ...
        [-8.32, 1.50; %tabular from Urbina-Barretto 2021 
        -8.32, 1.50; %tabular from Urbina-Barretto 2021
        -7.37, 1.34; %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora 
        -7.37, 1.34; %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora 
        -9.69, 1.49; %massives from Urbina-Barretto 2021, assumed similar for encrusting and small massives 
        -9.69, 1.49]; %massives from Urbina-Barretto 2021,  assumed similar for large massives

% Extend to array for all groups and sizes 
sheltervolume_parameters = repelem(sheltervolume_parameters, 6,1);
    
    nspecies = size(covers.all,2);
    ncoralgroups = nspecies/6;
    nsizeclasses = size(covers.tab_acr,2);
    ntsteps = size(covers.all,1);
    nsites = size(covers.all,3);

% Estimate log (natural) colony volume (litres) based on relationship 
% established by Urbina-Barretto 2021
logcolony_sheltervolume = sheltervolume_parameters(:,1) + ... 
        sheltervolume_parameters(:,2).*log10(colony_areas_cm2);

%shelter_volume_colony_litres_per_cm2 = (exp(logcolony_sheltervolume));
shelter_volume_colony_litres_per_cm2 = (10.^(logcolony_sheltervolume));

% convert from litres per cm2 to m3 per ha
shelter_volume_colony_m3_per_ha = shelter_volume_colony_litres_per_cm2 * ...
                (10^-3) * 10^4 *10^4; 

%calculate shelter volume of groups and size classes and multiply with covers
sv = zeros(ntsteps, nspecies, nsites);
for sp = 1:36
    sv(:,sp,:) = shelter_volume_colony_m3_per_ha(sp).*covers.all(:,sp,:);
end
%sum over groups and size classes to estimate total shelter volume per ha
Y = squeeze(sum(sv,2));
end


