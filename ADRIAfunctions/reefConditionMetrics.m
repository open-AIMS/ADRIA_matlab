function [TC,C,E,S] = ReefConditionMetrics(covsim)
%
% ADRIA Reef Condition Metrics as indicators of scope for ecosystem 
% service provision
% Function converts the cover of four species to scope for providing 
% ecosystem services: cultural, provisioning and regulating (including 
% some supporting)
% out_ind = 1 : just calculate TC
% out_ind >1 : calculate other metrics

%% Preliminary estimates using only three species 
% 1: Total coral cover (relative)
% 2: Evenness as E = D/N, with D = (Sum(pi^2))^(1/(1-q), where q = 2 to
% reduce sensitivity to rare groups (Jost 2006)
% 3: Structural complexity, for now as S = relative cover of large Acropora.
% 4: Net reef accretion as total coral cover times net rate of reef
% calcification from eReefs
C = covsim; % dimensions: time, species, sites, interventions, sims 
TC = sum(C,2); %sum over species
C1 = C(:,1,:,:,:) + C(:,2,:,:,:); %Adding enhanced to unenhanced Acropora
C2 = C(:,3,:,:,:); %Coral species 2
C3 = C(:,4,:,:,:); %Coral species 3

%% Calculate Evenness
% Note that evenness may be replaced by other diversity metric 
n = 3; %number of species
p1 = C1./TC;
p2 = C2./TC;
p3 = C3./TC;
FuncDiv = (p1.^2 + p2.^2 + p3.^2).^(1-(1-2)); %functional diversity
E = FuncDiv./n; %evenness
E(E>1) = 1; %limit to 1, probably unnecessary
E = squeeze(E); %species dimension squeezed out

%% Calculate structural complexity
% Note that structural complexity will be replaced with functions that 
% display refuge volume and size distributions as a function of coral 
% composition and coral size classes 

S = C1; %use Acropora for now as proxy for structural complexity
S(S>1) = 1; %limit to 1
S = squeeze(S); %species dimension squeezed out
TC = squeeze(TC); %species dimension squeezed out

end
