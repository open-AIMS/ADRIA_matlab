function criteria_weights = criteriaDetails(varargin)
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
    "wave_stress";
    "heat_stress";
    "shade_connectivity";
    "seed_connectivity";
    "coral_cover_high";
    "coral_cover_low";
    "seed_priority";
    "shade_priority";
    "deployed_coral_risk_tol"
];

defaults = [
    1; % "wave_stress";
    1; % "heat_stress";
    0; % "shade_connectivity";
    1; % "seed_connectivity";
    0; % "coral_cover_high";
    1; % "coral_cover_low";
    1; % "seed_priority";
    0; % "shade_priority";
    1 % "deployed_coral_risk_tol"
];

p_bounds = [
    [0, 1]; % "wave_stress";
    [0, 1]; % "heat_stress";
    [0, 1]; % "shade_connectivity";
    [0, 1]; % "seed_connectivity";
    [0, 1]; % "coral_cover_high";
    [0, 1]; % "coral_cover_low";
    [0, 1]; % "seed_priority";
    [0, 1]; % "shade_priority";
    [0, 1] % "deployed_coral_risk_tol"
];

ptype = [
    "float";
    "float";
    "float";
    "float";
    "float";
    "float";
    "float";
    "float";
    "float"
];


criteria_weights = paramTableBuilder(name, ptype, defaults, p_bounds, ...
                                     varargin);

end