%% Retrieve depth filtered sitesa for plotting
depth_min = 5;
depth_offset = 5;
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id","k",["Acropora2026","Goniastrea2026"],"sitedepth","recom_connectivity"]]);
site_data = sortrows(site_data, "recom_connectivity");
max_depth = depth_min+depth_offset;
depth_criteria = (site_data.sitedepth >-max_depth)&(site_data.sitedepth<-depth_min);
depth_priority = site_data{depth_criteria,"recom_connectivity"};

%% Create BBN table

% Table with node headings yr, site, Seed1, Seed2, NatAd, As Adt., Total Cover,
% E, SV
nnodes = 9;
nyrs = 50;
nsites = length(depth_priority);
Nint = 25;
store_table = zeros((nyrs/2)*Nint*nsites,nnodes);
count = 0;
batch_size = 5;
for l = 1:2:nyrs
    for s = 1:nsites
        for m = 1:n_batches
            for n = 1:batch_size
                 count = count +1;
                 store_table(count,1) = l;
                 store_table(count,2) = depth_priority(s);
                 store_table(count,3) = param_table.Seed1(m);
                 store_table(count,4) = param_table.Seed2(m);
                 store_table(count,5) = param_table.Natad(m);
                 store_table(count,6) = param_table.Aadpt(m);
                 store_table(count,7) = squeeze(mean(Y{m}.mean_coralTaxaCover_x_p_total_cover_4(l,depth_priority(s),n,:),4));
                 store_table(count,8) = squeeze(mean(Y{m}.coralEvenness(l,depth_priority(s),n,:),4));
                 store_table(count,9) = squeeze(mean(Y{m}.shelterVolume(l,depth_priority(s),n,:),4));
            end
        end
    end
end

%% Create BBN
nodeNames = {'Yr','Site','Seed1','Seed2','NatAd','AsAdt','Coral Cover','Evenness','Shelter Vol.'};
ParentCell = cell(1,nnodes);
for c = 1:nnodes-3
    ParentCell{c} = [];
end
for c = nnodes-2:nnodes
    ParentCell{c} = [1:nnodes-3];
end

R = bn_rankcorr(ParentCell,store_table,1,1,nodeNames);

%% Begin inferences

% Rose histograms
% seeding scenario
inf_cells = [1 3:nnodes-3];
increArray = 10:20:50;
nodePos = 1;
knownVars = [20000,20000,0.2,4];
F_yrs = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);
% counterfactual
knownVars = [0,0,0,0];
F_yrsc = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);

% plot as Rose histograms
% intervention total coral cover
figure(1)
subplot(1,2,1)
hold on
for b = 1:5
    f = F_yrs{b};
    h = polarhistogram(f{3},25,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
tile('Seeding, shading with As. Adt. 4 and Nat. Adt. 0.2')
hold off
subplot(1,2,2)
hold on
for b = 1:5
    f = F_yrsc{b};
    h = polarhistogram(f{3},25,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
tile('Counterfactual')
hold off

% Spatially ploted probabilities
% Intervention
inf_cells = [1:nnodes-3];
F_psites = zeros(1,length(increArray));
increArray = depth_priority;
knownVars = [40 20000,20000,0.2,4];
nodePos = 2;
F_sites = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);

% Counterfactual
F_psitesc = zeros(1,length(increArray));
knownVars = [40 0 0 0 0];
F_sitesc = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);
val = 0.3;

% Calculate probability coral cover >0.3 for each site
for t = 1:length(increArray)
    f = F_sites{t};
    F_psites = calcBBNProb(f{3},val,1);
    fc = F_sitesc{t};
    F_psitesc = calcBBNProb(fc{3},val,1);
end

% plot probablilities on lat/lon map
Sites_pos = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')

% find lats and longs corresponding to site numbers
store_map = zeros(length(depth_priority),4);
store_map(:,1) = depth_priority;
for d = 1:length(Sites_pos.recom_connectivity);
    ind = find(depth_priority==Sites_pos.recom_connectivity(d));
    store_map(ind,2) = Sites_pos.long(Sites_pos.recom_connectivity==Sites_pos.recom_connectivity(d));
    store_map(ind,3) = Sites_pos.lat(Sites_pos.recom_connectivity==Sites_pos.recom_connectivity(d));    
end
    botz = site_data.sitedepth;
% Create two axes
    ax1 = axes;
    [~,h] = contourf(ax1,lon,lat,botz);
    view(2)
    ax2 = axes;
    scatter(ax2,F0(:,3),F0(:,4),600,Fp','filled')
    % Link them together
    linkaxes([ax1,ax2])
    % Hide the top axes
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];

    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 
    
    % Determine where the binary threshold is within the current colormap
    crng = caxis(ax1);  % range of color values 
    clrmap = ax1.Colormap; 
    nColor = size(clrmap,1); 
    binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
    binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
    
    % Change colormap to binary
    % White section first to label values less than threshold.
    newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
    ax1.Colormap = newColormap; 

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
    
    % plot site locations
    text(ax2,F0(:,3),F0(:,4), cellstr(num2str(F0(:,1))), 'FontSize', 18, 'Color', 'k');
    ylabel(cb2,'$P(Coral Cover \geq 0.7)$','FontSize',16,'Interpreter','latex');
% 
% figure(2)
% [ax1,ax2]= plotBBNProbMap()