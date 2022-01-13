function Y = ADRIA_larvalprod(tstep, assistadapt, natad, stresspast, LPdhwcoeff, DHWmaxtot, LPDprm2)
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

tmp_ad = (1 - ad / DHWmaxtot);
Y = 1 - exp(-(exp(-LPdhwcoeff*(stresspast' .* tmp_ad - LPDprm2))))';

end
