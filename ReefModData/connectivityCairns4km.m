%% Connectivity in the Cairns region
% Source: Yves-Marie Bozec
% Description: Characteristics of all individual reefs (n=3,806) simulated in ReefMod-GBR: GBRMPA
% name, GBRMPA ID, geographic coordinates, shelf position (1=inshore, 2=mid-shelf, 3=outer-shelf),
% AIMS sector (1 to 11) and reef area based on the GBRMPA-UQ geomorphic classification
% (Roelfsema et al. 2021) down to -20m depth with the inclusion of inshore reefs. Reef areas
% correspond to the 2D projected areas of selected geomorphic classes considered as suitable for
% coral colonisation: Outer Reef flat, Reef Crest, Sheltered Reef Slope, Reef Slope. About 700 reefs
% were absent from this classification so were assigned the area previously attributed by the
% GBRMPA reef outline.
% Type: table of 3,806 rows (reefs) and 7 columns: reef name, ID, LAT, LON, shelf position, AIMS
% sector, geomorphic area in km2.

F = load('LIST_CAIRNS_REEFS.mat');
reefID = F.reefs190(:,1);
reefID = table2array(reefID);
lat = F.reefs190.LAT;
lon = F.reefs190.LON;
%reef_area = table2array(F.reefs190(:,8));

%% Extract the connectivity matrices for all years:
G = load('GBR_CONNECT_7years.mat');
matrix_length = numel(reefID);
Y = zeros(matrix_length);
for yr = 1:7
Y(:,:,yr) = G.GBR_CONNECT(yr).ACROPORA(reefID , reefID);
Y = G.GBR_CONNECT(7).ACROPORA(reefID , reefID);
Y = full(Y); 
%T = table(squeeze(Y(:,:,yr)));
Year = yr + 2007;
Year = num2str(Year);
filename = strcat('Cairns_connectivity_', Year);
writematrix(Y, filename);
%writetable(T, filename.csv,'WriteVariableNames',false);
end

%% Code below is only if you want to visualise results  
% note: adjust con_cutoff to see strongest connections

con_cutoff = 0.02;
maxY = max(Y,[],'all');
maxYcut = maxY*con_cutoff;
Y(Y<con_cutoff) = 0;  %filter out weak connections

DGbase = digraph(Y);
EWbase = DGbase.Edges.Weight;

C1 = centrality(DGbase,'outdegree','Importance',DGbase.Edges.Weight);

bbox = [145 -17.5; 147 -15.5];
PP = shaperead('TS_AIMS_NESP_Torres_Strait_Features_V1b_with_GBR_Features.shp', 'BoundingBox',bbox);
%PP = shaperead('benthic.shp');
mapshow(PP)

hold on
J1=plot(DGbase, 'XData', lon, 'YData', lat);
J1.EdgeCData = nonzeros(EWbase);    % define edge colors
J1.LineWidth = 1; %EWbase; %nonzeros(EWbase)*25;
J1.ArrowSize = 12; %nonzeros(EWbase)*100;
J1.NodeFontSize = 10;
J1.NodeColor = [0,0.3,0.3];
J1.MarkerSize = 2;
%J1.EdgeColor = EWbase;%'k';
set(gca,'FontSize', 14);
set(gca,'color','none'); %set box to transparent
%Cairns
axis([145, 147, -17.5, -15.5]);
colormap jet;
colorbar;
caxis([0,inf]);
box on
axis on
title('Cairns Region') 

%% Figure of outgoing connection 
figure('Position', [15 15 900 600]);
mapshow(PP)
colormap(parula)
geoscatter(lat, lon, 30, C1,'filled') 
colorbar

box on
title('Outdegree strengths with self-seeding based on Bozec data')