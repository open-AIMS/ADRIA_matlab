function [F0, xx, yy, nsites] = ADRIA_siteTable(file)
% Load site location data
% Expects data format to follow the MooreSite.xlsx file.
%
% Inputs:
%     file : str, Name of file to load
%
% Outputs:
%     F0     : array, loaded site data
%     xx     : array, site longitude
%     yy     : array, site latitude
%     nsites : int, number of sites
    F0 = readtable(file, 'PreserveVariableNames', true);
    
    % site IDs, site address, lons and lats for all sites
    F0 = table2array(F0);

    xx = F0(:,3); %lon
    yy = F0(:,4); %lat
    nsites = length(F0);
end