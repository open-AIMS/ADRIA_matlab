function Y = coralEvennessADRIA(covers)  

% Inputs:
%  covers: structure
%  covers.all: array.  Dims: timesteps, species, sites, interventions, sims 
%  covers.tab_acr: array. Dims: timesteps, sites, interventions, sims 
%  covers.cor_acr: array. Dims: timesteps, sites, interventions, sims 
%  covers.sml_enc: array. Dims: timesteps, sites, interventions, sims 
%  covers.lrg_mas: array. Dims: timesteps, sites, interventions, sims
%  covers.TC = TC; array. Dims: timesteps, sites, interventions, sims 

% Calculates evenness across functional coral groups in ADRIA

% filter negative values and values >1
covers.all = min( max(covers.all, 0), 1);

% Functional diversity metric 
n = 4; %number of taxa
p1 = squeeze(sum(covers.tab_acr,2))./covers.TC;
p2 = squeeze(sum(covers.cor_acr,2))./covers.TC;
p3 = squeeze(sum(covers.sml_enc,2))./covers.TC;
p4 = squeeze(sum(covers.lrg_mas,2))./covers.TC;
sumpsqr = (p1.^2 + p2.^2 + p3.^2 + p4.^2).^(1-(1-2)); %functional diversity
simpsonD = 1./sumpsqr; % Hill 1973, Ecology 54:427-432
Y = simpsonD./n;  %Group evenness 
end
   




