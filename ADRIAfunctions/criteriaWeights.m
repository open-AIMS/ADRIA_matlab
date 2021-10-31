function criteria_weights = criteriaWeights(varargin)
% Create struct holding criteria weights
%
% Outputs:
%   criteria_weights : struct holding default and user specified weightings
%

%% ADRIA Criteria weights

%% Criteria Weights used in the selection of sites and interventions (min 0, max 1)
args = struct('wave_stress', 1, ...
              'heat_stress', 1, ...
              'shade_connectivity', 0, ...
              'seed_connectivity', 0, ...
              'coral_cover_high', 0, ...
              'coral_cover_low', 0, ...
              'seed_priority', 1, ...
              'shade_priority', 0, ...
              'deployed_coral_risk_tol', 1);

% if number of arguments passed in is 0, then use default values
% otherwise replace defaults with specified values
if nargin > 0
    valid_names = fieldnames(args);
    for name_val = [varargin(1:2:end); varargin(2:2:end)]
        [name, val] = name_val{:};
        if isempty(find(contains(valid_names, name), 1))
            error("Criteria option '%s' is invalid", name)
        end

        args.(name) = val;
    end
end



% Avoid Wave Stress:
criteria_weights(:,1) = args.wave_stress;
% Avoid Heat Stress: 
criteria_weights(:,2) = args.heat_stress;
% Account for Connectivity (Centrality) when Shading or Cooling:
criteria_weights(:,3) = args.shade_connectivity;
% Account for Connectivity (Centrality) when Seeding:
criteria_weights(:,4) = args.seed_connectivity;
% Intervene where Coral Cover is High:
criteria_weights(:,5) = args.coral_cover_high;
% Intervene where Coral Cover is Low:
criteria_weights(:,6) = args.coral_cover_low;
% Seed at Strongest Sources for Priority Sites:
criteria_weights(:,7) = args.seed_priority; 
% Shade at Strongest Sources for Priority Sites:
criteria_weights(:,8) = args.shade_priority;
% Risk Tolerance wrt Deployed Corals:
criteria_weights(:,9) = args.deployed_coral_risk_tol;

end