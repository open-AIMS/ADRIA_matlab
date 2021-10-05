function Y = ADRIA_bleachingmortalityfun(tstep,parms,dhw)
%Gompertz cumulative mortality function 
%partial calibration using data by Hughes et al 2018 (Fig. 2C)
ad = parms.assistadapt +tstep.*parms.natad;

Y(1) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(1))))); %sp1
Y(2) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(2))))); %sp2
Y(3) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(3))))); %sp3
Y(4) = exp(-parms.p(1)*(exp(-parms.p(2)*(dhw-ad(4))))); %sp4
end

