
%function Y = plotDHWsBrick(year)

%% Plot DHWs at Brick Reef Cluster sites

%% Load DHW data for 2015/2016 bleaching event
F_dhwRCP26 = load('dhwRCP26_brick');
F_dhwRCP45 = load('dhwRCP45_brick');
F_dhwRCP60 = load('dhwRCP60_brick');

dhw26 = F_dhwRCP26.DHWdatacube; 
dhw45 = F_dhwRCP45.DHWdatacube; 
dhw60 = F_dhwRCP60.DHWdatacube; 

mdhw26 = squeeze(mean(dhw26,3)); 
mdhw45 = squeeze(mean(dhw45,3)); 
mdhw60 = squeeze(mean(dhw60,3)); 

lon = F_dhwRCP60.lat; 
lat = F_dhwRCP60.lon; 

% bbox = [149.5 -19.8; 150 19.5];
% PP = shaperead('TS_AIMS_NESP_Torres_Strait_Features_V1b_with_GBR_Features.shp', 'BoundingBox', bbox);
%PP = shaperead('benthic.shp');


%% New method for DHWs (dhw0)
tiledlayout(2,2);
colormap jet
nexttile
p1 = geoscatter(lat,lon,30,mdhw26(year,:)'); shading interp
title('BrickCluster DHWs 2015 - DHW0 method')
% set(gca,'Xticklabel', lon)
% % set(gca,'Xticklabel', [])
% % set(gca,'Yticklabel', [])
shading interp
colorbar;
caxis([-inf,inf]);
%freezeColors;
pp = gca;
pp.FontSize = 16;

hold on
mapshow(PP)


nexttile
p2 = pcolor(lon,lat,dhw016); shading interp
title('BrickCluster DHWs 2016 - DHW0 method')
% set(gca,'Xticklabel', lon)
% % set(gca,'Xticklabel', [])
% % set(gca,'Yticklabel', [])
shading interp
colorbar;
caxis([-inf,inf]);
%freezeColors;
pp = gca;
pp.FontSize = 16;
hold on
mapshow(PP)


nexttile
p3 = pcolor(lon,lat,dhw017); shading interp
title('BrickCluster DHWs 2017 - DHW0 method')
% set(gca,'Xticklabel', lon)
% % set(gca,'Xticklabel', [])
% % set(gca,'Yticklabel', [])
shading interp
colorbar;
caxis([-inf,inf]);
%freezeColors;
pp = gca;
pp.FontSize = 16;
hold on
mapshow(PP)


nexttile
p4 = pcolor(lon,lat,dhw019); shading interp
title('BrickCluster DHWs 2019 - DHW0 method')
% set(gca,'Xticklabel', lon)
% % set(gca,'Xticklabel', [])
% % set(gca,'Yticklabel', [])
shading interp
colorbar;
caxis([-inf,inf]);
%freezeColors;
pp = gca;
pp.FontSize = 16;
hold on
mapshow(PP)