function interventions = interventionDetails(varargin)
% Detail intervention parameter values and expected ranges.
% Default values for each intervention option can be specified
% to override defaults.
%
% Inputs:
%    Argument list of parameters to override.
%    Possible arguments (with default values):
%      - Guided   : [0, 1]
%      - PrSites  : 3
%      - Seed1    : [0, 0.0005, 0.0010]
%      - Seed2    : 0
%      - SRM      : 0
%      - Aadpt    : [6, 12]
%      - Natad    : 0.05
%      - Seedyrs  : 10
%      - Shadeyrs : 1
%
% Outputs:
%   table of name, ptype, defaults, lower_bound, upper_bound, options,
%   raw_lower_bound, raw_upper_bound, where
%       - `name` holds the parameter names
%       - `ptype` denotes the parameter type (categorical, integer, float)
%           - categoricals: values have to be exact match
%           - integers: whole number values ranging between lower/upper
%           - float: values can range between lower/upper
%       - `defaults` indicates the raw unmodified assigned value
%       - lower/upper bounds indicate the range of mapped ids 
%       - `options` maps option ids to their values
%       - raw_lower/raw_upper bounds indicates the original value ranges
name = [
    "Guided";
    "PrSites";
    "Seed1";
    "Seed2";
    "SRM";
    "Aadpt";
    "Natad";
    "Seedyrs";
    "Shadeyrs";
];

defaults = {
    0;  % Guided
    3;  % PrSites
    0.0005;  % Seed1
    0;  % Seed2
    0;  % SRM
    6;  % Aadpt
    0.05;  % Natad
    10;  % Seedyrs
    1;  % Shadeyrs
};

% TODO: lower and upper bounds are dummy values and need to be replaced!
p_bounds = {
    [0, 1];  % Guided
    [1, 3];  % PrSites
    [0.0, 0.0010];  % Seed1
    [0.0, 1.0];  % Seed2
    [0, 1];  % SRM
    [6, 12];  % Aadpt
    [0.01, 0.1];  % Natad
    [10, 15];  % Seedyrs
    [1, 5];  % Shadeyrs
};

ptype = [
    "categorical";  % categoricals: values have to be exact match
    "integer";      % integer: option is whole number between upper/lower
    "float";        % float: value ranges between upper/lower
    "float";
    "categorical";
    "integer";
    "float";
    "integer";
    "integer";
];


interventions = paramTableBuilder(name, ptype, defaults, p_bounds, ...
                                  varargin);

end