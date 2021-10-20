
% change to functions folder
cd ..
cd ADRIAfunctions

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
interventions = intervention_specification();


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

% Settings can be changed as with intervention_specification()
criteria_weights = CriteriaWeights();

% Algorithm choice
%  1 = OrderRanking
%  2 = TOPSIS
%  3 = VIKOR 
alg_ind = 1;

% change to main folder to run main scripts
cd ..
cd ADRIAmain
runADRIA(interventions, criteria_weights, alg_ind);

cd ..
cd examples
analyseADRIAresults1(RCP,alg_ind);
