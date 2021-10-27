function DHWdisttime = ADRIA_DHWprojectfun(tf,nsites,mdhwdist0,sdhwdist0,dhwmax25,RCP,wb1,wb2)
% Generates time sequence of Degree Heating Weeks for all sites
%
% Inputs: 
%     tf        : int, number of time steps to generate
%     nsites    : int, number of sites to generate time sequence for
%     mdhwdist0 : float, mean of DHW distribution
%     sdhwdist0 : float, standard deviation of DHW distribution
%     dhwmax25  : float, Maximum DHW at year 2025
%     RCP       : int, RCP scenario
%     wb1       : float, scale `a` for weibull distribution
%     wb2       : float, shape `b` for weibull distribution
%
% Outputs:
%     DHWdisttime : 
%         2D table of (timestep, nsites) indicating DHWs for each site

% RCP heatrates
if RCP == 26
    heatrate = 0.2;
elseif RCP == 45
    heatrate = 0.3;
elseif RCP == 60
    heatrate = 0.5;
elseif RCP == 6085
    heatrate = 0.75;
elseif RCP == 85
    heatrate = 1.5;
end

DHW = ones(tf,nsites); %initialise
for t = 1:tf
    wblsample = wblrnd(wb1,wb2,1); % sample from under the maxDHW curve using the weibull distribution
    wblsample(wblsample>1) = 1;
    DHW(t,:) = wblsample*((dhwmax25 + normrnd(mdhwdist0,sdhwdist0))+heatrate*t);
end

DHW(DHW<0) = 0; 
DHWdisttime = DHW;

end %function