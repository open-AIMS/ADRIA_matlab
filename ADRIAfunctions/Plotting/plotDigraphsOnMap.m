%function Y = plotDigraphsOnMap()

%% Plot connectivity digraphs from connectivity matrix on map
ai = ADRIA();
% Load site specific data
% Must be loaded first
% Brick site data
%ai.loadSiteData('Inputs/Brick/site_data/Brick_2015_637_reftable.csv');

%Moore site data
ai.loadSiteData('Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');


% Path to folder or file. If folder, takes the average from all files in the given folder.
%ai.loadConnectivity('Inputs/Brick/connectivity/2016/');
ai.loadConnectivity('Inputs/Moore/connectivity/2015/', cutoff = 0.02);

% site data as used by ADRIA
ai.site_data;

% Connectivity data as used by ADRIA
Y = ai.TP_data;

lat = ai.site_data.lat;
lon = ai.site_data.long;

%Option: scale with site area and k values
%Y = Y.* ai.site_data.area/1e4 .* ai.site_data.k/100 ;

% Option: set self-seeding to zero (replace diagonal with zeros)
%Y = Y - diag(diag(Y));

DGbase = digraph(Y);
EWbase = DGbase.Edges.Weight;
C1 = centrality(DGbase,'outdegree','Importance',DGbase.Edges.Weight);

%% Load reef map
% boundaries for Brick 
% lonmin = 149.4; 
% latmin = -19.85; 
% lonmax = 149.85; 
% latmax = -19.47; 

% boundaries for Moore 
lonmin = 146.12; 
latmin = -16.96; 
lonmax = 146.33; 
latmax = -16.743; 

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
J1.LineWidth = nonzeros(EWbase)*2;
J1.ArrowSize = 10; %nonzeros(EWbase)*300;
J1.NodeFontSize = 10;
J1.NodeColor = [0,0.3,0.3];
J1.MarkerSize = 2;
%J1.EdgeColor = EWbase;%'k';
set(gca,'FontSize', 14);
set(gca,'color','none'); %set box to transparent
colorbar;
axis([lonmin,lonmax,latmin,latmax]); 
%end