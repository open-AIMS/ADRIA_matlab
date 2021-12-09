%% Transform raw .mat data

% filetype of saved raw data
filetype = 'mat';
% rcps to include
rcps = [26,45,60];
% algorithms to include
algs = 1:3;
% sites to include
sites = 1:26;
% intervention variables to include
col_names = {'Guided','PrSites','Seed1','Seed2','SRM','Aadpt','Natad','Seedyrs','Shadeyrs'};
% output metrics to include
metrics = {'TC','S','E'};
% number of simulations
nsims = 50;
% first year, yr increment and last year to use
yr = [1,2,25];

% create data table
Data = BBNTableMCData(filetype,rcps,algs,col_names,nsims,yr,sites,metrics);

% check header
head(Data)

%% Make BBN
% declare nodes in BBN
Names = {'RCP'; 'Alg';'Years';'Sites';'Guided'; 'PrSites';'Seed1'; 'Seed2'; 'SRM'; 'AssAdt'; 'NatAdt'; 'Seedyrs';'Shadeyrs';...
    'CC';'S';'E'};


% construct ParentCell, a cell structure of size 1*(no. of nodes)
% each cell contains the parents of the node corresponding the the cell no.
ParentCell = cell(1,16);
for i = 1:13
    ParentCell{i} = [];
end
ParentCell{14} = 1:13;
ParentCell{15} = 1:13;
ParentCell{16} = 1:13;

Data = table2array(Data);

R = bn_rankcorr(ParentCell, Data, 1, 0, Names);

bn_visualize(ParentCell,R,Names,gca);

%% example - what is the mean coral cover, E and S on site 26 for an RCP of 4.5,
% at year 10, with guided interventions, using all sites (Prsites = 3 ) and
% only seed1 and seed2 = 0.0005,seedyrs 12 and shadeyrs 3

% note that when performing inferences in this larger network, not enough
% degrees of freedom (e.g. setting too many variables as known) can result
% in Nans. It seems at least 5 variables need to be unknown to allow
% calculation.

% nodes we know
inf_cells = 1:8;
% their values
vals = [26,3,10,26,1,3,0.0009,0.0009];
outcome1 = inference(inf_cells,vals,R,Data,'mean',1000,'near');

% nodes we know
inf_cells = 1:8;
% their values, now with algorithm 1 for comparison
vals = [26,1,10,26,1,3,0.0009,0.0009];
outcome2 = inference(inf_cells,vals,R,Data,'mean',1000,'near');

% make the same inference but now with incrementally increasing years and
% retrieve the full distribution
F = cell(1,7);
figure(2);
yrsplot = 1:4:25;
hold on
for l = 1:length(yrsplot)
    F{l} = inference(inf_cells,[26,3,yrsplot(l),26,1,3,0.0009,0.0009],R,Data,'full',1000,'near');
    hist_dat = F{l};
    % plot the coral cover distribution as a histogram
    h = histogram(hist_dat{end-2},'NumBins',30,'Normalization','probability');     
end
legend('year 1','year 5','year 9','year 13','year 17','year 21','year 25');

% compare with rcp 60
F = cell(1,7);
figure(3);
yrsplot = 1:4:25;
hold on
for l = 1:length(yrsplot)
    F{l} = inference(inf_cells,[60,3,yrsplot(l),26,1,3,0.0009,0.0009],R,Data,'full',1000,'near');
    hist_dat = F{l};
    % plot the coral cover distribution as a histogram
    h = histogram(hist_dat{end-2},'NumBins',30,'Normalization','probability');     
end
legend('year 1','year 5','year 9','year 13','year 17','year 21','year 25');

%% trial plotting - probability of sites with coral cover >0.7, RCP 60, by yr 10, 
% probability indicated with colours
% nodes we know
inf_cells = 1:8;
% storage for probabilities
Fp = zeros(1,26);

% loop over 26 sites
for l = 1:26
    F = inference(inf_cells,[60,3,10,l,1,3,0.0009,0.0009],R,Data,'full',1000,'near');
    f = F{end-2};
    Fp(l) = sum(f(f>0.7))/sum(f);
end

% RCP 45 for comparison
% storage for probabilities
Fp2 = zeros(1,26);

% loop over 26 sites
for l = 1:26
    F = inference(inf_cells,[45,3,10,l,1,3,0.0009,0.0009],R,Data,'full',1000,'near');
    f = F{end-2};
    Fp2(l) = sum(f(f>0.7))/sum(f);
end

% Counterfactual for RCP 6.0
Fp0 = zeros(1,26);

% loop over 26 sites
for l = 1:26
    F = inference(inf_cells,[60,3,10,l,1,3,0,0],R,Data,'full',1000,'near');
    f = F{end-2};
    Fp0(l) = sum(f(f>0.7))/sum(f);
end
%% Plot probabilities on lat lon map
fileloc = 'Inputs/';
            load([fileloc,'MooreSitesDomainInfo.mat'])
figure(4)
%%Create two axes
ax1 = axes;
[~,h] = contourf(ax1,lon,lat,botz);
view(2)
ax2 = axes;
scatter(ax2,F0(:,3),F0(:,4),600,Fp','filled')
%%Link them together
linkaxes([ax1,ax2])
%%Hide the top axes
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];

% set this value to any value within the range of levels.  
binaryThreshold = 2.0; 
% Determine where the binary threshold is within the current colormap

crng = caxis(ax1);  % range of color values (same as min|max of c.LevelList) 
clrmap = ax1.Colormap; 
nColor = size(clrmap,1); 
binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
% Change colormap to binary
% White section first to label values less than threshold.
newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
ax1.Colormap = newColormap; 

colormap(ax2,'cool')
%%Then add colorbar for probabilities (hide contour colormap) and get everything lined up
set([ax1,ax2],'Position',[.17 .11 .685 .815]);
cb1 = colorbar(ax1);
colorbar(cb1,'hide');
cb2 = colorbar(ax2,'Position',[.88 .11 .0675 .815]);
ax1.FontSize = 16;
ax2.FontSize = 16;
set(ax1,'XLim',[min(min(lon)) max(max(lon))],...
    'YLim',[min(min(lat)) max(max(lat))])
title(ax1,'RCP $6.0$','FontSize',20,'Interpreter','latex')
% plot site locations
text(ax2,F0(:,3),F0(:,4), cellstr(num2str(F0(:,1))), 'FontSize', 18, 'Color', 'k');
ylabel(cb2,'$P(Coral Cover \geq 0.7)$','FontSize',16,'Interpreter','latex');

figure(5)
%%Create two axes
ax3 = axes;
[~,h] = contourf(ax3,lon,lat,botz);
view(2)
ax4 = axes;
scatter(ax4,F0(:,3),F0(:,4),600,Fp2','filled')
%%Link them together
linkaxes([ax3,ax4])
%%Hide the top axes
ax4.Visible = 'off';
ax4.XTick = [];
ax4.YTick = [];

% set this value to any value within the range of levels.  
binaryThreshold = 2.0; 
% Determine where the binary threshold is within the current colormap

crng = caxis(ax3);  % range of color values (same as min|max of c.LevelList) 
clrmap = ax3.Colormap; 
nColor = size(clrmap,1); 
binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
% Change colormap to binary
% White section first to label values less than threshold.
newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
ax3.Colormap = newColormap; 

colormap(ax4,'cool')
%%Then add colorbar for probabilities (hide contour colormap) and get everything lined up
set([ax3,ax4],'Position',[.17 .11 .685 .815]);
cb3 = colorbar(ax3);
colorbar(cb3,'hide');
cb4 = colorbar(ax4,'Position',[.88 .11 .0675 .815]);
ax3.FontSize = 16;
ax4.FontSize = 16;
set(ax3,'XLim',[min(min(lon)) max(max(lon))],...
    'YLim',[min(min(lat)) max(max(lat))])

title(ax3,'RCP $4.5$','FontSize',20,'Interpreter','latex')
% plot site locations
text(ax4,F0(:,3),F0(:,4), cellstr(num2str(F0(:,1))), 'FontSize', 18, 'Color', 'k');
ylabel(cb4,'$P(Coral Cover \geq 0.7)$','FontSize',16,'Interpreter','latex');
% 
% figure(6)
% %%Create two axes
% ax6 = axes;
% [~,h] = contourf(ax6,lon,lat,botz);
% view(2)
% ax7 = axes;
% scatter(ax7,F0(:,3),F0(:,4),600,Fp0','filled')
% %%Link them together
% linkaxes([ax6,ax7])
% %%Hide the top axes
% ax7.Visible = 'off';
% ax7.XTick = [];
% ax7.YTick = [];
% 
% % set this value to any value within the range of levels.  
% binaryThreshold = 2.0; 
% % Determine where the binary threshold is within the current colormap
% 
% crng = caxis(ax6);  % range of color values (same as min|max of c.LevelList) 
% clrmap = ax6.Colormap; 
% nColor = size(clrmap,1); 
% binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
% binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
% % Change colormap to binary
% % White section first to label values less than threshold.
% newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
% ax6.Colormap = newColormap; 
% 
% colormap(ax7,'cool')
% %%Then add colorbar for probabilities (hide contour colormap) and get everything lined up
% set([ax6,ax7],'Position',[.17 .11 .685 .815]);
% cb6 = colorbar(ax6);
% colorbar(cb6,'hide');
% cb7 = colorbar(ax7,'Position',[.88 .11 .0675 .815]);
% ax6.FontSize = 16;
% ax7.FontSize = 16;
% set(ax6,'XLim',[min(min(lon)) max(max(lon))],...
%     'YLim',[min(min(lat)) max(max(lat))])
% 
% title(ax6,'RCP $6.0$ Counterfactual','FontSize',20,'Interpreter','latex')
% % plot site locations
% text(ax7,F0(:,3),F0(:,4), cellstr(num2str(F0(:,1))), 'FontSize', 18, 'Color', 'k');
% ylabel(cb7,'$P(Coral Cover \geq 0.7)$','FontSize',16,'Interpreter','latex');