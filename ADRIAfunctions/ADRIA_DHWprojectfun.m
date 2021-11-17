function DHWdisttime = ADRIA_DHWprojectfun(tf,mdhwdist0,sdhwdist0,dhwmax25,RCP,wb1,wb2)
% Generates time sequence of Degree Heating Weeks for all sites.
% Builds on forward projections of max DHWs from trends in climate models. 
% Temporal patterns in DHW were simulated by fitting a weibul distribution to historical DHW data by 
% Lough et al. 2018, essentiallly sampling under the DHW max curve.
% Variation in the spatial distribution of observed DHWs in the three bleaching years was used
% to represent the spatio-temporal stochasticity among grid cells within and among bleaching years in the future. 
%
% Inputs: 
%     tf        : int, number of time steps to generate
%     nsites    : int, number of sites to generate time sequence for [now unused - derived from shape of mdhwdist]
%     mdhwdist0 : float, mean of DHW distribution
%     sdhwdist0 : float, standard deviation of DHW distribution
%     dhwmax25  : float, Maximum DHW at year 2025
%     RCP       : int, RCP scenario
%     wb1       : float, scale `a` for weibull distribution
%     wb2       : float, shape `b` for weibull distribution
%
% Outputs:
%     DHWdisttime : 
%         2D table of shape (tf, nsites) indicating DHWs for each site
%         across time

% Proxy RCP heatrates for maximum DHW. Represent trends based on regressions fitted to NOAA's ESM for the GBR (ref to come).   
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

DHWdisttime = min(wblrnd(wb1, wb2, tf, 1), 1.0) ...
    .* (dhwmax25 + normrnd(repmat(mdhwdist0, tf, 1), repmat(sdhwdist0, tf, 1))...
    + heatrate*(1:tf)');  % tf, nsites
DHWdisttime(DHWdisttime < 0) = 0;

% Below should be the equivalent of the above in a straight loop
% DHW = ones(tf,nsites); % initialise
% 
% for t = 1:tf
%     wblsample = wblrnd(wb1,wb2,1); % sample from under the maxDHW curve using the weibull distribution
%     wblsample(wblsample>1) = 1;
%     DHW(t,:) = wblsample*((dhwmax25 + normrnd(mdhwdist0,sdhwdist0))+heatrate*t);
% end
% 
% DHW(DHW<0) = 0; 
% DHWdisttime = DHW;

end %function