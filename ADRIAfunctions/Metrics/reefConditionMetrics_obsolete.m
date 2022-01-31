function [TC,C,E,S] = reefConditionMetrics(covsim)
%
% ADRIA Reef Condition Metrics as indicators of scope for ecosystem 
% service provision
% Function converts the cover of four species to scope for providing 
% ecosystem services: cultural, provisioning and regulating (including 
% some supporting)

%% Preliminary estimates using only three species 
% 1: Total coral cover (relative)
% 2: Evenness as E = D/N, with D = (Sum(pi^2))^(1/(1-q), where q = 2 to
% reduce sensitivity to rare groups (Jost 2006)
% 3: Structural complexity, for now as S = relative cover of large Acropora.
% 4: Net reef accretion as total coral cover times net rate of reef
% calcification from eReefs

C = covsim; % dimensions: time, species, sites, interventions, sims 
TC = sum(C,2); %sum over all species and size classes
C1 = C(:,1:6,:,:,:) + C(:,7:12,:,:,:); %Adding enhanced to unenhanced tabular Acropora
C2 = C(:,13:18,:,:,:) + C(:,19:24,:,:,:); %Adding %enhanced to unenhanced corymbose Acropora 
C3 = C(:,25:30,:,:,:); %Encrusting and small massives 
C4 = C(:,31:36,:,:,:); %Large massives 

%% Calculate Evenness
% Note that evenness may be replaced by other diversity metric 
n = 3; %number of species
p1 = C1./TC;
p2 = C2./TC;
p3 = C3./TC;
p4 = C4./TC;
FuncDiv = (p1.^2 + p2.^2 + p3.^2 + p4.^2).^(1-(1-2)); %functional diversity
E = FuncDiv./n; %evenness
E(E>1) = 1; %limit to 1, probably unnecessary
E = squeeze(E); %species dimension squeezed out

% TEMPORARY: Making metrics work with subset of new coral groups for now
E = squeeze(mean(E, 2));

%% Calculate structural complexity
% Note that structural complexity will be replaced with functions that 
% display refuge volume and size distributions as a function of coral 
% composition and coral size classes 

%The following will be replacedd by shelter volume functions developed for
%ReefMod
S = C1+C2+C4; %use tabular, corymbose and large massives as proxy for structural complexity
S(S>1) = 1; %limit to 1
S = squeeze(S); %species dimension squeezed out

% TEMPORARY: Making metrics work with subset of new coral groups for now
S = squeeze(mean(S, 2));

TC = squeeze(TC); %species dimension squeezed out

end
