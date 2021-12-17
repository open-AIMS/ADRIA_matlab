function [params, vital_params] = ADRIAparms()
% Create structs with default parameter values for ADRIA
%
% Notes:
% Values for the historical, temporal pattern of degree heating weeks between bleaching years come from [1].
%
% Outputs:
%   params       : struct, core ADRIA parameters
%   vital_params : struct, vital rate parameters for corals
%
% References
% 1. Lough, J.M., Anderson, K.D. and Hughes, T.P. (2018) 
%        'Increasing thermal stress for tropical coral reefs: 1871–2017',
%        Scientific Reports, 8(1), p. 6079. 
%        doi: 10.1038/s41598-018-24530-9.

% This is the list of parameters and values used in most of ADRIA.
% See ReadMe files for more descriptions and explanations

msg = ['Note: ADRIAparms() is marked for deprecation.', newline, ...
       'It will be replaced by coreParamDetails().'
];
warning(msg);

%% Base scenario parameters

params.tf = 25; %number of years - e.g. year 2050 if we start deploying in year 2025 and run for 25 years.

params.nsiteint = 5; % max number of sites we intervene on in a given year. May be updated in the intervention table
params.psgA = 1:10; % prioritysite group A
params.psgB = 11:20; % prioritysite group B
params.psgC = 1:26; % prioritysite group C

% Below parameters pertaining to species are new. We now add size classes 
% to each coral species, but treat each coral size class as a 'species'. 
% need a better word than 'species' to signal that we are using different
% sizes within groups and real taxonomic species. 

params.taxa_names = [ ...
    "tabular_acropora_enhanced", ...
    "tabular_acropora_unenhanced", ...
    "corymbose_acropora_enhanced", ...
    "corymbose_acropora_unenhanced", ...
    "small_massives", ...
    "large_massives"
];

size_classes = [2, 5, 10, 20, 40, 80];
params.size_classes = size_classes;

params.ntaxa = length(params.taxa_names);  % number of coral taxa
params.nclasses = length(params.size_classes); % number of coral size classes
params.nspecies = params.ntaxa * params.nclasses; % total number of species modelled in the current version.

params.con_cutoff = 0.10; % percent thresholds of max for weak connections in network
% params.ncrit = length(fieldnames(interv)); % number of columns used in the intervention table
params.years = 1:params.tf; % years of interest for analyses - change to yroi: years of interest
params.RCP = 60;  % RCP scenario to use

%% Environmental parameters

params.beta = [1, 3]; % beta parameters for wave disturbance (distribution parameter)
params.dhwmax25 = 7; % dhwmax at year 2025. NOTE: all warming simulations will change with new common DHW input for MDS team  
params.DHWmaxtot = 50; % max assumed DHW for all scenarios.  Will be obsolete when we move to new, shared inputs for DHW projections
params.wb1 = 0.55; % weibull parameter 2 for DHW distributions based on Lough et al 2018
params.wb2 = 2.24; % weibull parameter 1 for DHW distributions based on Lough et al 2018

%% Ecological parameters

% To be more consistent with parameters in ReefMod, IPMF and RRAP 
% interventions, we express coral abundance as colony numbers in different 
% size classes and growth rates as linear extention (in cm per year). 


%% Base covers
%First express as number of colonies per size class per 100m2 of reef
base_coral_numbers = ...
     [0,0,0,0,0,0;     %Tabular Acropora Enhanced
      2000,500,200,100,100,100;       %Tabular Acropora Unenhanced
      0,0,0,0,0,0;       %Corymbose Acropora Enhanced
      2000,500,200,100,100,100;       %Corymbose Acropora Unenhanced
      2000,500,200,100,100,100;       %small massives
      2000,200,100,100,50,10];      %large massives

% To convert to covers we need to first calculate the area of colonies, 
% multiply by how many corals in each bin, and divide by reef area

% The coral colony diameter bin edges (cm) are: 0, 2, 5, 10, 20, 40, 80
% To convert to cover we locate bin means and calculate bin mean areas

colony_diam_edges =  repmat(size_classes, length(size_classes), 1);
colony_area_means = pi.*((colony_diam_edges./2).^2)./(10^4);%areas in m2 

a_arena = 100; %m2 of reef arena where corals grow, survive and reproduce
  
% convert to coral covers (proportions) and convert to vector 
basecov = ...
    base_coral_numbers.*colony_area_means./a_arena;

% convert to vector and embed in structure 
for taxa = 1:params.ntaxa
    params.(strcat('basecov__', params.taxa_names(taxa))) = {basecov(:, taxa)};
end

% as nspecies*1 vector
params.basecov = reshape(basecov, params.nspecies, 1);


%% Coral growth rates as linear extensions (Bozec et al 2021 Table S2)
% we assume similar growth rates for enhanced and unenhanced corals
linear_extension = ...
      [1, 1, 2, 4.4, 4.4, 4.4;   %Tabular Acropora Enhanced
       1, 1, 2, 4.4, 4.4, 4.4;   %Tabular Acropora Unenhanced
       1, 1, 3, 3, 3, 3;         %Corymbose Acropora Enhanced
       1, 1, 3, 3, 3, 3;         %Corymbose Acropora Unenhanced
       1, 1, 1, 1, 0.8, 0.8;     %small massives
       1, 1, 1, 1, 1.2, 1.2];     %large massives

% Convert linear extensions to delta coral in two steps.
% First calculate what proportion of coral numbers that change size class 
% given linear extensions. This is based on the simple assumption that 
% coral sizes are evenly distributed within each bin
bin_widths = [2, 3, 5, 10, 20, 40];
diam_bin_widths = repmat(bin_widths, [length(bin_widths), 1]);
prop_change = linear_extension./diam_bin_widths;

%Second, growth as transitions of cover to higher bins is estimated as 
r = base_coral_numbers.*prop_change.*colony_area_means./a_arena;
for r_i = 1:params.ntaxa
    vital_params.(strcat('growth_rate__', params.taxa_names(taxa))) = {r(:, r_i)};
end

vital_params.growth_rate = reshape(r, params.nspecies, 1);

%% Background mortality

% Bleaching stress and coral fecundity parameters
params.LPdhwcoeff = 0.4; % shape parameters relating dhw affecting cover to larval production
params.LPDprm2 = 5; % parameter offsetting LPD curve

% coral mortality risk attributable to 38: wave damage for the 90 percentile of routine wave stress
wavemort90 = ...
      [0, 0, 0.02, 0.03, 0.03, 0.03;     % Tabular Acropora Enhanced
       0, 0, 0.02, 0.03, 0.03, 0.03;     % Tabular Acropora Unenhanced
       0, 0, 0.02, 0.02, 0.02, 0.02;     % Corymbose Acropora Enhanced
       0, 0, 0.02, 0.02, 0.02, 0.02;     % Corymbose Acropora Unenhanced
       0, 0, 0.00, 0.01, 0.01, 0.01;     % small massives
       0, 0, 0.00, 0.01, 0.01, 0.01];    % large massives

for wm_i = 1:params.ntaxa
    params.(strcat('wavemort90__', params.taxa_names(taxa))) = {wavemort90(wm_i, :)};
end
params.wavemort90 = reshape(wavemort90, params.nspecies, 1);

P = 1; % max total coral cover - used as a carrying capacity with 1-P representing space that is not colonisable for corals
p = {[2.74, 0.25]}; % Gompertz shape parameters 1 and 2 - for now applied to all coral species equally. Based on Hughes et al 2017 and Bozec et al 2021. 
vital_params = struct('max_coral_cover', P, 'p', p); % package into structure to use in functions

% Taken from Bozec et al. 2021 (Table S2)
mb = [0.2, 0.19, 0.10, 0.05, 0.03, 0.03;     % Tabular Acropora Enhanced
      0.2, 0.19, 0.10, 0.05, 0.05, 0.03;     % Tabular Acropora Unenhanced
      0.2, 0.20, 0.17, 0.05, 0.03, 0.03;     % Corymbose Acropora Enhanced
      0.2, 0.20, 0.17, 0.05, 0.05, 0.05;     % Corymbose Acropora Unenhanced
      0.2, 0.20, 0.04, 0.04, 0.02, 0.02;     % small massives
      0.2, 0.20, 0.04, 0.04, 0.02, 0.02];    % large massives

%Converted to vector and embedded in structure
for mb_i = 1:params.ntaxa
    vital_params.(strcat('mb_rate__', params.taxa_names(taxa))) = {mb(mb_i, :)};
end

vital_params.mb_rate = reshape(mb, params.nspecies, 1);

%% Ecosystem service parameters

params.evcult = 0.5; % assumes that evenness counts half for cultural ES
params.strcult = 0.5; % assumes that structural complexity counts half for cultural ES
params.evprov = 0.2; % 0.2 for provisioning ES
params.strprov = 0.8; % 0.8 for provisioning ES
