% set random number seed to ensure consistent results for test
rng(101)

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
N = 100;
% get shell variables
prsites = str2num(getenv('PrSites')); % PrSites
rcp = str2num(getenv('RCP'));; % RCP
s1 = str2num(getenv('Seed1')); % Seed 1
s2 = str2num(getenv('Seed2'));; % Seed 2
srm = str2num(getenv('SRM')); % SRM
aadpt = str2num(getenv('Aadpt'));; % Asissted Adapt.
natad = str2num(getenv('Natad'));; % Asissted Adapt.

interventions = interventionSpecification(Guided = 1,PrSites = prsites,...
    Seed1 = s1,Seed2 = s2,SRM = srm,Aadpt = aadpt,Natad = natad, ...
    Seedyrs = 10,Shadeyrs = 1,sims=N);

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

% set up ADRIA project
% input path to project or nothing if project is in pwd
ADRIAsetup()

% Settings can be changed as with interventionSpecification()
criteria_weights = criteriaWeights();

% Algorithm choice
%  1 = OrderRanking
%  2 = TOPSIS
%  3 = VIKOR 
%  4 = Multi-Obj GA 

alg_ind = 1;;


reef_condition_metrics = runADRIA(interventions, criteria_weights, alg_ind);

% Convert reef results to ecosystem service metrics
ecosys_results = Corals_to_Ecosys_Services(reef_condition_metrics);

% label file with key parameters
filename = sprintf('ADRIA_multipar_out_RCP%2.0f_PrS%1.0d_Alg%1.0d_s1%1.4f_s2%1.4f_srm%1.0d_aadpt%1.0f.csv',...
    rcp,prsites,alg,s1,s2,srm,aadpt,natad);

data = struct('CoralCover',reef_condition_metrics.TC, 'Cult_ES', ecosys_results.CultES,'Prov_ES',ecosys_results.ProvES);

% save as csv
ADRIA_saveResults(data,filename)