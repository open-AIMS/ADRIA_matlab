function Y = shelterVolumeADRIA(X, coral_params)
colony_diameter_edges = coral_params.size_cm(1:6); 
colony_diameter_edges_to = [colony_diameter_edges(2:end),120];
colony_diameter_means_to = colony_diameter_edges + (colony_diameter_edges_to - ...
                            colony_diameter_edges)/2;

colony_areas = pi*((0.5*colony_diameter_means_to).^2); %colony diameter converted to planar areas (cm2)
sheltervolume_parameters = ...
        [-8.32, 1.50; %tabular from Urbina-Barretto 2021 
        -8.32, 1.50; %tabular from Urbina-Barretto 2021
        -7.37, 1.34; %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora 
        -7.37, 1.34; %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora 
        -9.69, 1.49; %massive from Urbina-Barretto 2021, assumed similar for encrusting and small massives 
        -9.69, 1.49]; %massive from Urbina-Barretto 2021,  assumed similar for large massives

    ncoralgroups = size(X.all,1)/6;
    nsizeclasses = size(X.all,1)/6;
    
    logcolony_sheltervolume = zeros(ncoralgroups, nsizeclasses);
for sp = 1:ncoralgroups
    for size_bin = 1:nsizeclasses
        logcolony_sheltervolume(sp,size_bin) = sheltervolume_parameters(sp,1) + sheltervolume_parameters(sp,2)*log(colony_area(size_bin)); %shelter volume in dm3
    end
end

shelter_volume = zeros(X.NREEFS, X.NYEARS, X.NCORALGROUPS, X.NCORALSIZEBINS);
for site = 1:26
    for sp = 6
        for t = 25
            for size_bin = 1:X.NCORALSIZEBINS
shelter_volume(reef,t,sp,size_bin) = (exp(logcolony_sheltervolume(sp,size_bin))).*X.coralNumbers(reef,t,sp,size_bin); % shelter volume converted from log and dm to m3

            end
        end
    end
end    
Y = squeeze(sum(shelter_volume,3:4))./1000; %sum over species and size bins and convert to m3
end


