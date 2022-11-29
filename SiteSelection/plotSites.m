function plotSites(ax,site,sitesloc)
%
% Plot selected viable sites within selected zone
%
% Input: 
%   ax: axes where to plot (axes handle)
%   site: reef site (string)
%   sitesloc: locations of selected sites (lon/lat)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cla(ax)

% Load the bathymetry for vizualisation
fileloc = 'Inputs/';
load([fileloc,site,'/',site,'SitesDomainInfo.mat'], 'lon','lat','botz')            

h = pcolor(ax,lon,lat,botz);
set(h,'LineStyle','none')

hold(ax,'on')

% plot site locations
plot(ax,sitesloc(:,1),sitesloc(:,2),'.r','MarkerSize',10);
%text(ax,sitesloc(:,1),sitesloc(:,2), cellstr(num2str(sitesloc(:,1))), ...
%    'FontSize', 12, 'Color', 'k');

colorbar(ax)
set(ax,'XLim',[min(min(lon)) max(max(lon))],'YLim',[min(min(lat)) max(max(lat))])

hold(ax,'off')