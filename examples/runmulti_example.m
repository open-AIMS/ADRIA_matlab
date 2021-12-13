% set random number seed to ensure consistent results for test
rng(101)

% set up ADRIA project
% input path to project or nothing if project is in pwd
ADRIAsetup();

% Create struct with intervention values using system environment
% variables.

N = 50;
prsites = 2; % str2num(getenv('PrSites')); % PrSites
rcp = 60; % str2num(getenv('RCP')); % RCP
s1 = 0.3; % str2num(getenv('Seed1')); % Seed 1
s2 = 0.6; % str2num(getenv('Seed2')); % Seed 2
srm = 1; % str2num(getenv('SRM')); % SRM
aadpt = 7.0; % str2num(getenv('Aadpt')); % Asissted Adapt.
natad = 0.9; % str2num(getenv('Natad')); % rate of natural adaptation .

% Specify default values (assigned to `raw_defaults` column)
interventions = interventionDetails(Guided = 1, PrSites = prsites, ...
    Seed1 = s1, Seed2 = s2, SRM = srm, Aadpt = aadpt, Natad = natad, ...
    Seedyrs = 10, Shadeyrs = 1);

% Set default criteria weighting
% Settings can be changed as with interventionDetails()
criteria_weights = criteriaDetails();

% We're using specified values, so no need
interv_vals = convertScenarioSelection(interventions.sample_defaults', interventions);
criteria_vals = convertScenarioSelection(criteria_weights.sample_defaults', criteria_weights);

[params, ecol_params] = ADRIAparms();
param_tbl = struct2table(params);
ecol_tbl = struct2table(ecol_params);

param_tbl = repmat(param_tbl, N, 1);
ecol_tbl = repmat(ecol_tbl, N, 1);

% Convert sampled values to ADRIA usable values
% Necessary as samplers expect real-valued parameters (e.g., floats)
% where as in practice ADRIA makes use of integer and categorical
% parameters
% converted_tbl = convertScenarioSelection(p_sel, combined_opts);

% Separate parameters into components
% (to be replaced with a better way of separating these...)
% interv_scens = converted_tbl{:, 1:9};  % intervention scenarios
% criteria_weights = converted_tbl{:, 10:end};

% Algorithm choice
%  1 = OrderRanking
%  2 = TOPSIS
%  3 = VIKOR
%  4 = Multi-Obj GA
alg_ind = 1;

%% Load site specific data
[F0, xx, yy, nsites] = ADRIA_siteTable('Inputs/MooreSites.xlsx');
[TP_data, site_ranks, strongpred] = ADRIA_TP('Inputs/MooreTPmean.xlsx', params.con_cutoff);

%% setup for the geographical setting including environmental input layers
% Load wave/DHW scenario data
% Generated with generateWaveDHWs.m
% TODO: Replace these with wave/DHW projection scenarios instead
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(params.RCP), ".nc");
wave_scens = ncread(fn, "wave");
dhw_scens = ncread(fn, "DHW");

% Select 10 RCP conditions randomly WITHOUT replacement
n_rep_scens = length(wave_scens);
rcp_scens = datasample(1:n_rep_scens, N, 'Replace', false);
w_scens = wave_scens(:, :, rcp_scens);
d_scens = dhw_scens(:, :, rcp_scens);

% reef_condition_metrics = runADRIA(interventions, criteria_weights, alg_ind);
reef_condition_metrics = runADRIA(interv_vals, criteria_vals, param_tbl, ecol_tbl, ...
                 TP_data, site_ranks, strongpred, N, ...
                 w_scens, d_scens, alg_ind);
             
%% analysis
% Prompt for importance balancing
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

ES_vars = [evcult, strcult, evprov, strprov, TCsatCult, TCsatProv, cf];

% Convert reef results to ecosystem service metrics
ecosys_results = coralsToEcosysServices(reef_condition_metrics, ES_vars);

% label file with key parameters
filename = sprintf('ADRIA_multipar_out_RCP%2.0f_PrS%1.0d_Alg%1.0d_s1%1.4f_s2%1.4f_srm%1.0d_aadpt%1.0f_natad%1.0f.nc', ...
    rcp, prsites, alg_ind, s1, s2, srm, aadpt, natad);

filename = strcat("Outputs/", filename);

data = struct('CoralCover', reef_condition_metrics.TC, 'Cult_ES', ecosys_results.CultES, 'Prov_ES', ecosys_results.ProvES);

% save results
saveData(data, filename)