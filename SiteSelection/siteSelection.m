function sitesloc = siteSelection(site,rubble,cyclonerisk,routwaverisk,minDepth)
%
% Find viable sites within selected zone
%
% Input: 
%   site: reef site (string)
%   rubble: if rubbles are considered for potential sites (boolean)
%   cyclonerisk = wave risk tolerance for deployement (from cyclone 70th
%   percentile) (float between 0 and 1)
%   routwaverisk = wave risk tolerance for coral survival (from routine 70th
%   percentile) (float between 0 and 1)
%
% Output:
%   sitesloc = location of sites (lon/lat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<4
    routwaverisk = 0.8;
end
if nargin<3
    cyclonerisk = 0.8;
end
if nargin<2
    rubble = 0;
end
if nargin <1
    site = 'Moore';
end

% Files location
fileloc = ['Inputs/',site];

%% Get bathymetry
[bathy,R] = geotiffread([fileloc,'/SiteSelection/depth.tif']);
bathy(bathy<-900)=NaN;
latlim = R.LatitudeLimits;
lonlim = R.LongitudeLimits;
latbathy = latlim(1)+R.CellExtentInLatitude/2:R.CellExtentInLatitude:latlim(2);
lonbathy = lonlim(1)+R.CellExtentInLongitude/2:R.CellExtentInLongitude:lonlim(2);

%% Get benthic maps from the Allen's map
% Use these as the default grid to work on as they cover the full domain
load([fileloc,'/benthicMasks.mat'],'CoralAlgae','Rock','Rubble','lat','lon')
latbenthic = lat;
lonbenthic = lon;

%% Get viable locations for coral from Ben (AIMS Perth)
[coralLoc,Rcor] = geotiffread([fileloc,'/coral_exists_ben/coral_exists_ben.tif']);
coralLoc(coralLoc<0)=NaN;
latlim = Rcor.LatitudeLimits;
lonlim = Rcor.LongitudeLimits;
latcorloc = latlim(1)+Rcor.CellExtentInLatitude/2:Rcor.CellExtentInLatitude:latlim(2);
loncorloc = lonlim(1)+Rcor.CellExtentInLongitude/2:Rcor.CellExtentInLongitude:lonlim(2);

%% Routine wave height 70th percentile (for coral stress)
[rwaveh70,R] = geotiffread([fileloc,'/SiteSelection/hs70r.tif']);
rwaveh70(rwaveh70<0)=NaN;
% **Definitely incorrect coordinate, will use the commented lines once I have
% the correct files, but for the moment I'm just using a workaround to have
% working code**
latlim = R.LatitudeLimits;
lonlim = R.LongitudeLimits;
latrwaveh = latlim(1)+R.CellExtentInLatitude/2:R.CellExtentInLatitude:latlim(2);
lonrwaveh = lonlim(1)+R.CellExtentInLongitude/2:R.CellExtentInLongitude:lonlim(2);
% latrwavehT = latlim(1)+Rcor.CellExtentInLatitude:Rcor.CellExtentInLatitude*2:latlim(2);
% lonrwavehT = lonlim(1)+Rcor.CellExtentInLongitude:Rcor.CellExtentInLongitude*2:lonlim(2);
% latrwaveh = latrwavehT(1:size(rwaveh70,1));
% lonrwaveh = lonrwavehT(1:size(rwaveh70,2));

%% Routine bottom pressure 70th percentile
% [rbotpres70,R] = geotiffread([fileloc,'/SiteSelection/ub_r.tif']);
% rbotpres70(rbotpres70<0)=NaN;
% % **Definitely incorrect coordinate, will use the commented lines once I have
% % the correct files, but for the moment I'm just using a workaround to have
% % working code**
% % latlim = R.YWorldLimits;
% % lonlim = R.XWorldLimits;
% % latrbotpres = latlim(1)+R.CellExtentInWorldY/2:R.CellExtentInWorldY:latlim(2);
% % lonrbotpres = lonlim(1)+R.CellExtentInWorldX/2:R.CellExtentInWorldX:lonlim(2);
% latrbotpresT = latlim(1)+Rcor.CellExtentInLatitude:Rcor.CellExtentInLatitude*2:latlim(2);
% lonrbotpresT = lonlim(1)+Rcor.CellExtentInLongitude:Rcor.CellExtentInLongitude*2:lonlim(2);
% latrbotpres = latrbotpresT(1:size(rbotpres90,1));
% lonrbotpres = lonrbotpresT(1:size(rbotpres90,2));

%% Cyclone wave duration return times of 10 years (capable of damaging most vulnerable
%% colonies (height>= 4m)
[cwaved10,R] = geotiffread([fileloc,'/SiteSection_OnlyMoore/geoTIFF_ADRIA/dt_rt10.tif']);
cwaved10(cwaved10<0)=NaN;
% **Definitely incorrect coordinate, will use the commented lines once I have
% the correct files, but for the moment I'm just using a workaround to have
% working code**
% latlim = R.YWorldLimits;
% lonlim = R.XWorldLimits;
% latcyclw = latlim(1)+R.CellExtentInWorldY/2:R.CellExtentInWorldY:latlim(2);
% loncyclw = lonlim(1)+R.CellExtentInWorldX/2:R.CellExtentInWorldX:lonlim(2);
latcyclwT = latlim(1)+Rcor.CellExtentInLatitude:...
    (latlim(2)-(latlim(1)+Rcor.CellExtentInLatitude))/size(cwaved10,1):latlim(2);
loncyclwT = lonlim(1)+Rcor.CellExtentInLongitude:...
    (lonlim(2)-(lonlim(1)+Rcor.CellExtentInLongitude))/size(cwaved10,2):lonlim(2);
latcyclw = latcyclwT(1:size(cwaved10,1));
loncyclw = loncyclwT(1:size(cwaved10,2));

%% Cyclone bottom pressure return times of 10 years
% [cycbotpres10,R] = geotiffread([fileloc,'/geoTIFF_ADRIA/hs_rt10.tif']);
% cycbotpres10(cycbotpres10<0)=NaN;
% % **Definitely incorrect coordinate, will use the commented lines once I have
% % the correct files, but for the moment I'm just using a workaround to have
% % working code**
% % latlim = R.YWorldLimits;
% % lonlim = R.XWorldLimits;
% % latcycbotpres = latlim(1)+R.CellExtentInWorldY/2:R.CellExtentInWorldY:latlim(2);
% % loncycbotpres = lonlim(1)+R.CellExtentInWorldX/2:R.CellExtentInWorldX:lonlim(2);
% latcycbotpresT = latlim(1)+Rcor.CellExtentInLatitude:Rcor.CellExtentInLatitude*2:latlim(2);
% loncycbotpresT = lonlim(1)+Rcor.CellExtentInLongitude:Rcor.CellExtentInLongitude*2:lonlim(2);
% latcycbotpres = latcycbotpresT(1:size(cycbotpres10,1));
% loncycbotpres = loncycbotpresT(1:size(cycbotpres100,2));

%% Interpolate on the same grid
% Find smaller domains limits within our default grid
[~,xmin] = min(abs(lonlim(1)-lonbenthic));
[~,ymin] = min(abs(latlim(1)-latbenthic));
[~,xmax] = min(abs(lonlim(2)-lonbenthic));
[~,ymax] = min(abs(latlim(2)-latbenthic));

% Interpolate the grids onto the default working grid
% Make mesh grids
[meshlonbentsmaller,meshlatbentsmaller] = meshgrid(lonbenthic(xmin:xmax),latbenthic(ymin:ymax));
[meshlonbent,meshlatbent] = meshgrid(lonbenthic,latbenthic);
[meshloncor,meshlatcor] = meshgrid(loncorloc,latcorloc);
[meshlonbathy,meshlatbathy] = meshgrid(lonbathy,latbathy);
[meshlonwh,meshlatwh] = meshgrid(lonrwaveh,latrwaveh);
%[meshlonbp,meshlatbp] = meshgrid(lonrbotpres,latrbotpres);
[meshloncd,meshlatcd] = meshgrid(loncyclw,latcyclw);
%[meshloncbp,meshlatcbp] = meshgrid(loncycbotpres,latcycbotpres);

coralLocint = interp2(meshloncor,meshlatcor,single(coralLoc),meshlonbentsmaller,meshlatbentsmaller);
bathyint = interp2(meshlonbathy,meshlatbathy,bathy,meshlonbent,meshlatbent);
rwaveh70int = interp2(meshlonwh,meshlatwh,rwaveh70,meshlonbent,meshlatbent);
%rbotpres90int = interp2(meshlonbp,meshlatbp,rbotpres90,meshlonbent,meshlatbent);
cwaved10int = interp2(meshloncd,meshlatcd,cwaved10,meshlonbentsmaller,meshlatbentsmaller);
%cbotpres10int = interp2(meshloncbp,meshlatcbp,cycbotpres10,meshlonbent,meshlatbent);
clear mesh*

% Because the coral presence mask was interpolated, it's not a boolean mask
% anymore, we define as 1 if >=0.5 or 0 otherwise.
coralLocint(coralLocint>=0.5) = 1;
coralLocint(coralLocint<0.5) = 0;

%% Mask non coral-viable locations
if rubble
    potentialsites = CoralAlgae+Rock+Rubble;
else
    potentialsites = CoralAlgae+Rock;
end

% Add locations from Ben's map
potentialsites(xmin:xmax,ymin:ymax) = potentialsites(xmin:xmax,ymin:ymax) + coralLocint';
potentialsites(potentialsites>1)=1;

%% Mask bathymetry too shallow
% Change for > MLD eventually
potentialsites(bathyint>-minDepth) = 0;

%% Mask routine coral wave stress risk according to risk tolerance
% Build a cumulative normal distribution with the wave height
meanwh = nanmean(nanmean(rwaveh70int));
stdwh = std(rwaveh70int,0,[1 2],'omitnan');
riskwh = normcdf(0:0.001:2,meanwh,stdwh);
% Find the cutoff height
[~,cutoff] = min(abs(riskwh-routwaverisk));

wavehmask = zeros(size(rwaveh70int));
wavehmask(normcdf(rwaveh70int,meanwh,stdwh)<=routwaverisk)=1;

potentialsites = potentialsites.*wavehmask';

%% Mask coral cyclone wave stress according to risk tolerance
% Build a cumulative normal distribution with the cyclone wave stress
% duration
meancwd = nanmean(nanmean(cwaved10int));
stdcwd = std(cwaved10int,0,[1 2],'omitnan');
%riskcwd = normcdf(0:0.1:30,meancwd,stdcwd);
% Find the cutoff height
%[~,cutoff] = min(abs(riskcwd-cyclonerisk));

cwavedmask = zeros(size(cwaved10int));
cwavedmask(normcdf(cwaved10int,meancwd,stdcwd)<=cyclonerisk)=1;

potentialsites(xmin:xmax,ymin:ymax) = potentialsites(xmin:xmax,ymin:ymax).*cwavedmask';

%% Select sites in what's left by selecting only the centre of a bunch of 
%% adjacent grid cells (from wave height)

%% TO BE IMPROVED

% In the meantime just take what's left
[xx,yy] = find(potentialsites==1);
sitesloc = ones(length(xx),2)*NaN;
for i = 1:length(xx)
    sitesloc(i,1) = lonbenthic(xx(i));
    sitesloc(i,2) = latbenthic(yy(i));
end

