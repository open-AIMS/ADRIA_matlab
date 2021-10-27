function [params, ecol_params] = ADRIAparms(Interv)
% Create structs with default parameter values for ADRIA
%
% Notes:
% Values for distribution of degree heating weeks come from [1].
%
% References
% 1. Lough, J.M., Anderson, K.D. and Hughes, T.P. (2018) 
%        'Increasing thermal stress for tropical coral reefs: 1871–2017',
%        Scientific Reports, 8(1), p. 6079. 
%        doi: 10.1038/s41598-018-24530-9.

% This is the list of parameters and values used in most of ADRIA.
% See ReadMe files for more descriptions and explanations

%% Base scenario parameters

params.tf = 25; %number of years - e.g. year 2050 if we start deploying in year 2025 and run for 25 years.

params.nsiteint = 5; % max number of sites we intervene on in a given year. May be updated in the intervention table
params.psgA = 1:10; % prioritysite group A
params.psgB = 11:20; % prioritysite group B
params.psgC = 1:26; % prioritysite group C
params.nspecies = 4; % number of groups modelled in the current version. If the community model is replaced with a population model, then this becomes 1.
params.ncoralsp = 4; % number of coral species modelled in the current version. If the community model is replaced with a population model, then this becomes 1.
params.con_cutoff = 0.10; % percent thresholds of max for weak connections in network
params.ncrit = length(fieldnames(Interv)); % number of columns used in the intervention table
params.years = 1:params.tf; % years of interest for analyses - change to yroi: years of interest

%% Environmental parameters

params.beta = [1, 3]; % beta parameters for wave disturbance
params.dhwmax25 = 7; % dhwmax at year 2025
params.DHWmaxtot = 50; % max assumed DHW for all scenarios
params.wb1 = 0.55; % weibull parameter 2 for DHW distributions based on Lough et al 2018
params.wb2 = 2.24; % weibull parameter 1 for DHW distributions based on Lough et al 2018

%% Ecological parameters

params.basecov1 = 0.40; % initial cover of coral species 1
params.basecov2 = 0.00; % initial cover of coral species 2
params.basecov3 = 0.15; % initial cover of coral species 3
params.basecov4 = 0.15; % initial cover of coral species 4
%params.basecov5 = 0.00; % initial cover of rubble

params.corals = [1, 2, 3, 4]; % species of live corals

params.LPdhwcoeff = 0.4; % shape parameters relating dhw affecting cover to larval production
params.LPDprm2 = 5; % parameter offsetting LPD curve
params.wavemort90 = [0.3, 0.3, 0.1, 0.05]; % coral mortality risk attributable to 38: wave damage for the 90 percentile of routine wave stress
params.corals = [1, 2, 3, 4]; % species of live corals

r = [0.40, 0.40, 0.10, 0.05]; % base growth of species 1 to 4 (1&2: sens, 3&4: hard)
mb = [0.07, 0.07, 0.03, 0.01]; % background mortality of the four species, not waves and heat stress
P = 0.70; % max total coral cover

% DHW and bleaching mortality-related parameters.
p = [2.74, 0.25]; % Gompertz shape parameters 1 and 2 - for now applied to both species.
natad = [0.2, 0.2, 0.05, 0.10]; % DHWs per year for all species
assistadapt = [0, 2, 2, 4]; % expressed as DHWs in absolute terms - i.e. not increasing over time
ecol_params = struct('r', r, 'mb', mb, 'P', P, 'p', p, 'natad', natad, 'assistadapt', assistadapt); % package into structure to use in functions

%% Ecosystem service parameters

params.evcult = 0.5; % assumes that evenness counts half for cultural ES
params.strcult = 0.5; % assumes that structural complexity counts half for cultural ES
params.evprov = 0.2; % 0.2 for provisioning ES
params.strprov = 0.8; % 0.8 for provisioning ES
