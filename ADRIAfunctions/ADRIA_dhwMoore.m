
function [resdhwsites,dhw_surf,z] = ADRIA_dhwMoore(nsites)

%% Extract DHD data for Moore Reef Cluster from Robson files

%% Load Moore sites
F0 = readtable('MooreSites.xlsx', 'PreserveVariableNames',true);
F0 = table2array(F0); %site IDs, lats and lons for all sites
SiteID = F0(:,1);
SiteAddress = F0(:,2);
xx = F0(:,3);
yy = F0(:,4);

%% Load DHW data
dhw16 = ncread('2016_std2.nc','dhw0');
dhw17 = ncread('2017_std2.nc','dhw0');  
dhw20 = ncread('2020_std2.nc','dhw0');
z = ncread('2020_std2.nc','botz');
tf16 = numel(dhw16(1,1,25,:));
tf17 = numel(dhw17(1,1,25,:));
tf20 = numel(dhw20(1,1,25,:));

dhw16_surf = squeeze(dhw16(:,:,25,tf16));
dhw17_surf = squeeze(dhw17(:,:,25,tf17));
dhw20_surf = squeeze(dhw20(:,:,25,tf20));

dhw_surf(:,:,1) = dhw16_surf;
dhw_surf(:,:,2) = dhw17_surf;
dhw_surf(:,:,3) = dhw20_surf;

dhw16_surf_vector = reshape(dhw16_surf',[2500,1]);
dhw17_surf_vector = reshape(dhw17_surf',[2500,1]);
dhw20_surf_vector = reshape(dhw20_surf',[2500,1]);

dhw16_sites = dhw16_surf_vector(SiteAddress);
dhw17_sites = dhw17_surf_vector(SiteAddress);
dhw20_sites = dhw20_surf_vector(SiteAddress);

resdhwsites = zeros(26,7);
resdhwsites(:,1:4) = F0;
resdhwsites(:,5) = dhw16_sites-mean(dhw16_surf_vector,'all');
resdhwsites(:,6) = dhw17_sites-mean(dhw17_surf_vector,'all');
resdhwsites(:,7) = dhw20_sites-mean(dhw20_surf_vector,'all');
resdhwsites = sortrows(resdhwsites,1);
save MooreDHWs resdhwsites dhw_surf z
end