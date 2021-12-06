function ecosys_results = coralsToEcosysServices(F0, ES_vars)

%% Converts coral metrics in F0 (TC, E and S) into scope to support cultural
% and provisional ES (CultES and ProvES)
%
% Input -
%       F0 : structure with categories 'TC','E' and 'S' (total coral cover,
%             evenness and structural complexity.
%       ES_vars : parameters for calculating the ES (these functions will
%                 change in later versions
% Output -
%       ecosys_results : structure with categories 'CultES', 'ProvES','dCultES',
%                        'dProvES' (difference to counterfactual)

    TC = F0.TC;
    E = F0.E;
    S = F0.S;

    evcult = ES_vars(1);
    strcult = ES_vars(2);
    evprov = ES_vars(3);
    strprov = ES_vars(4);
    TCsatCult = ES_vars(5);
    TCsatProv = ES_vars(6);
    cf = ES_vars(7);

    %% Conversion to scope for ecosystem services

    CultES = tanh(TC/TCsatCult) .* (evcult .* E + strcult .* S); %placeholder function for saturating function (needs stakeholder input)
    CultES(CultES > 1) = 1; %set unity to max

    ProvES = tanh(TC/TCsatProv) .* (evprov .* E + strprov .* S); %placeholder function for saturating function (needs stakeholder input)
    ProvES(ProvES > 1) = 1;

    dCultES = CultES - CultES(:, :, cf, :); %ditto for delta between intervention and counterfactual
    dCultES(dCultES > 1) = 1; %set unity to max
    dCultES(dCultES < 0) = 0; %set unity to max

    dProvES = ProvES - ProvES(:, :, cf, :); %ditto for delta between intervention and counterfactual
    dProvES(dProvES > 1) = 1;
    dProvES(dProvES < 0) = 0;

    ecosys_results = struct('CultES', CultES, ...
        'ProvES', ProvES, ...
        'dCultES', dCultES, ...
        'dProvES', dProvES);
end
