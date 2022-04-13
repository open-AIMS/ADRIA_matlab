%% Plot Cairns Reef ranks on Map 

%% Load reef ranks
F = readtable('GrandMeanRanksCairns.xlsx','PreserveVariableNames', false);

%F = readtable('Brick_RCP45_seed_site_ranks.xlsx');

G = load('LIST_GBR_REEFS_new.mat');

GBRreefs = G.reefs.Reef_ID;

Cairnsreefs = F.SiteID;

reef_ranks = F.mmean;


lat = G.reefs.LAT(Cairnsreefs);
lon = G.reefs.LON(Cairnsreefs);

%rank = F.relative_rank;

%% Load reef map
% Cairns
%set boundary box
lonmin = 145.2;
lonmax = 146.8;
latmin = -17.5;
latmax = -15.65; 
bbox = [lonmin,latmin;lonmax,latmax];
P = shaperead('Great_Barrier_Reef_Features.shp', 'BoundingBox', bbox);

Lat = P.X;
Lon = P.Y;
f = figure; 
f.Position = [10, 10, 800 600];
geoshow(P, 'FaceColor', [0.8,0.8,0.8])

hold on
colormap parula;
scatter(lon,lat,30,reef_ranks,'filled')
colorbar('Direction', 'reverse');
axis([lonmin,lonmax,latmin,latmax]); 

% plot boundary for brick cluster
% xx = [149.4856, 149.7649, 149.8772, 149.5979, 149.4856];
% yy = [-19.6099, -19.829, -19.706, -19.4843, -19.6099];
% hold on
% PL = plot(xx,yy);
% PL.LineWidth = 1;
% PL.Color = 'r';
% PL.LineStyle = '- -';
% 
hold on
scatter(lon(1:20),lat(1:20), 70,'MarkerEdgeColor', 'r');
colormap(flipud(parula))

