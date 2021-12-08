
function [resdhwsites,dhw_surf,z] = ADRIA_dhwMoore(~)

%% Extract Degree Heating Weeks data for Moore Reef Cluster from Robson files

%% Load Moore sites
F0 = readtable('MooreSites.xlsx', 'PreserveVariableNames',true);
F0 = table2array(F0); %site IDs, grid addresses, longituded and latitudes for reef sites
SiteID = F0(:,1);  % running reef site ID for internal reference 
SiteAddress = F0(:,2);  %grid-cell location of sites in the grid defined by the RECOM and the netcdf files
nsites = numel(SiteID);
% xx = F0(:,3); %longitude
% yy = F0(:,4); %latitude

%% Load DHW data from marine heat waves (bleaching seasons) 
dhw16 = ncread('2016_std2.nc','dhw0');  %extract dhws for bleaching year 1 of 3
dhw17 = ncread('2017_std2.nc','dhw0');  %extract dhws for bleaching year 2 of 3
dhw20 = ncread('2020_std2.nc','dhw0');  %extract dhws for bleaching year 3 of 3
z = ncread('2020_std2.nc','botz');  %extract depth to use for contours when displaying reef outlines 
tf16 = numel(dhw16(1,1,25,:)); %time final for year 1 
tf17 = numel(dhw17(1,1,25,:)); %time final for year 2 
tf20 = numel(dhw20(1,1,25,:)); %time final for year 3 

%extract surface dhws (layer 25) from the dataset
dhw16_surf = squeeze(dhw16(:,:,25,tf16)); %year 1
dhw17_surf = squeeze(dhw17(:,:,25,tf17)); %year 2
dhw20_surf = squeeze(dhw20(:,:,25,tf20)); %year 3

%Bring the surface dhws for years 2016, 2017 and 2020 into a matrix with years as third dimension
%Matrix is saved and used to display hot and cool areas on a 50 by 50 grid
dhw_surf(:,:,1) = dhw16_surf;  %year 1
dhw_surf(:,:,2) = dhw17_surf;  %year 2
dhw_surf(:,:,3) = dhw20_surf;  %year 3

%reorganise the 50 by 50 grid to a vector - needed to extract dhws for reef sites
dhw16_surf_vector = reshape(dhw16_surf',[2500,1]); %year 1
dhw17_surf_vector = reshape(dhw17_surf',[2500,1]); %year 2
dhw20_surf_vector = reshape(dhw20_surf',[2500,1]); %year 3

%Pick the site addresses on the 50 by 50 grid that correspond to site IDs
dhw16_sites = dhw16_surf_vector(SiteAddress); %dhws for reef sites in year 1
dhw17_sites = dhw17_surf_vector(SiteAddress); %dhws for reef sites in year 2
dhw20_sites = dhw20_surf_vector(SiteAddress); %dhws for reef sites in year 3

%Calculate residual dhws across sites to understand spatial dhw texture for sites and use in forecasts  
resdhwsites = zeros(nsites,7); %initialise matrix for residual dhws for sites
resdhwsites(:,1:4) = F0; %site IDS, addresses, lons and lats in columns 1 to 4
resdhwsites(:,5) = dhw16_sites - mean(dhw16_surf_vector,'all'); %spatial residuals for year 1
resdhwsites(:,6) = dhw17_sites - mean(dhw17_surf_vector,'all'); %spatial residuals for year 2
resdhwsites(:,7) = dhw20_sites - mean(dhw20_surf_vector,'all'); %spatial residuals for year 3
resdhwsites = sortrows(resdhwsites,1); %organise residuals according to site IDs (column 1)
save MooreDHWs resdhwsites dhw_surf z
end