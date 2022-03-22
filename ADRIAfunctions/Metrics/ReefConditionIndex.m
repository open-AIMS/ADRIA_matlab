function Y = ReefConditionIndex(TC, E, SV, juveniles)
% Translates coral metrics in ADRIA to a Reef Condition Metrics
%
% Inputs:
%   TC        : Total relative coral cover across all groups 
%   E         : Evenness across four coral groups
%   SV        : Shelter volume based coral sizes and abundances
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

% Note that the scores for evenness and juveniles are slightly different
TC_func = @(x) interp1([0, 0.05, 0.15, 0.25, 0.35, 0.45, 1.0], [0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0], x);
E_func = @(x) interp1([0, 0.15, 0.25, 0.35, 0.45, 1.0], [0, 0.1, 0.5, 0.7, 0.9, 1.0], x);
SV_func = @(x) interp1([0, 0.18, 0.30, 0.35, 0.45, 1.0], [0, 0.1, 0.3, 0.5, 0.9, 1.0], x);
juv_func = @(x) interp1([0, 0.15, 0.25, 0.35, 1.0], [0, 0.1, 0.5, 0.9, 1.0], x);

TC_i = TC_func(TC);
E_i = E_func(E);
SV_i = SV_func(SV);
juv_i = juv_func(juveniles);

% Original
% Y = (TC_i + E_i + SV_i + juv_i) ./ 4;

% Weighted, giving evenness 10% weight
% Y = (TC_i*0.3) + (E_i*0.1) + (SV_i*0.3) + (juv_i*0.3);

% Removing evenness completely
Y = (TC_i + SV_i + juv_i) ./ 3;

end
