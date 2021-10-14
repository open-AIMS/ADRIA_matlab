function CrtWts0 = CriteriaWeights

%% ADRIA Criteria weights

%% Criteria Weights used in the selection of sites and interventions (min 0, max 1)

% Avoid Wave Stress:
CrtWts0(:,1) = 1;
% Avoid Heat Stress: 
CrtWts0(:,2) = 1;
% Account for Connectivity (Centrality) when Shading or Cooling:
CrtWts0(:,3) = 0;
% Account for Connectivity (Centrality) when Seeding:
CrtWts0(:,4) = 0;
% Intervene where Coral Cover is High:
CrtWts0(:,5) = 0;
% Intervene where Coral Cover is Low:
CrtWts0(:,6) = 0;
% Seed at Strongest Sources for Priority Sites:
CrtWts0(:,7) = 1; 
% Shade at Strongest Sources for Priority Sites:
CrtWts0(:,8) = 0;
% Risk Tolerance wrt Deployed Corals:
CrtWts0(:,9) = 1;
end