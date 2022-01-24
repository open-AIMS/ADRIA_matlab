function params = simConstants()
% Create struct with simulation constants for ADRIA
%
% Outputs:
%   params       : struct, simulation constants for ADRIA
%
% References:
%   1. Lough, J. M., Anderson, K. D., & Hughes, T. P. (2018). 
%          Increasing thermal stress for tropical coral reefs: 1871–2017. 
%          Scientific Reports, 8(1), 6079. 
%          https://doi.org/10.1038/s41598-018-24530-9
%   2. Hughes, T. P., Kerry, J. T., Baird, A. H., Connolly, S. R., 
%        Dietzel, A., Eakin, C. M., Heron, S. F., Hoey, A. S., 
%        Hoogenboom, M. O., Liu, G., McWilliam, M. J., Pears, R. J., 
%        Pratchett, M. S., Skirving, W. J., Stella, J. S., & Torda, G. (2018). 
%          Global warming transforms coral reef assemblages. 
%          Nature, 556(7702), 492–496. 
%          https://doi.org/10.1038/s41586-018-0041-2
%   3. Bozec, Y.-M., Rowell, D., Harrison, L., Gaskell, J., Hock, K., 
%        Callaghan, D., Gorton, R., Kovacs, E. M., Lyons, M., Mumby, P., 
%        & Roelfsema, C. (2021). 
%          Baseline mapping to support reef restoration and 
%          resilience-based management in the Whitsundays. 
%          https://doi.org/10.13140/RG.2.2.26976.20482

%% Base scenario parameters
params.tf = 25; %number of years - e.g. year 2050 if we start deploying in year 2025 and run for 25 years.
params.nsiteint = 5; % max number of sites we intervene on in a given year. May be updated in the intervention table

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
% equally. Based on Hughes et al 2018 and Bozec et al 2021.
% Corrected to be consistent with zero bleaching mortality at DHW < 3.
params.gompertz_p1 = 6.0;
params.gompertz_p2 = 0.40;

% Bleaching stress and coral fecundity parameters
params.LPdhwcoeff = 0.4; % shape parameters relating dhw affecting cover to larval production
params.LPDprm2 = 5; % parameter offsetting LPD curve

% competition: probability that large tabular Acropora overtop small massives
params.comp = 0.3;
%params.max_settler_density = 20; %per m2, more optimistic than Bozec et al 2021
