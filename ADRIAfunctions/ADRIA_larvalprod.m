function Y = ADRIA_larvalprod(tstep, assistadapt, natad, stresspast, LPdhwcoeff, DHWmaxtot, LPDprm2)
% Estimate how scope for larval production by each coral type changes as a 
% function of last year's heat stress. The function is theoretical and is 
% not yet verified by data. The rationale is that 

%
% Inputs:
%    tstep : int,
%    assistadapt : array, DHW
%    natad : array, DHWs per year for all species
%    stresspast : array, DHW at previous time step for each site
%    LPdhwcoeff : float,
%    DHWmaxtot : int, maximum DHW
%    LPDprm2 : int, larval production parameter 2
% Output:  
%    array of ngroups by nsites

ad = assistadapt + tstep .* natad;

tmp_ad = (1 - ad / (DHWmaxtot/2)); %using half of DHWmaxtot as a placeholder 
% for the maximum capacity for thermal adaptation 

% one way around dimensional issue - tmp_ad for each class as the averaged
% % of the enhanced and unenhanced corals in that class
tmp_ad2 = mean(reshape(tmp_ad,length(tmp_ad)/6,6));
% KA note: this works as it averages over size classes and not across groups.  

Y = 1 - exp(-(exp(-LPdhwcoeff*(stresspast .* tmp_ad2' - LPDprm2))));
end
