
function [resdhwsites,dhw_surf,z] = ADRIA_dhwMoore_new(~)

%% Extract Degree Heating Weeks data for Moore Reef Cluster from Robson files

%% Load Moore sites
F0 = readtable('MooreSpatialSimple.xlsx', 'PreserveVariableNames',true);
F0 = table2array(F0); %site IDs, site area, longituded and latitudes, k and, depth for reef sites
site_area = F0(:,1);
nsites = size(F0,1);
LON_sites = F0(:,3); %longitude
LAT_sites = F0(:,4); %latitude

%% Load DHW data from marine heat waves (bleaching seasons) 
dhw16 = ncread('2016_std2.nc','dhw0');  %extract dhws for bleaching year 1 of 3
dhw17 = ncread('2017_std2.nc','dhw0');  %extract dhws for bleaching year 2 of 3
dhw20 = ncread('2020_std2.nc','dhw0');  %extract dhws for bleaching year 3 of 3
LON_RECOM = ncread('2020_std2.nc','x_centre');
LAT_RECOM = ncread('2020_std2.nc','y_centre');
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
dhw16_surf_vector  = reshape(dhw16_surf,[],1); %year 1
dhw17_surf_vector = reshape(dhw17_surf,[],1); %year 2
dhw20_surf_vector = reshape(dhw20_surf,[],1); %year 3
LON_RECOM_vector = reshape(LON_RECOM,[],1); %year 3
LAT_RECOM_vector = reshape(LAT_RECOM,[],1); %year 3

%% Find sites and their DHWs (VERY PRELIMINARY APPROACH)
tol = 0.01; %tolerance for the width of the search window for coordinates
for s = 1:nsites
    row = find(abs(LON_RECOM_vector-LON_sites(s))<tol & abs(LAT_RECOM_vector - LAT_sites(s))<tol);
    dhw16_sites(s) = mean(dhw16_surf_vector(row));
    dhw17_sites(s) = mean(dhw17_surf_vector(row));
    dhw20_sites(s) = mean(dhw20_surf_vector(row));
end
 
%Calculate residual dhws across sites to understand spatial dhw texture for sites and use in forecasts  
resdhwsites = zeros(nsites,9); %initialise matrix for residual dhws for sites
resdhwsites(:,1) = 1:nsites; %site ID
resdhwsites(:,2:6) = F0; %site IDS, addresses, lons and lats in columns 1 to 4
resdhwsites(:,7) = dhw16_sites - mean(dhw16_surf_vector,'all'); %spatial residuals for year 1
resdhwsites(:,8) = dhw17_sites - mean(dhw17_surf_vector,'all'); %spatial residuals for year 2
resdhwsites(:,9) = dhw20_sites - mean(dhw20_surf_vector,'all'); %spatial residuals for year 3
% Important, need to check that this first column is consistent with what the IPMF team uses
resdhwsites = sortrows(resdhwsites,1); %organise residuals according to site IDs (column 1)

save MooreDHWnew resdhwsites dhw_surf z;
% 
% 
% %% Plot results (turn off when using this function in work flow)
% cmin_axis = 5;
% cmax_axis = 16;
% 
% figure;
% contour(LON_RECOM, LAT_RECOM, -z, [0, 6, 20]);
% hold on
% colormap jet;
% scatter(LON_sites, LAT_sites, site_area/5000, dhw16_sites, 'filled');
% colorbar
% caxis([cmin_axis,cmax_axis]);
% 
% figure; 
% colormap jet;
% pcolor(LON_RECOM, LAT_RECOM, dhw16_surf);
% shading flat;
% caxis([cmin_axis,cmax_axis]);
% 
% figure; 
% colormap jet;
% surf(LON_RECOM, LAT_RECOM, dhw16_surf);
% caxis([cmin_axis,cmax_axis]);
% colorbar
% 
% hold on
% contour(LON_RECOM, LAT_RECOM, -z, [0, 6, 20]);
% hold on
% caxis([cmin_axis,cmax_axis]);

end
