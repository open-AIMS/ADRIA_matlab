function DHWdatacube = DHW_simproj
%
% Reads MIROC5 2021-2099 DHW projections and creates some simulated
% timeseries projections with a stochastic element.
%
% Input:
%   siteloc: site locations in lat/lon (sites,coord)
%
% Output:
%   DHWdatacube: maximum annual DHW for a number of simulation of
%       timeseries in the data format (time in years, sites lat/lon, 
%       simulation)
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% the following code is to test this function or run it independantly
BrickCluster = readmatrix('Brick\Brick_Cluster_Spatial.csv');
siteloc(:,1) = BrickCluster(:,9);
siteloc(:,2) = BrickCluster(:,8);

%RCPs = {'2.6','4.5','6.0','8.5'};
RCPs = {'4.5','6.0','8.5'};
for rcpi = 1:length(RCPs)
    RCP = RCPs{rcpi};
    disp(['RCP: ',RCP])

%% Define the timeserie
years = 2026:1:2099;
%% Define the number of simulations (includes the first one being the
%% MIROC5 projection directly)
nsim = 50;

%% Define which RCP scenario in the format used for the MIROC5 data files
switch RCP
    case '2.6'
        RCPname = '26';
    case '4.5'
        RCPname = '45'; 
    case '6.0'
        RCPname = '60';
    case '8.5'
        RCPname = '85';
end

% Initialise output data matrix
DHWdatacube = zeros(length(years),size(siteloc,1),50);

%% Get the spatial pattern from four years of RECOM's run
for yearDHW = [2015:2017,2019]

    nc = netcdf.open(['brick_',num2str(yearDHW),'_dhw_surf.nc'],'NC_NOWRITE');
    eval(['DHWBrick',num2str(yearDHW),' = netcdf.getVar(nc,netcdf.inqVarID(nc,''dhw0''));']);
    netcdf.close(nc)

end
% Make spatial average for the maximum annual those years
dhwPattern = (max(squeeze(DHWBrick2015(:,:,1,:)),[],3)+...
    max(squeeze(DHWBrick2016(:,:,1,:)),[],3)+...
    max(squeeze(DHWBrick2017(:,:,1,:)),[],3)+...
    max(squeeze(DHWBrick2019(:,:,1,:)),[],3))./4;
clear DHWBrick2*

%% get the Brick cluster's lat/lon
nc = netcdf.open('Brick\BrickBoundaries.nc');
bricklat = netcdf.getVar(nc,netcdf.inqVarID(nc,'lat'));
bricklon = netcdf.getVar(nc,netcdf.inqVarID(nc,'lon'));
netcdf.close(nc)

% For each site, define the DHW density probability function around a trend
% defined by the MIROC5 projection
% Make nsim simulated projection with a stochastic element.
for sitei = 1:size(siteloc,1)

    disp(['Site: ',num2str(sitei),'/',num2str(size(siteloc,1))])
    % Define the density probability function
    [densprob,pMIROC5,MIROC5proj] = getDHWtrendenv(RCPname,squeeze(siteloc(sitei,:)));

    %% Find the RECOM's cells closest to the site and adjust the probability's 
    %% mean according to the variation from the mean for a part of the 
    %% domain that this cell is. (The whole domain gives too large 
    %% variations and would be domain-dependant, which isn't reasonable, 
    %% by taking a small domain around the RECOM cell, it's like accounting
    %% for the difference in resolution for the data used to produce the 
    %% density probability. Although, this method could be improved)
    % Find closest data to our site's coordinates
    distgrid = distance(bricklat,bricklon,siteloc(sitei,1),siteloc(sitei,2));
    [indx,indy] = find(min(min(distgrid))==distgrid);

    % Domain size to adjust for (in number of grid cells on each side of the location cell)
    domsz = 5; % a domsz of 3 means a 7x7 box, domsz of 2 means a 5x5 box, etc.
    % Unfortunately, some sites are too close to the edge, even with a
    % domsz=2, so I need to cut at the edge for those
    if indx+domsz>size(dhwPattern,1) && indy+domsz>size(dhwPattern,2)
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(indx-domsz:size(dhwPattern,1),indy-domsz:size(dhwPattern,2))));
    elseif indx+domsz>size(dhwPattern,1) && indy-domsz<1
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(indx-domsz:size(dhwPattern,1),1:indy+domsz)));
    elseif indx+domsz>size(dhwPattern,1)
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(indx-domsz:size(dhwPattern,1),indy-domsz:indy+domsz)));
    elseif indx-domsz<1 && indy+domsz>size(dhwPattern,2)
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(1:indx+domsz,indy-domsz:size(dhwPattern,2))));
    elseif indx-domsz<1 && indy-domsz<1
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(1:indx+domsz,1:indy+domsz)));
    elseif indx-domsz<1
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(1:indx+domsz,indy-domsz:indy+domsz)));
    elseif indy+domsz>size(dhwPattern,2)
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(indx-domsz:indx+domsz,indy-domsz:size(dhwPattern,2))));
    elseif indy-domsz<1
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(indx-domsz:indx+domsz,1:indy+domsz)));
    else
        spatialadj = dhwPattern(indx,indy)-nanmean(nanmean(dhwPattern(indx-domsz:indx+domsz,indy-domsz:indy+domsz)));
    end
    %% The first timeserie needs to be the MIROC5 exact projection
    DHWdatacube(:,sitei,1) = MIROC5proj(years(1)-2021+1:years(end)-2021+1);

    %% Produce other simulations timeseries
    % Superimpose the density probability function over the mean trend in
    % the MIROC5 projection and take a random number inside this enveloppe
    for simi = 2:nsim
        for yeari = years(1):years(end)

            DHWdatacube(yeari-years(1)+1,sitei,simi) = random(densprob)+...
                (pMIROC5(1)*yeari+pMIROC5(2))+spatialadj;

        end
    end

%     %% Plot the range of simulations for this site
%     close all
%     scrsz = get(0,'Screensize');
%     figure('Color','w','Position',...
%         [scrsz(1)+scrsz(3)/10 scrsz(2)+scrsz(4)/10 7*scrsz(3)/10 7*scrsz(4)/10])
%     hold on
%     for simi = 2:nsim
%         plot(years,squeeze(DHWdatacube(:,sitei,simi)),'LineWidth',1);
%     end
%     plot(years,MIROC5proj(years(1)-2021+1:years(end)-2021+1),'k','LineWidth',2.5);
%     title(['Annual Maximum DHW projection at site ',num2str(sitei),' for ',num2str(nsim),' simulations (thick black line is MIROC5)'])
%     ylabel('DHW (^oC weeks)')
%     xlabel('Years')
%     set(gca,'LineWidth',1.5,'FontSize',14)
%     set(gca,'XLim',[years(1) years(end)])
% 
%     figsave = gcf;
%     saveas(figsave,['Brick\Site',num2str(sitei),'_Brick_',num2str(nsim),'sims_',num2str(years(1)),'_',num2str(years(end)),'.png'])


end % Loop on sites
lat = siteloc(:,1);
lon = siteloc(:,2);
save(['Brick\DHW_Brick_',RCPname],'DHWdatacube','lat','lon')

end %loop on RCPs