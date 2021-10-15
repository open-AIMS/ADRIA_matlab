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

% Create struct with default values.
% Specify options above by name to change settings
interventions = intervention_specification(Guided=1);

% Set default criteria weighting
% Settings can be changed as with intervention_specification()
criteria_weights = CriteriaWeights();

% Algorithm choice
%  1 = OrderRanking
%  2 = TOPSIS
%  3 = VIKOR 
alg_ind = 1;

runADRIA(interventions, criteria_weights, alg_ind);
