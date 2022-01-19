function Y = coralSpeciesCover(X, ~)
% Converts outputs from coralScenario to relative cover of the six
% different coral groups
%
% Input: 
%   X : array, of coralScenario results
%       Dimensions: time, species, sites, interventions, sims

[nsteps, ~, nsites] = size(X);
Y = zeros(nsteps, 6, nsites);  % TODO: Remove hardcoded `6` value...
for sp = 1:6
    Y(:,sp,:) = sum(X(:,6*sp-5:sp*6,:), 2);
end

end
