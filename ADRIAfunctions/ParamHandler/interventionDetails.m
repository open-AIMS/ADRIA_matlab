function interventions = interventionDetails(varargin)
% Detail intervention parameter values and expected ranges.
% Parameter values for each intervention option can be specified
% to override defaults.
%
% Inputs:
%    Argument list of parameters to override.
%    Possible arguments (with default values/ranges):
%      - Guided   : [0, 1, 2, 3, 4], where 0 is unguided
%      - Seed1    : [100, 10000], 1000
%      - Seed2    : [100, 10000], 1000
%      - SRM      : [0, 12], 0
%      - Aadpt    : [0, 12], 0
%      - Natad    : [0, 0.1], 0.025
%      - Seedyrs  : [10, 15], 10
%      - Shadeyrs : [10, 25], 10
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
    "Guided";
    "Seed1";
    "Seed2";
    "SRM";
    "Aadpt";
    "Natad";
    "Seedyrs";
    "Shadeyrs";
];

defaults = [
    0;  % Guided
    1000;  % Seed1
    1000;  % Seed2
    0;  % SRM
    0;  % Aadpt
    0.025;  % Natad
    10;  % Seedyrs
    10;  % Shadeyrs
];


p_bounds = [
    [0, 4];  % Guided
    [100, 10000];  % Seed1
    [100, 10000];  % Seed2
    [0, 12];  % SRM
    [0.0, 12];  % Aadpt
    [0.0, 0.1];  % Natad
    [10, 15];  % Seedyrs
    [10, 25];  % Shadeyrs
];

% categoricals: values indicated by whole number mapped back to arbitrary
% value (e.g., string input).
%
% integers: values have to be a whole number
% float: real-valued inputs


ptype = [
    "integer";
    "integer";
    "integer";
    "float";
    "float";
    "float";
    "integer";
    "integer";
];

interventions = paramTableBuilder(name, ptype, defaults, p_bounds, ...
                                  varargin);

end