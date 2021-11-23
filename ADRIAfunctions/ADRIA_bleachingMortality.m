function Y = ADRIA_bleachingMortality(tstep, n_p1, n_p2, a_adapt, n_adapt, dhw) %NOTATION HERE IS INCONSISTENT WITH THAT IN LINES 221-223 OF MAIN SCRIPT WHERE THE FUNCTION IS CALLED 
% Gompertz cumulative mortality function 
%
% Partial calibration using data by Hughes et al [1] (see Fig. 2C)
%
% Inputs:
%     tstep   : int, current time step
%     n_p1    : float, Gompertz distribution shape parameter 1
%     n_p2    : float, Gompertz distribution shape parameter 2
%     a_adapt : array[sp*2, float], assisted adaptation
%                 where `sp` is the number of species considered
%     n_adapt : array[sp*2, float], assisted adaptation
%                 where `sp` is the number of species considered
%     dhw     : float, degree heating weeks for given time step
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
ad = a_adapt + tstep .* n_adapt;
Y = exp(n_p1 * (exp(n_p2 * (dhw - ad) )));

end

