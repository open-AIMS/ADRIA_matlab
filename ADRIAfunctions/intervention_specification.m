function [interventions] = intervention_specification(varargin)
% Create intervention struct that hold default choices
%
% Outputs:
%   interventions : struct holding default/modified intervention values
%

interventions = struct('Guided', [0,1], ...
                       'PrSites', 3, ...
                       'Seed1', [0, 0.0005, 0.0010], ...
                       'Seed2', 0, ...
                       'SRM', 0, ...
                       'Aadpt', [6, 12], ...
                       'Natad', 0.05, ...
                       'Seedyrs', 10, ...
                       'Shadeyrs', 1, ...
                       'sims', 50);

% if number of arguments passed in is 0, then use default values
% otherwise replace defaults with specified values
if nargin > 0
    valid_names = fieldnames(interventions);
    for name_val = [varargin(1:2:end); varargin(2:2:end)]
        [name, val] = name_val{:};
        if isempty(find(contains(valid_names, name), 1))
            error("Intervention option '%s' is invalid", name)
        end
        
        interventions.(name) = val;
    end
end

end