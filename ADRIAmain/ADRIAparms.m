function [params, ecol_params] = ADRIAparms()
% Create structs with default parameter values for ADRIA
%
% Notes:
% Values for the historical, temporal pattern of degree heating weeks between bleaching years come from [1].
%
% References
% 1. Lough, J.M., Anderson, K.D. and Hughes, T.P. (2018) 
%        'Increasing thermal stress for tropical coral reefs: 1871–2017',
%        Scientific Reports, 8(1), p. 6079. 
%        doi: 10.1038/s41598-018-24530-9.

% This is the list of parameters and values used in most of ADRIA.
% See ReadMe files for more descriptions and explanations

msg = ['Note: ADRIAparms() is marked for deprecation.\n', ...
       'It will be replaced by coreParamDetails().'
];
warning(msg);

%% Base scenario parameters

params.tf = 25; %number of years - e.g. year 2050 if we start deploying in year 2025 and run for 25 years.

params.nsiteint = 5; % max number of sites we intervene on in a given year. May be updated in the intervention table
params.psgA = 1:10; % prioritysite group A
params.psgB = 11:20; % prioritysite group B
params.psgC = 1:26; % prioritysite group C

params.nspecies = 4; % total number of species modelled in the current version. Currently this is only corals, so nspecies = ncoralsp.
params.ncoralsp = 4; % number of coral species modelled in the current version. Currently nspecies = ncoralsp.
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

params.basecov1 = 0.40; % initial cover of coral species 1. Acropora unenhanced 
params.basecov2 = 0.00; % initial cover of coral species 2. Acropora enhanced
params.basecov3 = 0.15; % initial cover of coral species 3  Other coral unenhanced
params.basecov4 = 0.15; % initial cover of coral species 4  Other coral enhanced
%params.basecov5 = 0.00; % initial cover of rubble

params.corals = [1, 2, 3, 4]; % species of live corals

params.LPdhwcoeff = 0.4; % shape parameters relating dhw affecting cover to larval production
params.LPDprm2 = 5; % parameter offsetting LPD curve
params.wavemort90 = [0.3, 0.3, 0.1, 0.05]; % coral mortality risk attributable to 38: wave damage for the 90 percentile of routine wave stress

r = [0.40, 0.40, 0.10, 0.05]; % base growth of species 1 to 4 (1&2: Acropora, 3&4: others)
mb = [0.07, 0.07, 0.03, 0.01]; % background mortality of the four coral species, not waves and heat stress
P = 0.70; % max total coral cover - used as a carrying capacity with 1-P representing space that is not colonisable for corals

% DHW and bleaching mortality-related parameters.
p = [2.74, 0.25]; % Gompertz shape parameters 1 and 2 - for now applied to all coral species equally. Based on Hughes et al 2017 and Bozec et al 2021. 
natad = [0.2, 0.2, 0.05, 0.10]; % rate of natural adaptation, DHWs per year for all species
assistadapt = [0, 2, 2, 4]; % assisted adaptation, expressed as DHWs in absolute terms - i.e. not increasing over time
ecol_params = struct('r', r, 'mb', mb, 'P', P, 'p', p, 'natad', natad, 'assistadapt', assistadapt); % package into structure to use in functions

%% Ecosystem service parameters

params.evcult = 0.5; % assumes that evenness counts half for cultural ES
params.strcult = 0.5; % assumes that structural complexity counts half for cultural ES
params.evprov = 0.2; % 0.2 for provisioning ES
params.strprov = 0.8; % 0.8 for provisioning ES
