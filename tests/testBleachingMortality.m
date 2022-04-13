tstep = 2;
neg_e_p1 = -6;
neg_e_p2 = -0.4;
assistadapt = zeros(36, 1);
assistadapt(1:6) = 6;
assistadapt(13:18) = 6;

natad = zeros(36, 1);
natad(:) = 0.05;

bleach_resist = zeros(36, 1);
bleach_resist(25:30) = 1.5;
bleach_resist(31:36) = 1.0;
adjusted_dhw = [2.3331, 1.9367, 0, 1.4349, 1.6578, 4.0865, 3.4649, ...
                4.0029, 0, 3.9902, 0, 3.1109, 3.5390, 3.7092, 3.4628, ...
                4.7154, 4.4475, 0, 4.0330, 4.0390, 4.2792, 4.3592, ...
                3.6215, 3.6026, 0, 3.4624];
fogging = 0.0;

bleach_mort = ADRIA_bleachingMortality(tstep, neg_e_p1, ...
                                       neg_e_p2, assistadapt, ...
                                       natad, bleach_resist, adjusted_dhw, fogging);

% Check that bleaching mortality values are roughly in line with known
% result
assert(all(ismembertol(bleach_mort(1:6,1), 0.0025, 0.009)), "Deviation from known result!")
assert(all(ismembertol(bleach_mort(13:18,1), 0.0025, 0.009)), "Deviation from known result!")
