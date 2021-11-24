function ecosys_results = Corals_to_Ecosys_Services(F0,user_ind)

% user_ind indicates whether to use default 
TC = F0.TC;
E = F0.E;
S = F0.S;

% if user_ind =1 request user input for importance balancing
if user_ind == 1
    MetricPrompt = {'Relative importance of coral evenness for cultural ES (proportion):', ...
        'Relative importance of structural complexity for cultural ES (proportion):', ...
        'Relative importance of coral evenness for provisioning ES (proportion):', ...
        'Relative importance of structural complexity for provisioning ES (proportion):', ...
        'Total coral cover at which scope to support Cultural ES is maximised:', ...
        'Total coral cover at which scope to support Provisioning ES is maximised:', ...
        'Row used as counterfactual:'};
    dlgtitle = 'Coral metrics and scope for ecosystem-services provision';
    dims = [1, 50];
    definput = {'0.5', '0.5', '0.2', '0.8', '0.5', '0.5', '1'};
    answer = inputdlg(MetricPrompt, dlgtitle, dims, definput, "off");
    evcult = str2double(answer{1});
    strcult = str2double(answer{2});
    evprov = str2double(answer{3});
    strprov = str2double(answer{4});
    TCsatCult = str2double(answer{5});
    TCsatProv = str2double(answer{6});
    cf = str2double(answer{7}); %counterfactual
    % if user_ind == 0 use default (e.g. for optimisation)
elseif user_ind == 0
    evcult = 0.5;
    strcult = 0.5;
    evprov = 0.2;
    strprov = 0.8;
    TCsatCult = 0.5;
    TCsatProv = 0.5;
    cf = 1; %counterfactual
end
%% Conversion to scope for ecosystem services

CultES = tanh(TC/TCsatCult) .* (evcult .* E + strcult .* S); %placeholder function
CultES(CultES > 1) = 1; %set unity to max

ProvES = tanh(TC/TCsatProv) .* (evprov .* E + strprov .* S);
ProvES(ProvES > 1) = 1;

dCultES = CultES - CultES(:, :, cf, :);
dCultES(dCultES > 1) = 1; %set unity to max
dCultES(dCultES < 0) = 0; %set unity to max

dProvES = ProvES - ProvES(:, :, cf, :);
dProvES(dProvES > 1) = 1;
dProvES(dProvES < 0) = 0;

Nint = size(CultES, 3);

ecosys_results = struct('CultES', CultES, ...
                        'ProvES', ProvES, ...
                        'dCultES', dCultES, ...
                        'dProvES', dProvES, ...
                        'Nint', Nint);
end

