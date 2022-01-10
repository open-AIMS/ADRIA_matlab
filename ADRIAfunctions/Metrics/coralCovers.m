function Y = coralCovers(X)
%
% ADRIA Reef Condition Metrics as indicators of scope for ecosystem 
% service provision
% Function converts the cover of four species to scope for providing 
% ecosystem services: cultural, provisioning and regulating (including 
% some supporting)

% covsim dimensions: time, species, sites, interventions, sims 


%% Preliminary estimates using only three species 
% 1: Total coral cover (relative)
% 
TC = squeeze(sum(X,2)); %sum over all species and size classes
C1 = X(:,1:6,:,:,:) + X(:,7:12,:,:,:); %Adding enhanced to unenhanced tabular Acropora
C2 = X(:,13:18,:,:,:) + X(:,19:24,:,:,:); %Adding %enhanced to unenhanced corymbose Acropora 
C3 = X(:,25:30,:,:,:); %Encrusting and small massives 
C4 = X(:,31:36,:,:,:); %Large massives 

Y.all = X; 
Y.tab_acr = C1;
Y.cor_acr = C2;
Y.sml_enc = C3;
Y.lrg_mas = C4;
Y.TC = TC;

end
