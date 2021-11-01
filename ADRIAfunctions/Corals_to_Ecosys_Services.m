function ecosys_results = Corals_to_Ecosys_Services(F0)

%% load data file
%loads results from ADRIA -
% F0 = load(strcat('Outputs/Results_RCP',num2str(RCP),'_Alg',num2str(alg_ind)));

TC = F0.TC;
C = F0.C;
E = F0.E;
S = F0.S;

%% request user input
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
evcult = str2num(answer{1}); %importance of evenness in supporting cultural ecosystem services
strcult = str2num(answer{2}); %importance of structural complexity in supporting cultural ecosystem services
evprov = str2num(answer{3}); %importance of evenness in supporting provisioning ecosystem services
strprov = str2num(answer{4});  %importance of structural complexity in supporting provisioning ecosystem services
TCsatCult = str2num(answer{5}); %saturating relationship between total cover and cultural services
TCsatProv = str2num(answer{6}); %saturating relationship between total cover and cultural services
cf = str2num(answer{7}); %counterfactual

%% Conversion to scope for ecosystem services

CultES = tanh(TC/TCsatCult) .* (evcult .* E + strcult .* S); %placeholder function for saturating function (needs stakeholder input)
CultES(CultES > 1) = 1; %set unity to max

ProvES = tanh(TC/TCsatProv) .* (evprov .* E + strprov .* S); %placeholder function for saturating function (needs stakeholder input)
ProvES(ProvES > 1) = 1;

dCultES = CultES - CultES(:, :, cf, :);  %ditto for delta between intervention and counterfactual
dCultES(dCultES > 1) = 1; %set unity to max
dCultES(dCultES < 0) = 0; %set unity to max

dProvES = ProvES - ProvES(:, :, cf, :); %ditto for delta between intervention and counterfactual
dProvES(dProvES > 1) = 1;
dProvES(dProvES < 0) = 0;

Nint = size(CultES, 3);

ecosys_results = struct('CultES', CultES, ...
                        'ProvES', ProvES, ...
                        'dCultES', dCultES, ...
                        'dProvES', dProvES, ...
                        'Nint', Nint);
end