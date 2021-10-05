function [LP1,LP2,LP3,LP4] = ADRIA_larvalprod(tstep,parms,stresspast,LPdhwcoeff,DHWmaxtot,LPDprm2)

%dhw = structDHW.dhwdisttime; % size: 30 time steps by 26 sites
ad = parms.assistadapt + tstep.*parms.natad; % +tstep*parms.natad;

LP1 = 1-exp(-(exp(-LPdhwcoeff*(stresspast.DHWpast*(1-ad(1)/DHWmaxtot)-LPDprm2))));
LP2 = 1-exp(-(exp(-LPdhwcoeff*(stresspast.DHWpast*(1-ad(2)/DHWmaxtot)-LPDprm2))));
LP3 = 1-exp(-(exp(-LPdhwcoeff*(stresspast.DHWpast*(1-ad(3)/DHWmaxtot)-LPDprm2))));
LP4 = 1-exp(-(exp(-LPdhwcoeff*(stresspast.DHWpast*(1-ad(4)/DHWmaxtot)-LPDprm2))));
end
