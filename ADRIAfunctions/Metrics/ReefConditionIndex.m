function Y = ReefConditionIndex(X, coralEvenness, shelterVolume, coralTaxaCover, coral_params)

%% Translates coral metrics in ADRIA to a Reef Condition Metrics
% Inputs:
% 1. Total relative coral cover across all groups
% 2. Evenness across four coral groups
% 3. Abundance of coral juveniles < 5 cm diam
% 4. Shelter volume based coral sizes and abundances

% Input dimensions: ntimesteps, nspecies, nsites
% Output dimensions: ntimesteps, nsites

%% Total coral cover
covers = coralTaxaCover(X);
TC = covers.total_cover;

%% Coral evenness 
E = coralEvenness(X);

%% Shelter volume
SV = shelterVolume(X, coral_params);

%% Coral juveniles
juv = covers.juveniles; 

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

A_E = E > rci_crit(1,2);
B_E = E > rci_crit(2,2);
C_E = E > rci_crit(3,2);
D_E = E > rci_crit(4,2);
E_E = E > rci_crit(5,2);

A_SV = SV > rci_crit(1,3);
B_SV = SV > rci_crit(2,3);
C_SV = SV > rci_crit(3,3);
D_SV = SV > rci_crit(4,3);
E_SV = SV > rci_crit(5,3);

A_juv = juv > rci_crit(1,4);
B_juv = juv > rci_crit(2,4);
C_juv = juv > rci_crit(3,4);
D_juv = juv > rci_crit(4,4);
E_juv = juv > rci_crit(5,4);

crit_thr = 0.75; %threshold for the proportion of criteria needed to be 
% met for category to be satisfied.

ntsteps = 25;
nsites = 26;

reefcondition = zeros(ntsteps, nsites);
        
A = (A_TC + A_E + A_SV + A_juv)/4;
B = (B_TC + B_E + B_SV + B_juv)/4;
C = (C_TC + C_E + C_SV + C_juv)/4;
D = (D_TC + D_E + D_SV + D_juv)/4;
E = (E_TC + E_E + E_SV + E_juv)/4;

for tstep = 1:ntsteps
     for site = 1:nsites
        if A(tstep,site) > crit_thr
            reefcondition(tstep, site) = 0.9; %representative of very good
        elseif B(tstep,site) > crit_thr && A(tstep,site) < crit_thr
            reefcondition(tstep, site) = 0.7; %representative of good
        elseif C(tstep,site) > crit_thr && A(tstep,site) < crit_thr && B(tstep,site) < crit_thr
            reefcondition(tstep, site) = 0.5; %representative of fair
        elseif D(tstep,site) > crit_thr && C(tstep,site) < crit_thr && A(tstep,site) < crit_thr && B(tstep,site) < crit_thr
            reefcondition(tstep, site) = 0.3; %representative of poor
        else
            reefcondition(tstep, site) = 0.1; %
        end %if
    end %site
end %tstep

Y = reefcondition;
