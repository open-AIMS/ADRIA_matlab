function Y = shelterVolumeFromReefmod(X)
colony_diameter = [0.5:1:16.5, 22, 32, 42, 52, 62, 72, 82, 92, 99]; %from ReefMod documentation
colony_area = ((0.5 * colony_diameter).^2) * pi; %colony diameter converted to planar areas (cm2)
sheltervolume_parameters = [-8.31, 1.47; ... %branching from Urbina-Barretto 2021
    -8.32, 1.50; ... %tabular from Urbina-Barretto 2021
    -7.37, 1.34; ... %columnar from Urbina-Barretto 2021, assumed similar for corymbose Acropora
    -7.37, 1.34; ... %columnar from Urbina-Barretto 2021, assumed similar for corymbose non-Acropora
    -9.69, 1.49; ... %massive from Urbina-Barretto 2021, assumed similar for encrusting and small massives
    -9.69, 1.49];    %massive from Urbina-Barretto 2021,  assumed similar for large massives
logcolony_sheltervolume = zeros(X.NCORALGROUPS, X.NCORALSIZEBINS);
for sp = 1:X.NCORALGROUPS
    for size_bin = 1:X.NCORALSIZEBINS
        logcolony_sheltervolume(sp, size_bin) = sheltervolume_parameters(sp, 1) + sheltervolume_parameters(sp, 2) * log(colony_area(size_bin)); %shelter volume in dm3
    end
end

shelter_volume = zeros(X.NREEFS, X.NYEARS, X.NCORALGROUPS, X.NCORALSIZEBINS);
for reef = 1:X.NREEFS
    for t = 1:X.NYEARS
        for sp = 1:X.NCORALGROUPS
            for size_bin = 1:X.NCORALSIZEBINS
                shelter_volume(reef, t, sp, size_bin) = (exp(logcolony_sheltervolume(sp, size_bin))) .* X.coralNumbers(reef, t, sp, size_bin); % shelter volume converted from log and dm to m3
            end
        end
    end
end

%sum over species and size bins and convert to m3
Y = squeeze(sum(shelter_volume, 3:4)) ./ 1000;
end
