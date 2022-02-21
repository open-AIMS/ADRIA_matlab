load('./Outputs/metric_summaries_1920_prelim_10p_bounds.mat')

depth_min = 5;
depth_offset = 5;
sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
site_data = sdata(:,[["site_id","k",["Acropora2026","Goniastrea2026"],"sitedepth","recom_connectivity"]]);
site_data = sortrows(site_data, "recom_connectivity");
max_depth = depth_min+depth_offset;
depth_criteria = (site_data.sitedepth >-max_depth)&(site_data.sitedepth<-depth_min);
depth_priority = site_data{depth_criteria,"recom_connectivity"};
latitude = sdata{depth_priority,"lat"};
longitude = sdata{depth_priority,"long"};
%% extract median of each metric for final timestep and average over
% intervention scenarios

TCMed_yr25 = squeeze(median(met_summaries.TC.median(25,depth_priority,:),3));
SVMed_yr25 = squeeze(median(met_summaries.SV.median(25,depth_priority,:),3));
EvMed_yr25 = squeeze(median(met_summaries.evenness.median(25,depth_priority,:),3));
JuMed_yr25 = squeeze(median(met_summaries.juveniles.median(25,depth_priority,:),3));

% TCMed_yr35 = squeeze(median(met_summaries.TC.median(,:,:),3));
% SVMed_yr35 = squeeze(median(met_summaries.SV.median(35,:,:),3));
% EvMed_yr35 = squeeze(median(met_summaries.evenness.median(35,:,:),3));
% JuMed_yr35 = squeeze(median(met_summaries.juveniles.median(35,:,:),3));
% 
% TCMed_yr45 = squeeze(median(met_summaries.TC.median(45,:,:),3));
% SVMed_yr45 = squeeze(median(met_summaries.SV.median(45,:,:),3));
% EvMed_yr45 = squeeze(median(met_summaries.evenness.median(45,:,:),3));
% JuMed_yr45 = squeeze(median(met_summaries.juveniles.median(45,:,:),3));
% construct pca matrix with sites along rows and variables (outputs)
% along cols
mat_pca = [depth_priority,TCMed_yr25',SVMed_yr25',EvMed_yr25',JuMed_yr25'];
%,...
%     TCMed_yr35',SVMed_yr35',EvMed_yr35',JuMed_yr35',...
%     TCMed_yr45',SVMed_yr45',EvMed_yr45',JuMed_yr45'];
%% save data as csv
writematrix(mat_pca,'test_data_ES_analysis.csv')
%% perform pca
coeff = pca(mat_pca)


%% clustering analysis
% determine optimal number of clusters

%o_c = evalclusters(mat_pca,'kmeans','CalinskiHarabasz','Klist',1:15)

[idx C] = kmeans(mat_pca,4);

%% plot clusters on map with different clusters in different colours

% let cluster be the colouring variable
Cluster = categorical(idx(depth_priority));
% add TC for sizin
clustering_TC = table(latitude,longitude,Cluster,TCMed_yr25(depth_priority)');
clustering_SV = table(latitude,longitude,Cluster,SVMed_yr25(depth_priority)');
clustering_Ev = table(latitude,longitude,Cluster,EvMed_yr25(depth_priority)');
clustering_Ju = table(latitude,longitude,Cluster,JuMed_yr25(depth_priority)');
%% Plotting
figure()
colororder(hsv(10))
subplot(2,2,1)
gb1 = geobubble(clustering_TC,'latitude','longitude','SizeVariable','Var4','ColorVariable','Cluster','Basemap','satellite')
gb1.SizeLegendTitle = 'Total cover';
subplot(2,2,2)
gb2 = geobubble(clustering_SV,'latitude','longitude','SizeVariable','Var4','ColorVariable','Cluster','Basemap','satellite')
gb1.SizeLegendTitle = 'Shelter Volume'
subplot(2,2,3)
gb3 = geobubble(clustering_Ev,'latitude','longitude','SizeVariable','Var4','ColorVariable','Cluster','Basemap','satellite')
gb3.SizeLegendTitle = 'Evenness'
subplot(2,2,4)
gb4 = geobubble(clustering_Ju,'latitude','longitude','SizeVariable','Var4','ColorVariable','Cluster','Basemap','satellite')
gb4.SizeLegendTitle = 'Juveniles';


