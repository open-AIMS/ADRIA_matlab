function Y = ReefConditionIndex(TC, E, SV, juveniles)
% Translates coral metrics in ADRIA to a Reef Condition Metrics
% Inputs:
%   TC : Total relative coral cover across all groups 
%   E  : Evenness across four coral groups
%   SV : Shelter volume based coral sizes and abundances
%   juveniles : Abundance of coral juveniles < 5 cm diameter

% Input dimensions: ntimesteps, nspecies, nsites
% Output dimensions: ntimesteps, nsites, ninterventions, nreplicates

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

A_juv = juveniles > rci_crit(1,4);
B_juv = juveniles > rci_crit(2,4);
C_juv = juveniles > rci_crit(3,4);
D_juv = juveniles > rci_crit(4,4);
E_juv = juveniles > rci_crit(5,4);

crit_thr = 0.75; %threshold for the proportion of criteria needed to be 
% met for category to be satisfied.

A = (A_TC + A_E + A_SV + A_juv)/4;
B = (B_TC + B_E + B_SV + B_juv)/4;
C = (C_TC + C_E + C_SV + C_juv)/4;
D = (D_TC + D_E + D_SV + D_juv)/4;
% E = (E_TC + E_E + E_SV + E_juv)/4;

num_dims = ndims(TC);
if num_dims == 5
    % multi-scenario case
    [ntsteps, ~, nsites, ninterv, nreps] = size(TC);
elseif num_dims == 4
    [ntsteps, nsites, ninterv, nreps] = size(TC);
elseif num_dims == 3
    % single scenario case
    [ntsteps, ~, nsites] = size(TC);
    ninterv = 1;
    nreps = 1;
else
    error("Unexpected number of dimensions in result set.")
end

Y = zeros(ntsteps, nsites, ninterv, nreps);

% In single simulation cases, `inter` and `rep` are set to 1. Although
% matrices A, B, C etc may only have 3 dimensions, MATLAB accepts `1` in
% dims > 3, and just squeezes these out.
for inter = 1:ninterv
    for rep = 1:nreps
        for tstep = 1:ntsteps
             for site = 1:nsites
                 A_below_thres = A(tstep,site,inter,rep) <= crit_thr;
                 B_below_thres = B(tstep,site,inter,rep) <= crit_thr;

                 if A(tstep,site,inter,rep) >= crit_thr
                     Y(tstep, site, inter, rep) = 0.9; % representative of very good
                 elseif B(tstep,site,inter,rep) >= crit_thr && A_below_thres
                     Y(tstep,site,inter,rep) = 0.7; % representative of good
                 elseif C(tstep,site,inter,rep) >= crit_thr && A_below_thres && B_below_thres
                     Y(tstep,site,inter,rep) = 0.5; % representative of fair
                 elseif D(tstep,site,inter,rep) >= crit_thr && C(tstep,site, inter, rep) <= crit_thr && A_below_thres && B_below_thres
                     Y(tstep,site,inter,rep) = 0.3; % representative of poor
                 else
                     Y(tstep,site,inter,rep) = 0.1; %
                 end %if
            end %site
        end %tstep
    end  % reps
end  %interv
