%% Plot Brick reef site and reef ranks

%% Load site ranks
F = readtable('Rankings_RCPs264560_connectivity2012_coralcover2025.xlsx');
%F = readtable('Brick_RCP45_seed_site_ranks.xlsx');

lat = F.lat;
lon = F.long;
rank = F.relative_rank;

%% Load reef map
% first set
lonmin = 149; 
latmin = -20; 
lonmax = 150; 
latmax = -19; 
bbox = [lonmin,latmin;lonmax,latmax];
P = shaperead('Great_Barrier_Reef_Features.shp', 'BoundingBox', bbox);

Lat = P.X;
Lon = P.Y;
figure; 
geoshow(P, 'FaceColor', [0.8,0.8,0.8])

hold on
colormap parula;
scatter(lon,lat,40,rank,'filled')
colorbar('Direction', 'reverse');
axis([149.48,149.9,-19.85,-19.45]); 

% plot boundary for brick cluster
xx = [149.4856, 149.7649, 149.8772, 149.5979, 149.4856];
yy = [-19.6099, -19.829, -19.706, -19.4843, -19.6099];
hold on
PL = plot(xx,yy);
PL.LineWidth = 1;
PL.Color = 'r';
PL.LineStyle = '- -';

hold on
plot(lon(1:5),lat(1:5), 'Marker','d', 'MarkerSize',20, 'MarkerEdgeColor', 'r');

