function [LP1,LP2,LP3,LP4] = ADRIA_larvalprod(tstep, assistadapt, natad, stresspast, LPdhwcoeff, DHWmaxtot, LPDprm2)
% Project larval production for each coral type for the given time step.
%
% Inputs:
%    tstep : int,
%    assistadapt : array, DHW
%    natad : array, DHWs per year for all species
%    stresspast : array, DHW at previous time step for each site
%    LPdhwcoeff : float,
%    DHWmaxtot : int, maximum DHW
%    LPDprm2 : int, larval production parameter 2?
ad = assistadapt + tstep .* natad;

LP1 = 1-exp(-(exp(-LPdhwcoeff*(stresspast*(1-ad(1)/DHWmaxtot)-LPDprm2))));
LP2 = 1-exp(-(exp(-LPdhwcoeff*(stresspast*(1-ad(2)/DHWmaxtot)-LPDprm2))));
LP3 = 1-exp(-(exp(-LPdhwcoeff*(stresspast*(1-ad(3)/DHWmaxtot)-LPDprm2))));
LP4 = 1-exp(-(exp(-LPdhwcoeff*(stresspast*(1-ad(4)/DHWmaxtot)-LPDprm2))));

end
