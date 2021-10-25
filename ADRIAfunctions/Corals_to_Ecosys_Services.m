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
evcult = str2num(answer{1});
strcult = str2num(answer{2});
evprov = str2num(answer{3});
strprov = str2num(answer{4});
TCsatCult = str2num(answer{5});
TCsatProv = str2num(answer{6});
cf = str2num(answer{7}); %counterfactual

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