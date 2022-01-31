function Y = coralSpeciesCover(X, coral_params)
% Converts outputs from coralScenario to relative cover of the six
% different coral groups
%
% Input: 
%   X : array, of coralScenario results
%       Dimensions: time, species, sites, interventions, sims

[nsteps, ~, nsites, nint, nreps] = size(X);

% Get unique coral names to determine number of corals
tmp = split(string(coral_params.Properties.VariableNames)', "__");
tmp = regexp(tmp(:, 1), "\_[0-9]", "split", "once");
tmp = vertcat(tmp{:, 1});
coral_names = unique(vertcat(tmp(:, 1)));
n_corals = length(coral_names);

Y = zeros(nsteps, n_corals, nsites, nint, nreps);
for sp = 1:n_corals
    Y(:,sp,:,:,:) = sum(X(:,n_corals*sp-(n_corals-1):sp*n_corals,:,:,:), 2);
end

end
