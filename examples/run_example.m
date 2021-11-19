% set random number seed to ensure consistent results for test
rng(101)

%% Set up ADRIA project
% Specify path to ADRIA project. Opens current directory if nothing is
% provided
ADRIAsetup()

%% Generate parameter combinations
% Create struct with default intervention values
% Options and default values:
%   Guided = [0, 1];  0 or 1 for guided or unguided intervention 
%                     (can specify both as an array)
%   PrSites = 3;      1, 2 or 3 for selection of site to intervene on
%   Seed1 = [0, 0.0005, 0.0010];  Seeding scenarios for 2 coral types
%   Seed2 = 0;
%   SRM = 0;          Shading levels
%   Aadpt = [6, 12];  Assisted adaptation levels
%   Natad = 0.05;     Natural adaptation levels
%   Seedyrs = 10;     how many years to seed, starting in 2026
%   Shadeyrs = 1;     how many years to shade, starting in 2026
%   sims = 50;        how many simulations to run
%   RCP = 60;

% Specify options above by name to change settings
N = 10;

interventions = interventionSpecification(sims=N);

% Specific settings can be changed as with interventionSpecification()
criteria_weights = criteriaWeights();

alg_ind = 1;

%% Future approach (implementation above will be deprecated)
% inter_opts = interventionDetails();
% criteria_opts = criteriaDetails();

% combine parameters
% combined_opts = [inter_opts; criteria_opts];

% p_sel = table;
% converted_tbl = convertScenarioSelection(p_sel, combined_opts);
% converted_tbl

% Set default criteria weighting
% wave_stress = 1  % wave stress avoidance
% heat_stress = 1  % heat stress avoidance
% shade_connectivity = 0  % Connectivity when shading/cooling
% seed_connectivity = 0   % Connectivity when seeding
% coral_cover_high = 0    % High coral cover intervention
% coral_cover_low = 0     % Low coral cover intervention
% seed_priority = 1       % Seed at strongest sources for priority sites
% shade_priority = 0      % Shade at strongest sources for priority sites
% deployed_coral_risk_tol = 1  % Risk Tolerance wrt Deployed Corals


% Algorithm choice
%  1 = OrderRanking
%  2 = TOPSIS
%  3 = VIKOR 
%  4 = Multi-Obj GA 

%% LOAD parameter file
[params, ecol_parms] = ADRIAparms(); % environmental and ecological parameter values etc

%% Run ADRIA

tic
reef_condition_metrics = runADRIA(interventions, criteria_weights, params, ecol_parms, alg_ind);
tmp = toc;

disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N), " sims (", num2str(tmp/N), " seconds per run)"))

%% Analysis Example

% Convert reef results to ecosystem service metrics
ecosys_results = Corals_to_Ecosys_Services(reef_condition_metrics);

% Display analysis
analyseADRIAresults1(ecosys_results);


%% Save results to file

% TODO: Extract RCP setting from `params` via ADRIAparms

% Generate common file prefix
filename = ADRIA_resultFilePrefix(params.RCP, alg_ind);

% Save reef results
ADRIA_saveResults(reef_condition_metrics, strcat(filename, '_reef'));

% Save ecosystem results into separate file
ADRIA_saveResults(ecosys_results, strcat(filename, '_ES'))
