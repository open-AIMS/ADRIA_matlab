function Y = coralEvenness(X, ~)
% Calculates evenness across functional coral groups in ADRIA
% Inputs:
%  results from coralScenario, array.  Dims: timesteps, species, sites, interventions, sims

% filter negative values and values >1
X = min(max(X, 0), 1);

covers = coralTaxaCover(X);

% Evenness as a functional diversity metric
n = 4; %number of taxa
p1 = squeeze(sum(covers.tab_acr, 2)) ./ covers.total_cover;
p2 = squeeze(sum(covers.cor_acr, 2)) ./ covers.total_cover;
p3 = squeeze(sum(covers.sml_enc, 2)) ./ covers.total_cover;
p4 = squeeze(sum(covers.lrg_mas, 2)) ./ covers.total_cover;
sumpsqr = p1.^2 + p2.^2 + p3.^2 + p4.^2; %functional diversity
simpsonD = 1 ./ sumpsqr; % Hill 1973, Ecology 54:427-432
Y = simpsonD ./ n; %Group evenness
end
