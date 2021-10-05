
%% Generate kml file of Moore Reef sites for Google Earth

F = readtable('MooreSites.xlsx');
F = table2array(F);
lon = F(:,3);
lat = F(:,4);

filename = 'GE_MooreSites.kml';
sitetags = 1:26;
for i = 1:26 
    tags{i} = num2str(sitetags(i));
end
cd 'C:\users\KenAnthony\Documents\MATLAB\1_ADRIA\ADRIATemp_mat'
kmlwritepoint(filename,lat,lon,'Name',tags,'Icon','http://maps.google.com/mapfiles/kml/paddle/red-blank.png');
