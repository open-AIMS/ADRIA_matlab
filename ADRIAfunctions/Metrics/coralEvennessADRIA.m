function Y = coralEvennessADRIA(covers)  

%%Calculate evenness across functional coral groups in ReefMod
% X dimensions: time, species, sites, interventions, sims 

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
   




