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
TC = covers.total_cover;

%% Coral evenness 
E = coralEvenness(X);

%% Shelter volume
SV = shelterVolume(X, @coral_params);

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

criteria_threshold = 0.75; %threshold for how many criteria need to be met for category to be satisfied.

ntsteps = size(X,1);
nsites = size(X,2);
ninterventions = size(X,3);
nsims = size(X,4);

reefcondition = zeros(ntsteps, nsites, ninterventions, nsims);
%Start loop for crieria vs metric comparisons
for tstep = 1:ntsteps
    for site = 1:nsites
        for int = 1:ninterventions
            for sim = 1:nsims
        M = [TC(tstep, site, int, sim), ...
            E(tstep, site, int, sim), ...
            SV(tstep, site, int, sim), ...
            juveniles(tstep, site, int, sim)];
        
        A = sum(M > rci_crit(1, :), 'omitnan') / size(M,2);
        B = sum(M > rci_crit(2, :), 'omitnan') / size(M,2);
        C = sum(M > rci_crit(3, :), 'omitnan') / size(M,2);
        D = sum(M > rci_crit(4, :), 'omitnan') / size(M,2);
        E = sum(M > rci_crit(5, :), 'omitnan') / size(M,2);
    
        if A > criteria_threshold
            reefcondition(tstep, site, int, sim) = 0.9; %representative of very good
        elseif B > criteria_threshold && A < criteriaThreshold
            reefcondition(tstep, site, int, sim) = 0.7; %representative of good
        elseif C > criteria_threshold && A < criteriaThreshold && B < criteriaThreshold
            reefcondition(tstep, site, int, sim) = 0.5; %representative of fair
        elseif D > criteria_threshold && C < criteriaThreshold && A < criteriaThreshold && B < criteriaThreshold
            reefcondition(tstep, site, int, sim) = 0.3; %representative of poor
        else
            reefcondition(tstep, site, int, sim) = 0.1; %
        end %if
            end %sim
        end %int
    end %site
end %tstep

Y = reefcondition;
