function Y = ADRIA_bleachingMortality(tstep,parms,dhw)
% Gompertz cumulative mortality function 
%
% Partial calibration using data by Hughes et al [1] (see Fig. 2C)
%
% Inputs:
%     tstep : int, current time step
%     parms : ?
%     dhw   : float, degree heating weeks for given time step
%
% Output:
%     Y : Array[4, float], bleaching mortality for each coral species
%
% References:
%     1. Hughes, T.P., Kerry, J.T., Baird, A.H., Connolly, S.R., 
%           Dietzel, A., Eakin, C.M., Heron, S.F., Hoey, A.S., 
%           Hoogenboom, M.O., Liu, G., McWilliam, M.J., Pears, R.J., 
%           Pratchett, M.S., Skirving, W.J., Stella, J.S. 
%           and Torda, G. (2018) 
%        'Global warming transforms coral reef assemblages', 
%        Nature, 556(7702), pp. 492–496. 
%        doi:10.1038/s41586-018-0041-2.
ad = parms.assistadapt +tstep.*parms.natad;

Y(1) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(1))))); %sp1
Y(2) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(2))))); %sp2
Y(3) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(3))))); %sp3
Y(4) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(4))))); %sp4
end

