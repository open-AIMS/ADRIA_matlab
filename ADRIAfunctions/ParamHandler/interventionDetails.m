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
%   option_bounds
%       where lower/upper bounds indicates the raw bound values
%       `options` maps option ids to their values, and
%       `option_bounds` indicates the min/max range of options ids.

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
lower_bound = {
    0;  % Guided
    1;  % PrSites
    0.0;  % Seed1
    0.0;  % Seed2
    0;  % SRM
    6;  % Aadpt
    0.01;  % Natad
    10;  % Seedyrs
    1;  % Shadeyrs
    % 60  % RCP
};

upper_bound = {
    1;  % Guided
    3;  % PrSites
    0.0010;  % Seed1
    1.0;  % Seed2
    1;  % SRM
    12;  % Aadpt
    0.1;  % Natad
    15;  % Seedyrs
    5;  % Shadeyrs
    % 85  % RCP
};

ptype = [
    "categorical";
    "categorical";
    "float";
    "float";
    "categorical";
    "categorical";
    "float";
    "categorical";
    "categorical";
    % "categorical";
];


interventions = paramTableBuilder(name, ptype, defaults, lower_bound, ...
                                  upper_bound);

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