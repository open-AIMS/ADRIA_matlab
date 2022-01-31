function dhw = makeDhwProjection(tf, resdhwsites, dhwmax25, RCP, wb1, wb2, sims)

% Make DHW data for sites for projections
% Generates time sequence of Degree Heating Weeks for all sites.
% Builds on forward projections of max DHWs from trends in climate models. 
% Temporal patterns in DHW were simulated by fitting a weibul distribution to historical DHW data by 
% Lough et al. 2018, essentially sampling under the DHW max curve.
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

% Proxy RCP heatrates for maximum DHW (as DHWs per year). They coarsely represent trends based on regressions fitted to NOAA's ESM for the GBR (ref to come).   
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

nsites = size(resdhwsites,1);

mdhwdist0 = mean(resdhwsites(:,5:7),2)'; %mean residual dhw at sites
    sdhwdist0 =std(resdhwsites(:,5:7),0,2)'; %standard deviation of residual dhws at sites
    dhwdisttime = zeros(tf,nsites); %initialise matrix that represents projections of DHW in space and time
    
% sample from under the maxDHW curve using the weibull distribution, and
% project for tf years and 
for sim = 1:sims
dhw(:,:, sim) = min(wblrnd(wb1, wb2, tf, 1), 1.0) ...
    .* (dhwmax25 + normrnd(repmat(mdhwdist0, tf, 1), repmat(sdhwdist0, tf, 1))...
    + heatrate*(1:tf)');  % tf, nsites
end 
dhw(dhw < 0) = 0;

Y = dhw;

save MooreSiteDHW dhwRCP45;
end %function