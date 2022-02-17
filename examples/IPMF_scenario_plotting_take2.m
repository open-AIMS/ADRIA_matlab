%% Loading file if .mat format
load('./Outputs/fri_deliv_2022-02-04_specific_metrics');
Y = specific_metrics;

% select only parameters which are permuted
inputs_data = Y.inputs(:,[1:3, 5 6]);
% set up indices describing simple guided runs
guided1 = [1 3:4:size(Y.inputs,1)];
inputs_data = inputs_data(guided1,:);
inputs_data = table2array(inputs_data);
%% Retrieve depth filtered sitesa for plotting
depth_min = 5;
depth_offset = 5;
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id","k",["Acropora2026","Goniastrea2026"],"sitedepth","recom_connectivity"]]);
site_data = sortrows(site_data, "recom_connectivity");
max_depth = depth_min+depth_offset;
depth_criteria = (site_data.sitedepth >-max_depth)&(site_data.sitedepth<-depth_min);
depth_priority = site_data{depth_criteria,"recom_connectivity"};

%% Split metric data into guided1 runs for comparision
Y_g1 = cell(1,length(guided1));

for k = 1:length(guided1)
    Y_g1{k} = struct('mean_TC',Y.mean_TC(:,:,guided1(k)),...
        'SV_per_ha',Y.SV_per_ha(:,:,guided1(k)),...
        'cover_per_species',Y.cover_per_species(:,:,:,guided1(k)),...
        'evenness',Y.evenness(:,:,guided1(k)),...
        'juveniles',Y.juveniles(:,:,guided1(k)));
end
%% Some spatial movies of changing metrics as predicted by ADRIA
% counterfactuals
counter_TC = Y_g1{1}.mean_TC;
% scenario 1 seed1 =200, seed2 = 200
scen1_TC = Y_g1{20}.mean_TC-counter_TC;
% scenario 2 seed1 = 200, seed2 = 200, As Adt. = 4
scen2_TC = Y_g1{21}.mean_TC-counter_TC;

catnames = ["0.0-0.001","0.001-0.002","0.002-0.003","0.003-0.004","0.004-0.005","0.005>"]
bins = [-0.01,0.001,0.002,0.003,0.004,0.005,1]
myWriter = VideoWriter('CCbubblemov');
myWriter.FrameRate = 2;
fileloc = 'Inputs/';
load([fileloc,'MooreSitesDomainInfo.mat']);
% find lats and longs corresponding to site numbers
store_map = zeros(length(depth_priority),5);
store_map(:,1) = depth_priority;
store_map(:,2)= sdata{depth_criteria,"lat"};
store_map(:,3)= sdata{depth_criteria,"long"};
open(myWriter);
% movie comparing counterfactual and scenario 1
for t = 1:50
    store_map(:,4)= scen1_TC(t,depth_priority);
    store_map(:,5)= scen2_TC(t,depth_priority);
    maptable1 = array2table(store_map(:,1:4),"VariableNames",["Sites","Latitude","Longitude","MeanCC"])   
    maptable1.CCCat = discretize(maptable1.MeanCC,bins,'categorical',catnames)    
    maptable2 = array2table(store_map(:,[1:3,5]),"VariableNames",["Sites","Latitude","Longitude","MeanCC"])
    maptable2.CCCat = discretize(maptable2.MeanCC,bins,'categorical',catnames)
    fig = figure()
    hold on
    subplot(1,2,1)
    gb = geobubble(maptable1,'Latitude','Longitude','SizeVariable','MeanCC','ColorVariable','CCCat','Basemap','satellite')
    subplot(1,2,2)
    gb = geobubble(maptable2,'Latitude','Longitude','SizeVariable','MeanCC','ColorVariable','CCCat','Basemap','satellite')
    colororder(prism(11))
    set(gcf,'Position',get(0,'Screensize'))
    movieVector = getframe(fig);

    writeVideo(myWriter,movieVector);

    clf
end
    close(myWriter);


%% Create BBN table

% Table with node headings yr, site, Seed1, Seed2, NatAd, As Adt., Total Cover,
% E, SV
nodeNames = {'Yr','Site','Seed1','Seed2','AsAdt','NatAd','Coral Cover','Evenness','Shelter Vol.','Juveniles'};
nnodes = length(nodeNames);
nyrs = 50;
nsites = length(depth_priority);
Nint = 25;
sites = 1:nsites;
store_table = zeros((nyrs/2)*Nint*nsites,nnodes);
count = 0;
for l = 1:nyrs
    for s = 1:nsites
        for m = 1:Nint
                 count = count +1;
                 store_table(count,1) = l;
                 store_table(count,2) = s;
                 store_table(count,3:6) = inputs_data(m,2:end);
                 store_table(count,7) = Y_g1{m}.mean_TC(l,depth_priority(s));
                 store_table(count,8) = Y_g1{m}.evenness(l,depth_priority(s));
                 store_table(count,9) = Y_g1{m}.SV_per_ha(l,depth_priority(s));
                 store_table(count,10) = Y_g1{m}.juveniles(l,depth_priority(s));
%                  store_table(count,11) = Y_g1{m}.mean_TC(l,depth_priority(s))-Y_g1{1}.mean_TC(l,depth_priority(s));
%                  store_table(count,12) = Y_g1{m}.evenness(l,depth_priority(s))-Y_g1{1}.evenness(l,depth_priority(s));
%                  store_table(count,13) = Y_g1{m}.SV_per_ha(l,depth_priority(s))-Y_g1{1}.SV_per_ha(l,depth_priority(s));
%                  store_table(count,14) = Y_g1{m}.juveniles(l,depth_priority(s))-Y_g1{1}.juveniles(l,depth_priority(s));
        end
    end
end

%% Create BBN

ParentCell = cell(1,nnodes);
for c = 1:nnodes-4
    ParentCell{c} = [];
end
for c = nnodes-3:nnodes
    ParentCell{c} = [1:nnodes-4];
end

R = bn_rankcorr(ParentCell,store_table,1,1,nodeNames);
figure(1)
%bn_visualize(ParentCell,R,nodeNames,gca)
%% Begin inferences
% seeding scenario
inf_cells = [1 3 4 5 6];
increArray = [9 25 35 49];
Seed = 200;
Aadt = 4;
Natad = 0;
nodePos = 1;
knownVars = [Seed Seed Aadt Natad];
F_yrs = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);
% counterfactual
knownVars = [0 0 0 0];
F_yrsc = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);

% plot as histograms
% intervention total coral cover
figure(7)
subplot(1,2,1)
hold on
for b = 1:4
    f = F_yrs{b};
    h = histogram(f{2},20,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle(sprintf('Seed1, Seed2 %3.0f, As. Adt. %1.0f and Nat. Adt. %1.2f',Seed,Aadt,Natad),'Fontsize',16,'Interpreter','latex')
xlabel('Mean coral cover','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
ylim([0 0.3])
hold off

subplot(1,2,2)
hold on
for b = 1:4
    f = F_yrsc{b};
    h = histogram(f{2},25,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle('Counterfactual','Fontsize',16,'Interpreter','latex')
xlabel('Mean coral cover','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
ylim([0 0.3])
hold off

% plot as histograms
% intervention evenness
figure(8)
subplot(1,2,1)
hold on
for b = 1:4
    f = F_yrs{b};
    h = histogram(f{3},20,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle(sprintf('Seed1, Seed2 %3.0f, As. Adt. %1.0f and Nat. Adt. %1.2f',Seed,Aadt,Natad),'Fontsize',16,'Interpreter','latex')
xlabel('Mean Evenness','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
ylim([0 0.3])
hold off

subplot(1,2,2)
hold on
for b = 1:4
    f = F_yrsc{b};
    h = histogram(f{3},25,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle('Counterfactual','Fontsize',16,'Interpreter','latex')
xlabel('Mean Evenness','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
ylim([0 0.3])
hold off

% plot as histograms
% intervention shelter volume
figure(9)
subplot(1,2,1)
hold on
for b = 1:4
    f = F_yrs{b};
    h = histogram(f{4},20,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle(sprintf('Seed1, Seed2 %3.0f, As. Adt. %1.0f and Nat. Adt. %1.2f',Seed,Aadt,Natad),'Fontsize',16,'Interpreter','latex')
xlabel('Mean Shelter Volume','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')

hold off

subplot(1,2,2)
hold on
for b = 1:4
    f = F_yrsc{b};
    h = histogram(f{4},25,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle('Counterfactual','Fontsize',16,'Interpreter','latex')
xlabel('Mean Shelter Volume','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
hold off


% plot as histograms
% intervention juveniles
figure(10)
subplot(1,2,1)
hold on
for b = 1:4
    f = F_yrs{b};
    h = histogram(f{5},20,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle(sprintf('Seed1, Seed2 %3.0f, As. Adt. %1.0f and Nat. Adt. %1.2f',Seed,Aadt,Natad),'Fontsize',16,'Interpreter','latex')
xlabel('Juveniles','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
ylim([0 0.3])
hold off

subplot(1,2,2)
hold on
for b = 1:4
    f = F_yrsc{b};
    h = histogram(f{5},25,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle('Counterfactual','Fontsize',16,'Interpreter','latex')
xlabel('Juveniles','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
ylim([0 0.3])
hold off
%% Spatially ploted probabilities
% Intervention
inf_cells = [1:nnodes-4];
F_psites = zeros(4,length(increArray));
increArray = 1:length(depth_priority);
knownVars = [49,200,200,4,0.05];
nodePos = 2;
F_sites = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);

% Counterfactual
F_psitesc = zeros(4,length(increArray));
knownVars = [49 0 0 0 0];
F_sitesc = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);
val1 = 0.2;
val2 = 0.6;
val3 = 25;
val4 = 0.03;
% Calculate probability coral cover >0.3 for each site
for t = 1:length(increArray)
    f = F_sites{t};
    F_psites(1,t) = calcBBNProb(f{1},val1,1);
    F_psites(2,t) = calcBBNProb(f{2},val2,1);
    F_psites(3,t) = calcBBNProb(f{3},val3,1);
    F_psites(4,t) = calcBBNProb(f{4},val4,1);
    fc = F_sitesc{t};
    F_psitesc(1,t) = calcBBNProb(fc{1},val1,1);
    F_psitesc(2,t) = calcBBNProb(fc{2},val2,1);
    F_psitesc(3,t) = calcBBNProb(fc{3},val3,1);
    F_psitesc(4,t) = calcBBNProb(fc{4},val4,1);
end

%% plot probablilities on lat/lon map
%Sites_pos = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')
fileloc = 'Inputs/';
load([fileloc,'MooreSitesDomainInfo.mat']);
% find lats and longs corresponding to site numbers
store_map = zeros(length(depth_priority),5);
store_map(:,1) = depth_priority;
store_map(:,2)= sdata{depth_criteria,"lat"};
store_map(:,3)= sdata{depth_criteria,"long"};
store_map(:,4)= F_psites(1,:);
store_map(:,5)= F_psitesc(1,:);
store_map(:,6)= F_psites(2,:);
store_map(:,7)= F_psitesc(2,:);
store_map(:,8)= F_psites(3,:);
store_map(:,9)= F_psitesc(3,:);
store_map(:,10)= F_psites(4,:);
store_map(:,11)= F_psitesc(4,:);
%% try mapping probabilities with geoplotting toolbox
maptable1 = array2table(store_map(:,1:4),"VariableNames",["Sites","Latitude","Longitude","Probability"])
catnames = ["0.0-0.4","0.4-0.45","0.45-0.5","0.5-0.6","0.6-0.7",">0.7"]
bins = [0,0.4,0.45,0.5,0.6,0.7,1]
maptable1.ProbabilityCat = discretize(maptable1.Probability,bins,'categorical',catnames)

maptable2 = array2table(store_map(:,[1:3,5]),"VariableNames",["Sites","Latitude","Longitude","Probability"])
maptable2.ProbabilityCat = discretize(maptable2.Probability,bins,'categorical',catnames)
fig = figure()
hold on
subplot(1,2,1)
gb = geobubble(maptable1,'Latitude','Longitude','SizeVariable','Probability','ColorVariable','ProbabilityCat','Basemap','satellite')
subplot(1,2,2)
gb = geobubble(maptable2,'Latitude','Longitude','SizeVariable','Probability','ColorVariable','ProbabilityCat','Basemap','satellite')
colororder(prism(11))
%% Coral cover
figure(10)
%hold on
   % title('Counterfactual','Interpreter','latex')
    ax1 = axes;
    [~,h] = contourf(ax1,lon,lat,botz);
    view(2)
    ax2 = axes;
    scatter(ax2,store_map(:,3),store_map(:,2),600,store_map(:,5),'filled')
    % Link them together
    linkaxes([ax1,ax2])
    % Hide the top axes
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    caxis([0,1])
    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 
    
    % Determine where the binary threshold is within the current colormap
%     crng = caxis(ax1);  % range of color values 
%     clrmap = ax1.Colormap; 
%     nColor = size(clrmap,1); 
%     binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
%     binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
%     
%     % Change colormap to binary
%     % White section first to label values less than threshold.
%     newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
   % ax1.Colormap = 'gray'%newColormap; 
    colormap(ax1,'gray')
    colormap(ax2,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax1,ax2],'Position',[.17 .11 .685 .815]);
    cb1 = colorbar(ax1);
    colorbar(cb1,'hide');
    cb2 = colorbar(ax2,'Position',[.88 .11 .0675 .815]);
    
    ax1.FontSize = 16;
    ax2.FontSize = 16;
    set(ax1,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
    set(ax1,'TickLabelInterpreter','latex')
    set(ax2,'TickLabelInterpreter','latex')
    caxis([0,1])
    % plot site locations
    txt = text(ax2,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb2,strcat('$P(Coral Cover \geq',sprintf(' %1.2f)$',val1)),'FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb2,'TickLabelInterpreter','latex')
 %   hold off

  figure(11)
    ax3 = axes;
    [~,h] = contourf(ax3,lon,lat,botz);
    view(2)
    ax4 = axes;
    scatter(ax4,store_map(:,3),store_map(:,2),600,store_map(:,4),'filled')
    % Link them together
    linkaxes([ax3,ax4])
    % Hide the top axes
    ax4.Visible = 'off';
    ax4.XTick = [];
    ax4.YTick = [];

    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 
    colormap(ax3,'gray')
    colormap(ax4,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax3,ax4],'Position',[.17 .11 .685 .815]);
    cb3 = colorbar(ax3);
    colorbar(cb3,'hide');
    cb4 = colorbar(ax4,'Position',[.88 .11 .0675 .815]);
    
    ax3.FontSize = 16;
    ax4.FontSize = 16;
    set(ax3,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
     set(ax3,'TickLabelInterpreter','latex')
     set(ax4,'TickLabelInterpreter','latex')
    caxis([0,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,strcat('$P(Coral Cover \geq',sprintf(' %1.2f)$',val1)),'FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')


%% Evenness    
  figure(12)
    ax3 = axes;
    [~,h] = contourf(ax3,lon,lat,botz);
    view(2)
    ax4 = axes;
    scatter(ax4,store_map(:,3),store_map(:,2),600,store_map(:,6),'filled')
    % Link them together
    linkaxes([ax3,ax4])
    % Hide the top axes
    ax4.Visible = 'off';
    ax4.XTick = [];
    ax4.YTick = [];

    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 

    colormap(ax3,'gray')
    colormap(ax4,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax3,ax4],'Position',[.17 .11 .685 .815]);
    cb3 = colorbar(ax3);
    colorbar(cb3,'hide');
    cb4 = colorbar(ax4,'Position',[.88 .11 .0675 .815]);
    caxis([0,1])
    ax3.FontSize = 16;
    ax4.FontSize = 16;
    set(ax3,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
     set(ax3,'TickLabelInterpreter','latex')
     set(ax4,'TickLabelInterpreter','latex')
    %caxis([0.5,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,strcat('$P(Evenness \geq',sprintf(' %1.2f)$',val2)),'FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')

  figure(13)
    ax3 = axes;
    [~,h] = contourf(ax3,lon,lat,botz);
    view(2)
    ax4 = axes;
    scatter(ax4,store_map(:,3),store_map(:,2),600,store_map(:,7),'filled')
    % Link them together
    linkaxes([ax3,ax4])
    % Hide the top axes
    ax4.Visible = 'off';
    ax4.XTick = [];
    ax4.YTick = [];
    caxis([0,1])
    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 

    colormap(ax3,'gray')
    colormap(ax4,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax3,ax4],'Position',[.17 .11 .685 .815]);
    cb3 = colorbar(ax3);
    colorbar(cb3,'hide');
    cb4 = colorbar(ax4,'Position',[.88 .11 .0675 .815]);
    
    ax3.FontSize = 16;
    ax4.FontSize = 16;
    set(ax3,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
     set(ax3,'TickLabelInterpreter','latex')
     set(ax4,'TickLabelInterpreter','latex')
    caxis([0,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,strcat('$P(Evenness \geq',sprintf(' %1.2f)$',val2)),'FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')

%% Shelter volume
  figure(14)
    ax3 = axes;
    [~,h] = contourf(ax3,lon,lat,botz);
    view(2)
    ax4 = axes;
    scatter(ax4,store_map(:,3),store_map(:,2),600,store_map(:,8),'filled')
    % Link them together
    linkaxes([ax3,ax4])
    % Hide the top axes
    ax4.Visible = 'off';
    ax4.XTick = [];
    ax4.YTick = [];

    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 

    colormap(ax3,'gray')
    colormap(ax4,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax3,ax4],'Position',[.17 .11 .685 .815]);
    cb3 = colorbar(ax3);
    colorbar(cb3,'hide');
    cb4 = colorbar(ax4,'Position',[.88 .11 .0675 .815]);
    
    ax3.FontSize = 16;
    ax4.FontSize = 16;
    set(ax3,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
     set(ax3,'TickLabelInterpreter','latex')
     set(ax4,'TickLabelInterpreter','latex')
    caxis([0,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,strcat('$P(Shelter Vol. \geq',sprintf(' %1.2f)$',val3)),'FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')


  figure(15)
% %hold on
%title('Seed2 200, As.Ad 4, Nat. Ad. 0.2','Interpreter','latex')
    ax3 = axes;
    [~,h] = contourf(ax3,lon,lat,botz);
    view(2)
    ax4 = axes;
    scatter(ax4,store_map(:,3),store_map(:,2),600,store_map(:,9),'filled')
    % Link them together
    linkaxes([ax3,ax4])
    % Hide the top axes
    ax4.Visible = 'off';
    ax4.XTick = [];
    ax4.YTick = [];

    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 

    colormap(ax3,'gray')
    colormap(ax4,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax3,ax4],'Position',[.17 .11 .685 .815]);
    cb3 = colorbar(ax3);
    colorbar(cb3,'hide');
    cb4 = colorbar(ax4,'Position',[.88 .11 .0675 .815]);
    
    ax3.FontSize = 16;
    ax4.FontSize = 16;
    set(ax3,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
     set(ax3,'TickLabelInterpreter','latex')
     set(ax4,'TickLabelInterpreter','latex')
    caxis([0,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,strcat('$P(Shelter Vol. \geq',sprintf(' %1.2f)$',val3)),'FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')
%% Juveniles

    figure(16)
% %hold on
%title('Seed2 200, As.Ad 4, Nat. Ad. 0.2','Interpreter','latex')
    ax3 = axes;
    [~,h] = contourf(ax3,lon,lat,botz);
    view(2)
    ax4 = axes;
    scatter(ax4,store_map(:,3),store_map(:,2),600,store_map(:,10),'filled')
    % Link them together
    linkaxes([ax3,ax4])
    % Hide the top axes
    ax4.Visible = 'off';
    ax4.XTick = [];
    ax4.YTick = [];

    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 

    colormap(ax3,'gray')
    colormap(ax4,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax3,ax4],'Position',[.17 .11 .685 .815]);
    cb3 = colorbar(ax3);
    colorbar(cb3,'hide');
    cb4 = colorbar(ax4,'Position',[.88 .11 .0675 .815]);
    
    ax3.FontSize = 16;
    ax4.FontSize = 16;
    set(ax3,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
     set(ax3,'TickLabelInterpreter','latex')
     set(ax4,'TickLabelInterpreter','latex')
    caxis([0,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,strcat('$P(Juveniles \geq',sprintf(' %1.2f)$',val4)),'FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')


  figure(17)
% %hold on
%title('Seed2 200, As.Ad 4, Nat. Ad. 0.2','Interpreter','latex')
    ax3 = axes;
    [~,h] = contourf(ax3,lon,lat,botz);
    view(2)
    ax4 = axes;
    scatter(ax4,store_map(:,3),store_map(:,2),600,store_map(:,11),'filled')
    % Link them together
    linkaxes([ax3,ax4])
    % Hide the top axes
    ax4.Visible = 'off';
    ax4.XTick = [];
    ax4.YTick = [];

    % Set this value to any value within the range of levels.  

    colormap(ax3,'gray')
    colormap(ax4,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax3,ax4],'Position',[.17 .11 .685 .815]);
    cb3 = colorbar(ax3);
    colorbar(cb3,'hide');
    cb4 = colorbar(ax4,'Position',[.88 .11 .0675 .815]);
    
    ax3.FontSize = 16;
    ax4.FontSize = 16;
    set(ax3,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
     set(ax3,'TickLabelInterpreter','latex')
     set(ax4,'TickLabelInterpreter','latex')
    caxis([0,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,strcat('$P(Juveniles \geq',sprintf(' %1.2f)$',val4)),'FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')

