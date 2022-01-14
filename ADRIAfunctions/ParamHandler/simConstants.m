function params = simConstants()
% Create struct with simulation constants for ADRIA
%
% Outputs:
%   params       : struct, simulation constants for ADRIA
%
% References:
%   1. Lough et al 2018
%   2. Hughes et al 2017
%   3. Bozec et al 2021

%% Base scenario parameters
params.tf = 25; %number of years - e.g. year 2050 if we start deploying in year 2025 and run for 25 years.
params.nsiteint = 5; % max number of sites we intervene on in a given year. May be updated in the intervention table
params.psgA = 1:10; % prioritysite group A
params.psgB = 11:20; % prioritysite group B
params.psgC = 1:26; % prioritysite group C

params.con_cutoff = 0.10; % percent thresholds of max for weak connections in network
% params.years = 1:params.tf; % years of interest for analyses - change to yroi: years of interest
params.RCP = 45;  % RCP scenario to use

%% Environmental parameters
params.beta = [1, 3]; % beta parameters for wave disturbance (distribution parameter)
params.dhwmax25 = 5; % dhwmax at year 2025. NOTE: all warming simulations will change with new common DHW input for MDS team
params.DHWmaxtot = 50; % max assumed DHW for all scenarios.  Will be obsolete when we move to new, shared inputs for DHW projections
params.wb1 = 0.55; % weibull parameter 1 for DHW distributions based on Lough et al 2018
params.wb2 = 2.24; % weibull parameter 2 for DHW distributions based on Lough et al 2018

% max total coral cover
% used as a carrying capacity with 1-P representing space that is not
% colonisable for corals
params.max_coral_cover = 0.8;

% Gompertz shape parameters 1 and 2 - for now applied to all coral species
% equally. Based on Hughes et al 2017 and Bozec et al 2021.
% Corrected to be consistent with zero bleaching mortality at DHW < 3.
params.gompertz_p1 = 2.74;
params.gompertz_p2 = 0.25;

% Bleaching stress and coral fecundity parameters
params.LPdhwcoeff = 0.4; % shape parameters relating dhw affecting cover to larval production
params.LPDprm2 = 5; % parameter offsetting LPD curve

% competition: probability that large tabular Acropora overtop small massives
params.comp = 0.3;
%params.max_settler_density = 20; %per m2, more optimistic than Bozec et al 2021

%% Ecosystem service parameters
params.evcult = 0.5; % assumes that evenness counts half for cultural ES
params.strcult = 0.5; % assumes that structural complexity counts half for cultural ES
params.evprov = 0.2; % 0.2 for provisioning evenness ES
params.strprov = 0.8; % 0.8 for provisioning structural ES
