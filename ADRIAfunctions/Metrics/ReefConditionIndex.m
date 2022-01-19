function Y = ReefConditionIndex(X, coralEvenness, shelterVolume, coralTaxaCover)

%% Translates coral metrics in ADRIA to a Reef Condition Metrics
% Inputs:
% 1. Total relative coral cover across all groups
% 2. Evenness across four coral groups
% 3. Abundance of coral juveniles < 5 cm diam
% 4. Shelter volume based coral sizes and abundances

% Dimensions: ntimesteps, nsites, ninterventions, nsimulations 

%% Total coral cover
covers = coralTaxaCover(X);
TC = covers.covers.total_cover;

%% Coral evenness 
E = coralEvenness(X);

%% Shelter volume
SV = shelterVolume(X);

%% Coral juveniles
juveniles = covers.juveniles; 

%% Compare outputs against reef condition criteria provided by experts 

%These are median values for 7 experts. TODO: draw from distributions
% Condition        TC       E       SV      Juv    
%{'VeryGood'}      0.45     0.45    0.45    0.35   
%{'Good'    }      0.35     0.35    0.35    0.25   
%{'Fair'    }      0.25     0.25    0.30    0.25   
%{'Poor'    }      0.15     0.25    0.30    0.25   
%{'VeryPoor'}      0.05     0.15    0.18    0.15   


rci_crit = [...
    0.45    0.45    0.45    0.35;
    0.35    0.35    0.35    0.25;
    0.25    0.25    0.30    0.25;
    0.15    0.25    0.30    0.25;
    0.05    0.15    0.18    0.15];

%% Adding dimension for rci metrics 

A_TC = TC > rci_crit(1,1);
B_TC = TC > rci_crit(2,1);
C_TC = TC > rci_crit(3,1);
D_TC = TC > rci_crit(4,1);
E_TC = TC > rci_crit(5,1);


A = sum(M,4)metrics) > rci_crit(1, metrics), 'omitnan') / numel(metrics);
reefcondition = zeros(NREEFS, NYEARS);
%Start loop for crieria vs metric comparisons
for reef = 1:NREEFS
    for t = 1:NYEARS
        M = [rci.totalCover(reef, t), ...
            rci.coralEvenness(reef, t), ...
            rci.shelterVolume(reef, t), ...
            rci.coraljuv_relative(reef, t), ...
            rci.CCA(reef, t), ...
            rci.COTSrel_complementary(reef, t), ...
            rci.Macroalgae_complementary(reef, t), ...
            rci.rubble_complementary(reef, t)];
        A = sum(M(metrics) > rci_crit(1, metrics), 'omitnan') / numel(metrics);
        B = sum(M(metrics) > rci_crit(2, metrics), 'omitnan') / numel(metrics);
        C = sum(M(metrics) > rci_crit(3, metrics), 'omitnan') / numel(metrics);
        D = sum(M(metrics) > rci_crit(4, metrics), 'omitnan') / numel(metrics);
        E = sum(M(metrics) > rci_crit(5, metrics), 'omitnan') / numel(metrics);
    
        if A > criteriaThreshold
            reefcondition(reef, t) = 0.9; %representative of very good
        elseif B > criteriaThreshold && A < criteriaThreshold
            reefcondition(reef, t) = 0.7; %representative of good
        elseif C > criteriaThreshold && A < criteriaThreshold && B < criteriaThreshold
            reefcondition(reef, t) = 0.5; %representative of fair
        elseif D > criteriaThreshold && C < criteriaThreshold && A < criteriaThreshold && B < criteriaThreshold
            reefcondition(reef, t) = 0.3; %representative of poor
        else
            reefcondition(reef, t) = 0.1; %
        end
    end
end

%% Plot results
figure;
tiledlayout(1, 4, 'TileSpacing', 'compact')
for p = 1:4
    ax(p) = nexttile;
    colormap(flipud(turbo))
    bubblechart(lons, lats, reefArea/1000, median(reefcondition(:, p*20-19:p*20), 2));
    bubblesize([3, 30])
    caxis([0.1, 0.9]);
end
colorbar('EastOutside')
