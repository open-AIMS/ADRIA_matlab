addPath(currentProject, "ADRIAfunctions")
addPath(currentProject, "ADRIAmain")
addPath(currentProject, "Inputs")


% Create struct with default intervention values
% Options and default values:
%   Guided = [0, 1];  0 for unguided intervention, 1 for guided
%   PrSites = 3;
%   Seed1 = [0, 0.0005, 0.0010];
%   Seed2 = 0;
%   SRM = 0;
%   Aadpt = [6, 12];
%   Natad = 0.05;
%   Seedyrs = 10;
%   Shadeyrs = 1;
%   sims = 50;

%   Guided - 0 for unguided intervention, 1 for guided
%   PrSites - 1,2 or 3 for selection of site to intervene on
%   Seed1,Seed2 - seeding scenarios for 2 coral types
%   SRM - Shading levels
%   Aadpt - Assisted adaptation levels
%   Natad - Natural adaptatio levels
%   t_s - time slice size to analyse 
%   RCPs- user will enter as one or more of 26,60,85 separated by commas
%       (each of these .mat files should exist in the specified file path)

interventions = intervention_specification(Guided=[0,1]);

% Set default criteria weighting
criteria_weights = CriteriaWeights();

runADRIA(interventions, criteria_weights);
