function plotBenthicLayers
close all

load('benthicMasks.mat')

Rock(Rock==0)=NaN;
Rubble(Rubble==0)=NaN;
Sand(Sand==0)=NaN;
CoralAlgae(CoralAlgae==0)=NaN;
Microalgal(Microalgal==0)=NaN;


scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/8 0 3*scrsz(3)/4 scrsz(4)],'Color','w')


h = pcolor(lon,lat,Rock');
set(h,'LineStyle','none')

hold on

set(gca,'FontSize',16,'LineWidth',1.5)


h = pcolor(lon,lat,Rubble'*2);
set(h,'LineStyle','none')

h = pcolor(lon,lat,CoralAlgae'*3);
set(h,'LineStyle','none')

h = pcolor(lon,lat,Microalgal'*4);
set(h,'LineStyle','none')

h = pcolor(lon,lat,Sand'*5);
set(h,'LineStyle','none')

caxis([0.5 5.5])
%colormap(parula(5))
colormap(buildColormap('categories5'))
h = colorbar;
set(h,'Ticks',1:1:5,'TickLabels',{'Rock','Rubble','Coral/Algae','Microalgal mats','Sand'},...
    'TickLength',0,'FontSize',16);

xlabel('Longitude')
ylabel('Latitude')

set(gca,'Position',[0.08 0.08 0.77 0.88])
set(h,'Position',[0.86 0.08 0.02 0.88])

figsave = figure(1);
saveas(figsave,'benthicLayersMooreReef.png')
