function [densprob,pMIROC5,MIROC5proj] = getDHWtrendenv(RCPname,siteloc)
%
% THis function finds the closest location to a site and calculate an
% envelope of possible maximum DHW projected over time using 1985-2022 NOAA
% Coral Reef Watcher historical data and MIROC5 2021-2099 projection data 
% to evaluate the density probability of annual maximum DHW around mean DHW
% trend. The mean annual maximum DHW projection is evaluated from MIROC5
% 2022-2099 run for a given RCP scenario.
%
% Input:
%   RCP: RCP scenario considered (e.g. '2.6', '4.5', '6.0', '8.5')
%   siteloc: location of the site considered (lat,lon as a 2 element array)
%
% Output:
%   densprob: density probability of obtaining a given annual maximum DHW
%   value around an mean trend.
%   pMIROC5: polyfit trend for the MIROC5 projection
%   MIROC5proj: MIROC5 projection closest to this site
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get projection trend
load(['GBR_maxDHW_MIROC5_rcp',RCPname,'_2021_2099.mat'])
load('MIROC5reefs.mat')
reeflat = table2array(reefs(:,3));
reeflon = table2array(reefs(:,4));
clear reefs

% Find reef data closest to our site
[~,ind] = min(distance(reeflat,reeflon,siteloc(1),siteloc(2)));

% Remove duplicates
indunique = unique(ind);

dhwMIROC5site = squeeze(max_annual_DHW(indunique,:));
MIROC5proj = dhwMIROC5site; %for output

% Detrend the MIROC5 data
% I remove a linear trend, it could be  hanged for a more sophisticated
% evaluation of the mean trend using e.g. EOF
pMIROC5 = polyfit(2021:2099,dhwMIROC5site,1);
for i = 1:length(dhwMIROC5site)
    dhwMIROC5site(i) = dhwMIROC5site(i)-(pMIROC5(1)*(2021+i-1)+pMIROC5(2));
end

%% Get historical data enveloppe

% Get data grid for the NOAA DHW product
nc = netcdf.open('Obs\GBR_dhw_hist_noaa.nc');
dhwlat = netcdf.getVar(nc,netcdf.inqVarID(nc,'latitude'));
dhwlon = netcdf.getVar(nc,netcdf.inqVarID(nc,'longitude'));

% Find closest data to our site's coordinates
[~,indlat] = min(abs(dhwlat-siteloc(1)));
[~,indlon] = min(abs(dhwlon-siteloc(2)));

% If 2 or more cells are equidistant to our site
% location, take the first one (could be changed for the average, which
% would be more accurate but more complex)
if length(indlat)>1
    indlatT = indlat(1);
    clear indlat
    indlat = indlatT;
    clear indlatT
end
if length(indlon)>1
    indlonT = indlon(1);
    clear indlon
    indlon = indlonT;
    clear indlonT
end

% Get the DHW data for the cell selected for each year available (1985
% to 2022, but 1985 isn't complete)
dhwdatatot = netcdf.getVar(nc,netcdf.inqVarID(nc,'CRW_DHW')).*...
    netcdf.getAtt(nc,netcdf.inqVarID(nc,'CRW_DHW'),'scale_factor');
time = netcdf.getVar(nc,netcdf.inqVarID(nc,'time'));

netcdf.close(nc)

dhwdata = squeeze(dhwdatatot(indlat,indlon,:));

%% Find the maximum historical DHW for each year

% Convert the time array from 'seconds since 1981-01-01 00:00:00' into
% fractions of years
time_days = time/(60*60*24);
[year,~,~] = ymd(datetime('1981-01-01') + double(time_days));

% Initialise maxdhw for the number of years available
histmaxDHW = zeros(year(end)-year(1)+1,1);
timeyr = zeros(year(end)-year(1)+1,1);
for yeari = year(1):year(end)
    indyear = find(year==yeari);
    
    histmaxDHW(yeari-year(1)+1) = max(dhwdata(indyear(:)));
    timeyr(yeari-year(1)+1) = yeari;
end

% Detrend the historical data
% I remove a linear trend, it could be  hanged for a more sophisticated
% evaluation of the mean trend using e.g. EOF
p = polyfit(timeyr,histmaxDHW,1);
for i = 1:length(histmaxDHW)
    histmaxDHW(i) = histmaxDHW(i)-(p(1)*timeyr(i)+p(2));
end

%% Put all the data together
maxDHWdetrend = zeros(length(histmaxDHW)+length(dhwMIROC5site),1);
maxDHWdetrend(1:length(histmaxDHW)) = histmaxDHW;
maxDHWdetrend(length(histmaxDHW)+1:length(histmaxDHW)+length(dhwMIROC5site)) = dhwMIROC5site;

%% Fit a distribution over these maxDHW
% Generalized Extreme value distribution
densprob =  fitdist(maxDHWdetrend,'gev');
