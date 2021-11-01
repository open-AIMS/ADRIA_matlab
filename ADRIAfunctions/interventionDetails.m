function interventions = interventionDetails(varargin)
% Detail intervention parameters value and expected ranges.
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
    [6, 12];  % Aadpt
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


% build categorical options
opts(1:length(ptype)) = {NaN};
for i = 1:length(ptype)
    if ptype(i) ~= "categorical"
        % opts(i) = lower_bound(i):upper_bound(i);
        % opts(i) = {NaN};
        continue
    end
    
%     if name(i) == "RCP"
%         % handle RCP specific options
%         opts{i} = {containers.Map(1:4, [45, 60, 6085, 85])};
%         continue
%     end
    
    if length(lower_bound{i}) > 1
        % opts(i) = paramCombinations({cell2mat(lower_bound(i)); cell2mat(upper_bound(i))});
        % opts(i) = paramCombinations({lower_bound(i); upper_bound(i)});
        t = [lower_bound{i}; upper_bound{i}]';
        tmp = paramCombinations({t(1, :); t(2, :)});
        opts{i} = {containers.Map(1:length(tmp), tmp)};
    else
        opts{i} = {paramCombinations({lower_bound{i}:upper_bound{i}})};
    end
end

options = opts';

% build option bounds
option_bounds(1:length(ptype)) = {NaN};
for i = 1:length(options)
    try
        option_bounds{i} = [1, length(options{i}{1})];
    catch
        option_bounds{i} = [lower_bound{i}, upper_bound{i}];
    end
end

option_bounds = option_bounds';

interventions = table(name, ptype, defaults, lower_bound, upper_bound, options, option_bounds);

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