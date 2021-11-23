function Y = ADRIA_bleachingMortality(tstep, g_shape, a_adapt, n_adapt, dhw)
% Gompertz cumulative mortality function 
%
% Partial calibration using data by Hughes et al [1] (see Fig. 2C)
%
% Inputs:
%     tstep   : int, current time step
%     g_shape : array[2, float], Gompertz distribution shape parameters 
%                 (1 and 2)
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
n_species = length(ad);
neg_p1 = -g_shape(1);
neg_p2 = -g_shape(2);

Y = zeros(1, n_species);
for sp = 1:n_species
    Y(sp) = exp(neg_p1*(exp(neg_p2 * (dhw - ad(sp)))));
end

end

