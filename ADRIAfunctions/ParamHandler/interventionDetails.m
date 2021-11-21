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
    %  "sims";
    % "RCP"
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
    %  50;  % sims
    % 60  % RCP
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
    % 85  % RCP
};

ptype = [
    "integer";
    "integer";
    "float";
    "float";
    "integer";
    "integer";
    "float";
    "integer";
    "integer";
    % "categorical";
];


interventions = paramTableBuilder(name, ptype, defaults, p_bounds);

% if number of arguments passed in is 0, then use default values
% otherwise replace defaults with specified values
if nargin > 0
    valid_names = name(:);
    for name_val = [varargin(1:2:end); varargin(2:2:end)]
        [name, val] = name_val{:};
        if isempty(find(contains(valid_names, name), 1))
            error("Intervention option '%s' is invalid", name)
        end
        
        interventions{interventions.name == name, "defaults"} = {val};
    end
end

end