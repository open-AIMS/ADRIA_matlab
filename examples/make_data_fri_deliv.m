%% Loading file if .mat format
load('./Outputs/fri_deliv_2022-02-04_specific_metrics');
Y = specific_metrics;

% select only parameters which are permuted
inputs_data = Y.inputs(:,[1:3, 5 6]);
inputs_data = table2array(inputs_data);
% set up indices describing simple guided runs
inds = 1:height(inputs_data);
guided1 = inds(logical((inputs_data(:,1) == 0)+(inputs_data(:,1)== 1)));
inputs_data = inputs_data(guided1,:);
inputs_data(1,:) = []; % remove counterfactual
guided1(1) = [];

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
ranks = [221,203,229,155,216,171,166,263,56,254,218,222,204,54,11,141,256,76,169,22,168];
top_5 = ranks(1:5);
top_20 = ranks; %REPLACE WITH TOP 20 BENEFICIARIES
Y_g1 = cell(1,length(guided1));

for k = 1:length(guided1)
    Y_g1{k} = struct('mean_TC',Y.mean_TC(:,:,guided1(k)),...
        'SV_per_ha',Y.SV_per_ha(:,:,guided1(k)),...
        'cover_per_species',Y.cover_per_species(:,:,:,guided1(k)),...
        'evenness',Y.evenness(:,:,guided1(k)),...
        'juveniles',Y.juveniles(:,:,guided1(k)));
end

%% Create BBN table

% Table with node headings yr, site, Seed1, Seed2, NatAd, As Adt., Total Cover,
% E, SV
Names = {'Yr','Guided','Seed1','Seed2','AsAdt','NatAd','Coral Cover 5 Av','Coral Cover 5 Abs Sum', 'Coral Cover 20 Av','Coral Cover 20 Abs Sum','Coral Cover Av','Coral Cover Sum','Coral Cover Abs Sum'};
nnodes = length(Names);
nyrs = 50;
nsites = length(depth_priority);
Nint = size(inputs_data,1);
store_table = zeros(nyrs*Nint,nnodes);
count = 0;
for l = 1:nyrs
        for m = 1:Nint
                 count = count +1;
                 store_table(count,1) = l;
                 store_table(count,2:6) = inputs_data(m,:);
                 store_table(count,7) = mean(Y_g1{m}.mean_TC(l,top_5));
                 store_table(count,8) = sum(Y_g1{m}.mean_TC(l,top_5)).*sdata.area(top_5); 
                 store_table(count,9) = mean(Y_g1{m}.mean_TC(l,top_20));
                 store_table(count,10) = sum(Y_g1{m}.mean_TC(l,top_20)).*sdata.area(top_20); 
                 store_table(count,11) = mean(Y_g1{m}.mean_TC(l,:));
                 store_table(count,12) = sum(Y_g1{m}.mean_TC(l,:)).*sdata.area; 
        end
end

data_tab = array2table(store_table,"VariableNames",Names);
% filename = 'ADRIA_IPMF_var_runs.xlsx';
% writetable(data_tab,filename);
%% Bubble plots
Names2 = {'Yr','Guided','Seed1','Seed2','AsAdt','NatAd','Coral Cover Difference'};
nnodes = length(Names2);
nyrs = 50;
nsites = 366;
Nint = size(inputs_data,1);
store_table2 = zeros(nyrs*Nint*nsites,nnodes);
count = 0;
for l = 1:nyrs
    for s = 1:nsites
        for m = 1:Nint
                 count = count +1;
                 store_table2(count,1) = l;
                 store_table2(count,2:6) = inputs_data(m,:);
                 store_table2(count,7) = sum((Y_g1{m}.mean_TC(l,s)-Y_g1{1}.mean_TC(l,s)).*sdata.area(s));
        end
    end
end

%data_tab = array2table(store_table,"VariableNames",Names);
%% Plotting
  figure(1)
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