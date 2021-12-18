function core_details = coreParamDetails(varargin)
% Detail criteria weight values and expected ranges.
% Default values for each criteria/option can be specified
% to override default values.
%
% Inputs:
%    Argument list of parameters to override.
%    Possible arguments (with default values):
%      - wave_stress             : 1
%      - heat_stress             : 0
%      - shade_connectivity      : 0
%      - seed_connectivity       : 0
%      - coral_cover_high        : 0
%      - coral_cover_low         : 0
%      - seed_priority           : 1
%      - shade_priority          : 0
%      - deployed_coral_risk_tol : 1
%
% Outputs:
%   table of name, ptype, defaults, lower_bound, upper_bound, options,
%   raw_lower_bound, raw_upper_bound, where
%       - `name` holds the parameter names
%       - `ptype` denotes the parameter type (categorical, integer, float)
%           - categoricals: values have to be exact match
%           - integers: whole number values ranging between lower/upper
%           - float: values can range between lower/upper
%       - `sample_defaults` indicates the default values modified for use
%           with samplers
%       - lower/upper bounds indicate the range of mapped ids 
%       - `options` maps option ids to their values
%       - `raw_defaults` indicates the raw unmodified "best guess" value
%       - `raw_bounds` indicates the original value ranges

name = [
    "tf";
    "nsiteint";
    "psgA";
    "psgB";
    "psgC";
    "nspecies";
    "ncoralsp";
    "con_cutoff";
    "years";
    "RCP"
];

defaults = {
    25; % "tf";
    5; % "nsiteint";
    1:10; % "psgA";
    11:20; % "psgB";
    1:26; % "psgC";
    4; % "nspecies";
    4; % "ncoralsp";
    0.10; % "con_cutoff";
    0; % "years";
    "45"  % RCP
};

params.tf = 25; %number of years - e.g. year 2050 if we start deploying in year 2025 and run for 25 years.

params.nsiteint = 5; % max number of sites we intervene on in a given year. May be updated in the intervention table
params.psgA = 1:10; % prioritysite group A
params.psgB = 11:20; % prioritysite group B
params.psgC = 1:26; % prioritysite group C

params.nspecies = 4; % number of groups modelled in the current version. If the community model is replaced with a population model, then this becomes 1.
params.ncoralsp = 4; % number of coral species modelled in the current version. If the community model is replaced with a population model, then this becomes 1.
params.con_cutoff = 0.10; % percent thresholds of max for weak connections in network
% params.ncrit = length(fieldnames(interv)); % number of columns used in the intervention table
params.years = 1:params.tf; % years of interest for analyses - change to yroi: years of interest
params.RCP = 60;  % RCP scenario to use

p_bounds = {
    [25, 100];  % "tf";
    [1, 26];    % "nsiteint";
    [0, 0];     % "psgA";
    [0, 0];     % "psgB";
    [0, 0];     % "psgC";
    [0, 0];     % "nspecies";
    [0, 0];     % "ncoralsp";
    [0, 0];     % "con_cutoff";
    [0, 0];     % "years";
    ["26", "45", "60", "6085", "85"];  % RCP
};

ptype = [
    "integer";
    "float";
    "float";
    "float";
    "float";
    "float";
    "float";
    "float";
    "float";
    "categorical"
];


% params.tf = 25; %number of years - e.g. year 2050 if we start deploying in year 2025 and run for 25 years.
% 
% params.nsiteint = 5; % max number of sites we intervene on in a given year. May be updated in the intervention table
% params.psgA = 1:10; % prioritysite group A
% params.psgB = 11:20; % prioritysite group B
% params.psgC = 1:26; % prioritysite group C
% params.nspecies = 4; % number of groups modelled in the current version. If the community model is replaced with a population model, then this becomes 1.
% params.ncoralsp = 4; % number of coral species modelled in the current version. If the community model is replaced with a population model, then this becomes 1.
% params.con_cutoff = 0.10; % percent thresholds of max for weak connections in network
% % params.ncrit = length(fieldnames(interv)); % number of columns used in the intervention table
% params.years = 1:params.tf; % years of interest for analyses - change to yroi: years of interest
% params.RCP = 60;  % RCP scenario to use


core_details = paramTableBuilder(name, ptype, defaults, p_bounds, varargin);

end
