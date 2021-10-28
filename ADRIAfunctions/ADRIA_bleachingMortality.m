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
%     1. Hughes, T.P., Anderson, K.D., Connolly, S.R., Heron, S.F., 
%           Kerry, J.T., Lough, J.M., Baird, A.H., Baum, J.K., 
%           Berumen, M.L., Bridge, T.C., Claar, D.C., Eakin, C.M., 
%           Gilmour, J.P., Graham, N.A.J., Harrison, H., Hobbs, J.-P.A., 
%           Hoey, A.S., Hoogenboom, M., Lowe, R.J., McCulloch, M.T., 
%           Pandolfi, J.M., Pratchett, M., Schoepf, V., Torda, G. and 
%           Wilson, S.K. (2018) 
%           ‘Spatial and temporal patterns of mass bleaching of corals 
%               in the Anthropocene’, 
%           Science, 359(6371), pp. 80–83. 
%           doi:10.1126/science.aan8048.
ad = parms.assistadapt +tstep.*parms.natad;

Y(1) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(1))))); %sp1
Y(2) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(2))))); %sp2
Y(3) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(3))))); %sp3
Y(4) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(4))))); %sp4
end

