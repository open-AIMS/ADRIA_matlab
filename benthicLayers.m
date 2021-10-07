function benthicLayers

% Reads a geojson file from benthic Allen maps to allocate specific benthic
% type mask as layers.


%% Read file

fname = 'benthic.geojson'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
benthic = jsondecode(str);

%% Build lat/lon grid that matches previous Moore Reef info

polygons = benthic.features(:);

rangelatmin = ones(length(polygons),1)*NaN;
rangelatmax = ones(length(polygons),1)*NaN;
rangelonmin = ones(length(polygons),1)*NaN;
rangelonmax = ones(length(polygons),1)*NaN;
for i = 1:length(polygons)
    
    % If inner and outer boundaries, take first one (outer)
    if iscell(polygons(i).geometry.coordinates)
        
        rangelatmin(i) = min(polygons(i).geometry.coordinates{1,1}(:,2));
        rangelatmax(i) = max(polygons(i).geometry.coordinates{1,1}(:,2));

        rangelonmin(i) = min(polygons(i).geometry.coordinates{1,1}(:,1));
        rangelonmax(i) = max(polygons(i).geometry.coordinates{1,1}(:,1));
        
    else
        rangelatmin(i) = min(polygons(i).geometry.coordinates(:,:,2));
        rangelatmax(i) = max(polygons(i).geometry.coordinates(:,:,2));

        rangelonmin(i) = min(polygons(i).geometry.coordinates(:,:,1));
        rangelonmax(i) = max(polygons(i).geometry.coordinates(:,:,1));
    end
    
end

lat = min(rangelatmin)-0.002:0.0005:max(rangelatmax)+0.002;
lon = min(rangelonmin)-0.002:0.0005:max(rangelonmax)+0.002;

Rock = zeros(length(lon),length(lat));
Rubble = zeros(length(lon),length(lat));
Sand = zeros(length(lon),length(lat));
CoralAlgae = zeros(length(lon),length(lat));
Microalgal = zeros(length(lon),length(lat));

for i = 1:length(lon)
    for j = 1:length(lat)
        
        for p = 1:length(polygons)
            
            % Determine if the polygon has inner boundary
            if iscell(polygons(p).geometry.coordinates)
                
                % Initialise
                inInnerPol = 0;
                % Determine if point is inside the outer polygon
                if inpolygon(lon(i),lat(j),...
                        polygons(p).geometry.coordinates{1,1}(:,1),polygons(p).geometry.coordinates{1,1}(:,2))
                    % Make sure it is outside the inner boundary polygons
                    for b = 2:size(polygons(p).geometry.coordinates,1)
                        if inpolygon(lon(i),lat(j),...
                            polygons(p).geometry.coordinates{b,1}(:,1),polygons(p).geometry.coordinates{b,1}(:,2))
                        
                            inInnerPol = 1;
                        end
                    end
                    % If it's in ther outer polygon but outside the inner
                    % polygon, attribute this point to its corresponding mask
                    if inInnerPol == 0
                        if strcmp(polygons(p).properties.class,'Coral/Algae')
                            CoralAlgae(i,j) = 1;
                        elseif strcmp(polygons(p).properties.class,'Microalgal Mats')
                            Microalgal(i,j) = 1;
                        else
                            eval([polygons(p).properties.class,'(i,j) = 1;'])
                        end
                        break;
                    end
                end
                
            else
            
                % Determine if point is inside the polygon
                if inpolygon(lon(i),lat(j),...
                        polygons(p).geometry.coordinates(:,:,1),polygons(p).geometry.coordinates(:,:,2))

                    if strcmp(polygons(p).properties.class,'Coral/Algae')
                        CoralAlgae(i,j) = 1;
                    elseif strcmp(polygons(p).properties.class,'Microalgal Mats')
                        Microalgal(i,j) = 1;
                    else
                        eval([polygons(p).properties.class,'(i,j) = 1;'])
                    end
                    break

                end % condition in polygon
            end %condition on number of boundaries
            
        end % loop on polygons
        
    end %loop on lats
end % loop on lons

save('benthicMasks.mat','lon','lat','Rock','Rubble','Sand','CoralAlgae','Microalgal')

