function interventions = interventionDetails(varargin)
% Detail intervention parameter values and expected ranges.
% Parameter values for each intervention option can be specified
% to override defaults.
%
% Inputs:
%    Argument list of parameters to override.
%    Possible arguments (with [value range], default value):
%      - Guided   : integer, [0, 1, 2, 3, 4], where 0 is unguided
%      - Seed1    : integer, [100, 10000], 1000  
%      - Seed2    : integer, [100, 10000], 1000
%      - SRM      : float, [0, 12], 0
%      - Aadpt    : float, [0, 12], 0
%      - Natad    : float, [0, 0.1], 0.025
%      - Seedyrs  : integer, [10, 15], 10
%      - Shadeyrs : integer, [10, 25], 10
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
    "Seedfreq";
    "Shadefreq";
    "Seedyr_start";
    "Shadeyr_start";
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
    5; % Seedfreq
    1; % Shadefreq
    2; % Year to start seed interventions
    2; % Year to start shading interventions
];


p_bounds = [
    [0, 4];  % Guided, choice of MCDA approach
    [100, 10000];  % Seed1, integer, number of Enhanced TA to seed
    [100, 10000];  % Seed2, integer, number of Enhanced TC to seed
    [0, 12];  % SRM, float, reduction in DHWs due to shading
    [0.0, 12];  % Aadpt, float, float, increased adaptation rate
    [0.0, 0.1];  % Natad, float, natural adaptation rate
    [10, 15];  % Seedyrs, integer, years into simulation during which seeding is considered
    [10, 25];  % Shadeyrs, integer, years into simulation during which shading is considered
    [0, 25]; % Seedfreq, integer, yearly intervals to adjust seeding site selection (0 is set and forget)
    [0, 25]; % Shadefreq, integer, yearly intervals to adjust shading site selection (0 is set and forget)
    [2, 25];  % Seedyr_start, integer, seed intervention start offset from simulation start
    [2, 25];  % Shadeyr_start, integer, shade intervention start offset from simulation start
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
    "integer";
    "integer";
    "integer";
    "integer";
];

interventions = paramTableBuilder(name, ptype, defaults, p_bounds, ...
                                  varargin);

end