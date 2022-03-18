%function Y = plotDigraphsOnMap()

%% Plot connectivity digraphs from connectivity matrix on map
ai = ADRIA();
% Load site specific data
% Must be loaded first
ai.loadSiteData('.\Inputs/Brick/site_data/Brick_2015_637_reftable.csv');

% Path to folder or file. If folder, takes the average from all files in the given folder.
ai.loadConnectivity('.\Inputs/Brick/connectivity/2015/');

% site data as used by ADRIA
ai.site_data;

% Connectivity data as used by ADRIA
Y = ai.TP_data;

lat = ai.site_data.lat;
lon = ai.site_data.long;

con_cutoff = 0.01;
maxY = max(Y,[],'all');
maxYcut = maxY*con_cutoff;
Y(Y<con_cutoff) = 0;  %filter out weak connections

DGbase = digraph(Y);
EWbase = DGbase.Edges.Weight;
C1 = centrality(DGbase,'outdegree','Importance',DGbase.Edges.Weight);

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
f= figure;
f.Position = [10, 10, 800 600];
geoshow(P, 'FaceColor', [0.8,0.8,0.8])
hold on

J1=plot(DGbase, 'XData', lon, 'YData', lat);
J1.EdgeCData = nonzeros(EWbase);    % define edge colors
J1.LineWidth = EWbase; %nonzeros(EWbase)*25;
J1.ArrowSize = 10; %nonzeros(EWbase)*300;
J1.NodeFontSize = 10;
J1.NodeColor = [0,0.3,0.3];
J1.MarkerSize = 2;
%J1.EdgeColor = EWbase;%'k';
set(gca,'FontSize', 14);
set(gca,'color','none'); %set box to transparent
colorbar;
axis([149.48,149.9,-19.85,-19.45]); 
%end