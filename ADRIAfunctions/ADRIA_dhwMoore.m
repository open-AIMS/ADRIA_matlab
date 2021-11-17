
function [resdhwsites,dhw_surf,z] = ADRIA_dhwMoore(~)

%% Extract DHD data for Moore Reef Cluster from Robson files

%% Load Moore sites
F0 = readtable('MooreSites.xlsx', 'PreserveVariableNames',true);
F0 = table2array(F0); %site IDs, lats and lons for all sites
SiteID = F0(:,1);  % running site ID for internal reference 
SiteAddress = F0(:,2);  %grid-cell locationin the grid defined by the RECOM and the netcdf files
nsites = numel(SiteID);
% xx = F0(:,3); %longitude
% yy = F0(:,4); %latitude

%% Load DHW data from marine heat waves (bleaching seasons) 
dhw16 = ncread('2016_std2.nc','dhw0');  %load year 1 of 3
dhw17 = ncread('2017_std2.nc','dhw0');  %load year 2 of 3
dhw20 = ncread('2020_std2.nc','dhw0');  %load year 3 of 3
z = ncread('2020_std2.nc','botz');  %load depth to use for contours when displaying reef outlines 
tf16 = numel(dhw16(1,1,25,:)); %time final for year 1 
tf17 = numel(dhw17(1,1,25,:)); %time final for year 1 
tf20 = numel(dhw20(1,1,25,:)); %time final for year 1 

dhw16_surf = squeeze(dhw16(:,:,25,tf16)); %extract surface dhw from year-1 dataset
dhw17_surf = squeeze(dhw17(:,:,25,tf17)); %extract surface dhw from year-1 dataset
dhw20_surf = squeeze(dhw20(:,:,25,tf20)); %extract surface dhw from year-1 dataset

dhw_surf(:,:,1) = dhw16_surf;
dhw_surf(:,:,2) = dhw17_surf;
dhw_surf(:,:,3) = dhw20_surf;

dhw16_surf_vector = reshape(dhw16_surf',[2500,1]);
dhw17_surf_vector = reshape(dhw17_surf',[2500,1]);
dhw20_surf_vector = reshape(dhw20_surf',[2500,1]);

dhw16_sites = dhw16_surf_vector(SiteAddress); %dhws for each grid cell in year 1
dhw17_sites = dhw17_surf_vector(SiteAddress); %dhws for each grid cell in year 2
dhw20_sites = dhw20_surf_vector(SiteAddress); %dhws for each grid cell in year 3

resdhwsites = zeros(nsites,7); %initialise matrix for residual dhws for sites
resdhwsites(:,1:4) = F0;
resdhwsites(:,5) = dhw16_sites-mean(dhw16_surf_vector,'all');
resdhwsites(:,6) = dhw17_sites-mean(dhw17_surf_vector,'all');
resdhwsites(:,7) = dhw20_sites-mean(dhw20_surf_vector,'all');
resdhwsites = sortrows(resdhwsites,1);
save MooreDHWs resdhwsites dhw_surf z
end