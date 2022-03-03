%% Loading file if batch net cdfs
file_location_prefix = './Outputs/mimi_IPMF_data/fri_deliv_2022-02-04_mimic_IPMF_d2_2015';
n_batches = 5;
n_reps = 50;  % num DHW/Wave/RCP replicates
desired_metrics = {@coralTaxaCover, ...
                   @coralEvenness, ...
                   @coralSpeciesCover, ...
                   @shelterVolume, ...
                   @(x, p) mean(coralTaxaCover(x, p).total_cover, 4)};
Y = ai.gatherResults(file_location_prefix, desired_metrics);
%% Collect metrics

% Get the mean total coral cover at end of simulation time across all
% simulations.
% Note the name of the custom function has been transformed from its 
% function name to a representative string (brackets/dots to underscores).
mean_TC = concatMetrics(Y, "mean_coralTaxaCover_x_p_total_cover_4");
mean_TC = squeeze(mean(mean_TC(end, :, :, :), 4));

% Total coral cover
TC = concatMetrics(Y, "coralTaxaCover.total_cover");

% Coral cover per species
covs = concatMetrics(Y, "coralSpeciesCover");

% Evenness
E = concatMetrics(Y, "coralEvenness");

% Extract juvenile corals (< 5 cm diameter)
BC = concatMetrics(Y, "coralTaxaCover.juveniles");

% Calculate coral shelter volume per ha
SV_per_ha = concatMetrics(Y, "shelterVolume");

%% Load intervention inputs
% inputs filename
input_file = './Outputs/mimi_IPMF_data/fri_deliv_2022-02-04_mimic_IPMF_d2_2015_[[1-49]]_inputs.nc';
inputs_data = ncread(input_file,'input_parameters');
tf = ncreadatt(input_file,'constants','tf');
% select only parameters which are permuted
inputs_data = inputs_data(:,[1:3, 5 6]);
% set up indices describing simple guided runs
guided1 = [1 3:4:49];
inputs_data = inputs_data(guided1,:);

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
Y_g1 = cell(1,13);

Y_g1{1} = Y{1}; % counterfactual

% seed 100, natad 0
Y_g1{2} = Y{3};
Y_g1{3} = Y{7};
Y_g1{4} = Y{11};
% seed 100, natad 0.2
Y_g1{5} = Y{15};
Y_g1{6} = Y{19};
Y_g1{7} = Y{23};
% seed 200, natad 0
Y_g1{8} = Y{27};
Y_g1{9} = Y{31};
Y_g1{10} = Y{35};
% seed 200, natad 0.2
Y_g1{11} = Y{39};
Y_g1{12} = Y{43};
Y_g1{13} = Y{47};

%% Plotting coral cover vs. years
yrs = 1:tf;
% seeding 200
% difference to counterfactual without natural adaptation
difftot_run1_1 = squeeze(mean((Y_g1{8}.coralTaxaCover.total_cover-Y_g1{1}.coralTaxaCover.total_cover),2));
difftot_run1_2 = squeeze(mean((Y_g1{9}.coralTaxaCover.total_cover-Y_g1{1}.coralTaxaCover.total_cover),2));
difftot_run1_3 = squeeze(mean((Y_g1{10}.coralTaxaCover.total_cover-Y_g1{1}.coralTaxaCover.total_cover),2));

% difference to counterfactual with natural adaptation
difftot_run2_1 = squeeze(mean((Y_g1{11}.coralTaxaCover.total_cover-Y_g1{1}.coralTaxaCover.total_cover),2));
difftot_run2_2 = squeeze(mean((Y_g1{12}.coralTaxaCover.total_cover-Y_g1{1}.coralTaxaCover.total_cover),2));
difftot_run2_3 = squeeze(mean((Y_g1{13}.coralTaxaCover.total_cover-Y_g1{1}.coralTaxaCover.total_cover),2));

% ploting coral cover total over years with spread
figure(1)
subplot(1,2,1)
hold on
subtitle('Nat Adt. = 0','Fontsize',18,'Interpreter','latex')
h1 = plot_distribution_prctile(yrs,difftot_run1_1')
h2 = plot_distribution_prctile(yrs,difftot_run1_2')
h3 = plot_distribution_prctile(yrs,difftot_run1_3')
ylabel('Mean difference in coral cover','Fontsize',16,'Interpreter','latex')
xlabel('Yrs','Fontsize',16,'Interpreter','latex')
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
set(l1, 'Fontsize',16,'Interpreter','latex','Location','northwest')
%ylim([0,0.4])
ax=gca;
ax.FontSize = 14;
ax.TickLabelInterpreter = 'latex';
hold off

subplot(1,2,2)
hold on
subtitle('Nat Adt. = 0.2','Fontsize',18,'Interpreter','latex')
h1 = plot_distribution_prctile(yrs,difftot_run2_1')
h2 = plot_distribution_prctile(yrs,difftot_run2_2')
h3 = plot_distribution_prctile(yrs,difftot_run2_3')
ylabel('Mean difference in coral cover','Fontsize',16,'Interpreter','latex')
xlabel('Yrs','Fontsize',16,'Interpreter','latex')
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
set(l1, 'Fontsize',16,'Interpreter','latex','Location','northwest')
%ylim([0,0.4])
ax=gca;
ax.FontSize = 14;
ax.TickLabelInterpreter = 'latex';
hold off


%% ploting evenness
Ev_run1_1 = Y_g1{8}.coralEvenness;
Ev_run1_2 = Y_g1{9}.coralEvenness;
Ev_run1_3 = Y_g1{10}.coralEvenness;
Ev_count = Y_g1{1}.coralEvenness;

Ev_run2_1 = Y_g1{11}.coralEvenness;
Ev_run2_2 = Y_g1{12}.coralEvenness;
Ev_run2_3 = Y_g1{13}.coralEvenness;

% ploting coral cover total over years with spread
figure(2)
subplot(1,2,1)
hold on
subtitle('Nat Adt. = 0','Fontsize',18,'Interpreter','latex')
h1 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run1_1,2,'omitnan'))'-squeeze(mean(Ev_count,2,'omitnan'))')
h2 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run1_2,2,'omitnan'))'-squeeze(mean(Ev_count,2,'omitnan'))')
h3 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run1_3,2,'omitnan'))'-squeeze(mean(Ev_count,2,'omitnan'))')
xlabel('Yrs','Fontsize',16,'Interpreter','latex')
ylabel('Mean difference in Evenness','Fontsize',16,'Interpreter','latex')
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
set(l1, 'Fontsize',16,'Interpreter','latex','Location','northwest')
%ylim([0,0.0015])
ax=gca;
ax.FontSize = 14;
ax.TickLabelInterpreter = 'latex';
hold off

subplot(1,2,2)
hold on
subtitle('Nat Adt. = 0.2','Fontsize',18,'Interpreter','latex')
h1 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run2_1,2,'omitnan'))'-squeeze(mean(Ev_count,2,'omitnan'))')
h2 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run2_2,2,'omitnan'))'-squeeze(mean(Ev_count,2,'omitnan'))')
h3 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run2_3,2,'omitnan'))'-squeeze(mean(Ev_count,2,'omitnan'))')
xlabel('Yrs','Fontsize',16,'Interpreter','latex')
ylabel('Mean difference in Evenness','Fontsize',16,'Interpreter','latex')
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
%ylim([0,0.0015])
set(l1, 'Fontsize',16,'Interpreter','latex','Location','northwest')
ax=gca;
ax.FontSize = 14;
ax.TickLabelInterpreter = 'latex';
hold off

%% Plotting Shelter Volume vs. years
% % difference to counterfactual with natural adaptation
SV_run1_1 = Y_g1{8}.shelterVolume;
SV_run1_2 = Y_g1{9}.shelterVolume;
SV_run1_3 = Y_g1{10}.shelterVolume;
SV_count = Y_g1{1}.shelterVolume;
 
SV_run2_1 = Y_g1{11}.shelterVolume;
SV_run2_2 = Y_g1{12}.shelterVolume;
SV_run2_3 = Y_g1{13}.shelterVolume;


figure(3)
subplot(1,2,1)
hold on
subtitle('Nat Adt. = 0','Fontsize',18,'Interpreter','latex')
h1 = plot_distribution_prctile(yrs,squeeze(mean(SV_run1_1,2,'omitnan'))'-squeeze(mean(SV_count,2,'omitnan'))')
h2 = plot_distribution_prctile(yrs,squeeze(mean(SV_run1_2,2,'omitnan'))'-squeeze(mean(SV_count,2,'omitnan'))')
h3 = plot_distribution_prctile(yrs,squeeze(mean(SV_run1_3,2,'omitnan'))'-squeeze(mean(SV_count,2,'omitnan'))')
xlabel('Yrs','Fontsize',16,'Interpreter','latex')
ylabel('Mean difference in shelter volume','Fontsize',16,'Interpreter','latex')
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
%ylim([0,0.0015])
set(l1, 'Fontsize',16,'Interpreter','latex','Location','northwest')
ax=gca;
ax.FontSize = 14;
ax.TickLabelInterpreter = 'latex';
hold off

subplot(1,2,2)
hold on
subtitle('Nat Adt. = 0','Fontsize',18,'Interpreter','latex')
h1 = plot_distribution_prctile(yrs,squeeze(mean(SV_run2_1,2,'omitnan'))'-squeeze(mean(SV_count,2,'omitnan'))')
h2 = plot_distribution_prctile(yrs,squeeze(mean(SV_run2_2,2,'omitnan'))'-squeeze(mean(SV_count,2,'omitnan'))')
h3 = plot_distribution_prctile(yrs,squeeze(mean(SV_run2_3,2,'omitnan'))'-squeeze(mean(SV_count,2,'omitnan'))')
xlabel('Yrs','Fontsize',16,'Interpreter','latex')
ylabel('Mean difference in shelter volume','Fontsize',16,'Interpreter','latex')
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
%ylim([0,0.0015])
set(l1, 'Fontsize',16,'Interpreter','latex','Location','northwest')
ax=gca;
ax.FontSize = 14;
ax.TickLabelInterpreter = 'latex';
hold off

%% Parallel coordinate plots
% Year, Site, species, Coral cover
priority_sites = [221,203,229,155,216];
% sorting data into table
dat_table = zeros(length(10:2:length(yrs))*length(priority_sites)*6,5);
count = 0;
for l = 10:4:length(yrs)
    for sp = 1:6
        for kk = 1:length(priority_sites)
            for run = 1:4
                count = count + 1;
                dat_table(count,1) = l;
                dat_table(count,2) = priority_sites(kk);
                dat_table(count,3) = sp;
                dat_table(count,5) = run;
                if run==1
                    %str = strcat('metrics_run',num2str(run),'_1');
                    dat_table(count,4) = squeeze(mean(Y_g1{11}.coralSpeciesCover(l,sp,priority_sites(kk),1,:),5));
                elseif run==2
                    dat_table(count,4) = squeeze(mean(Y_g1{12}.coralSpeciesCover(l,sp,priority_sites(kk),1,:),5));
                elseif run==3
                    dat_table(count,4) = squeeze(mean(Y_g1{13}.coralSpeciesCover(l,sp,priority_sites(kk),1,:),5));
                else
                    dat_table(count,4) = squeeze(mean(Y_g1{1}.coralSpeciesCover(l,sp,priority_sites(kk),1,:),5));
                end
            end
        end
    end
end
figure(4)
%figure('Units','normalized','Position',[0.3 0.3 0.45 0.4])
coordvars = {'Year','Site','Species','Coral Cover'}
runs = discretize(dat_table(:,5),[0,1.1,2.1,3.1,4.1],'categorical',{'Ass. Adt. 0','Ass. Adt. 4', 'Ass. Adt. 8','Counterfac.'});
coordata = [1 2 3 4];
p = parallelplot([dat_table(:,1:4)],'CoordinateData',coordata,'GroupData',runs)
p.Color = [0.6350 0.0780 0.1840;0.6350 0.0780 0.1840;0.9290 0.6940 0.1250;0 0.4470 0.7410;0 153/255 153/255];
%p.Color = turbo(200);
p.Title='Mean coral cover, top 5 ranked sites, years 10-50';
p.CoordinateTickLabels = coordvars;
p.FontName = 'Serif';

p.FontSize = 16;
p.Jitter = 0.4;
%% Parallel coordinate plots
% Year, Site, Coral cover
priority_sites = [221,203,229,155,216,171,166,263,56,254];
% sorting data into table
dat_table = zeros(length(10:2:length(yrs))*length(priority_sites),4);
count = 0;
for l = 10:2:length(yrs)
        for kk = 1:length(priority_sites)
            for run = 1:4
                count = count + 1;
                dat_table(count,1) = l;
                dat_table(count,2) = priority_sites(kk);
                dat_table(count,4) = run;
                if run==1
                    dat_table(count,3) = squeeze(mean(Y_g1{11}.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));
                elseif run==2
                    dat_table(count,3) = squeeze(mean(Y_g1{12}.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));
                elseif run==3
                    dat_table(count,3) = squeeze(mean(Y_g1{13}.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));
                else
                    dat_table(count,3) = squeeze(mean(Y_g1{1}.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));
                end
            end
        end
end
figure(5)
%figure('Units','normalized','Position',[0.3 0.3 0.45 0.4])
coordvars = {'Year','Site','Coral Cover'}
runs = discretize(dat_table(:,4),[0,1.1,2.1,3.1,4.1],'categorical',{'Ass. Adt. 0','Ass. Adt. 4', 'Ass. Adt. 8','Counterfac.'});
coordata = [1 2 3];
%p.Color = parula(10);
p = parallelplot([dat_table(:,1:3)],'CoordinateData',coordata,'GroupData',runs)
p.Color =  [0.6350 0.0780 0.1840;0.6350 0.0780 0.1840;0.9290 0.6940 0.1250;0 0.4470 0.7410;0 153/255 153/255];
%[0 0.4470 0.7410;0.6350 0.0780 0.1840;0.9290 0.6940 0.1250;0 153/255 153/255];
p.Title='Mean coral cover, top 10 ranked sites, years 10-25';
p.CoordinateTickLabels = coordvars;
p.FontSize = 16;
p.Jitter = 0.4;
p.FontName = 'Serif';

%% Parallel coordinate plots
% Year, Site, Coral cover for run3- counter, coloured by site
priority_sites = [221,203,229,155,216,171,166,263,56,254];
% sorting data into table
dat_table = zeros(length(10:2:length(yrs))*length(priority_sites),3);
count = 0;
for l = 10:2:length(yrs)
        for kk = 1:length(priority_sites)
                count = count + 1;
                dat_table(count,1) = l;
                dat_table(count,2) = priority_sites(kk);
                dat_table(count,3) = squeeze(mean(Y_g1{13}.coralTaxaCover.total_cover(l,priority_sites(kk),:)-Y_g1{1}.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));
        end
end
figure(6)
coordvars = {'Year','Site','Difference in Coral Cover'}
sites = categorical(dat_table(:,2))
coordata = [1 2 3];
p = parallelplot([dat_table(:,1:3)],'CoordinateData',coordata,'GroupData',sites);
p.Color = parula(10)
p.Title ='Ass. Ad. =8, Nat Ad. = 0.2. Top 10 ranked sites, years 10-25';
p.CoordinateTickLabels = coordvars;
p.FontSize = 16;
p.Jitter = 0.2;
p.FontName = 'Serif';

%% Create BBN table

% Table with node headings yr, site, Seed1, Seed2, NatAd, As Adt., Total Cover,
% E, SV
nodeNames = {'Yr','Site','Seed2','AsAdt','NatAd','Coral Cover','Evenness','Shelter Vol.'};
nnodes = length(nodeNames);
nyrs = 50;
nsites = length(depth_priority);
Nint = 13;
sites = 1:nsites;
store_table = zeros((nyrs/2)*Nint*nsites,nnodes);
count = 0;
for l = 1:nyrs
    for s = 1:nsites
        for m = 1:Nint
                 count = count +1;
                 store_table(count,1) = l;
                 store_table(count,2) = s;
                 store_table(count,3:5) = inputs_data(m,3:end);
                 store_table(count,6) = squeeze(mean(Y{guided1(m)}.mean_coralTaxaCover_x_p_total_cover_4(l,depth_priority(s),:),3));
                 store_table(count,7) = squeeze(mean(Y{guided1(m)}.coralEvenness(l,depth_priority(s),:),3));
                 store_table(count,8) = squeeze(mean(Y{guided1(m)}.shelterVolume(l,depth_priority(s),:),3));
        end
    end
end

%% Create BBN

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
inf_cells = [1 3 4 5];
increArray = [9 25 35 49];
nodePos = 1;
knownVars = [200 4 0.2];
F_yrs = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);
% counterfactual
knownVars = [0,0,0];
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
subtitle('Seed2 200, As. Adt. 4 and Nat. Adt. 0.2','Fontsize',16,'Interpreter','latex')
xlabel('Mean coral cover','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
xlim([0,0.6])
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
xlim([0,0.6])
hold off

% plot as histograms
% intervention total coral cover
figure(8)
subplot(1,2,1)
hold on
for b = 1:4
    f = F_yrs{b};
    h = histogram(f{3},20,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle('Seed2 200, As. Adt. 4 and Nat. Adt. 0.2','Fontsize',16,'Interpreter','latex')
xlabel('Mean Evenness','Fontsize',16,'Interpreter','latex')
ylabel('Probability','Fontsize',16,'Interpreter','latex')
l1 = legend('Year 9','Year 25','Year 35','Year 49')
set(l1,'Fontsize',16,'Interpreter','latex')
xlim([0,0.55])
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
xlim([0,0.55])
hold off

% plot as histograms
% intervention total coral cover
figure(9)
subplot(1,2,1)
hold on
for b = 1:4
    f = F_yrs{b};
    h = histogram(f{4},20,'FaceAlpha',0.3);
    h.Normalization = 'probability';
end
subtitle('Seed2 200, As. Adt. 4 and Nat. Adt. 0.2','Fontsize',16,'Interpreter','latex')
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
%% Spatially ploted probabilities
% Intervention
inf_cells = [1:nnodes-3];
F_psites = zeros(3,length(increArray));
increArray = 1:length(depth_priority);
knownVars = [40,200,4,0.2];
nodePos = 2;
F_sites = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);

% Counterfactual
F_psitesc = zeros(3,length(increArray));
knownVars = [40 0 0 0];
F_sitesc = multiBBNInf(store_table,R,knownVars,inf_cells,increArray,nodePos);
val = 0.3;

% Calculate probability coral cover >0.3 for each site
for t = 1:length(increArray)
    f = F_sites{t};
    F_psites(1,t) = calcBBNProb(f{1},val,1);
    F_psites(2,t) = calcBBNProb(f{2},val,1);
    F_psites(3,t) = calcBBNProb(f{3},val,1);
    fc = F_sitesc{t};
    F_psitesc(1,t) = calcBBNProb(fc{1},val,1);
    F_psitesc(2,t) = calcBBNProb(fc{2},val,1);
    F_psitesc(3,t) = calcBBNProb(fc{3},val,1);
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
% Create two axes
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
    %caxis([0.5,1])
    % plot site locations
    txt = text(ax2,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb2,'$P(Coral Cover \geq 0.3)$','FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb2,'TickLabelInterpreter','latex')
 %   hold off

  figure(11)
% %hold on
%title('Seed2 200, As.Ad 4, Nat. Ad. 0.2','Interpreter','latex')
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
%     
%     % Determine where the binary threshold is within the current colormap
%     crng = caxis(ax3);  % range of color values 
%     clrmap = ax3.Colormap; 
%     nColor = size(clrmap,1); 
%     binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
%     binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
%     
%     % Change colormap to binary
%     % White section first to label values less than threshold.
%     newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
%     ax3.Colormap = newColormap; 
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
    %caxis([0.5,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,'$P(Coral Cover \geq 0.3)$','FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')


    
  figure(12)
% %hold on
%title('Seed2 200, As.Ad 4, Nat. Ad. 0.2','Interpreter','latex')
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
%     
%     % Determine where the binary threshold is within the current colormap
%     crng = caxis(ax3);  % range of color values 
%     clrmap = ax3.Colormap; 
%     nColor = size(clrmap,1); 
%     binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
%     binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
%     
%     % Change colormap to binary
%     % White section first to label values less than threshold.
%     newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
%     ax3.Colormap = newColormap; 
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
    %caxis([0.5,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,'$P(Evenness \geq 0.3)$','FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')
    %hold off


  figure(13)
% %hold on
%title('Seed2 200, As.Ad 4, Nat. Ad. 0.2','Interpreter','latex')
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

    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 
%     
%     % Determine where the binary threshold is within the current colormap
%     crng = caxis(ax3);  % range of color values 
%     clrmap = ax3.Colormap; 
%     nColor = size(clrmap,1); 
%     binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
%     binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
%     
%     % Change colormap to binary
%     % White section first to label values less than threshold.
%     newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
%     ax3.Colormap = newColormap; 
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
    %caxis([0.5,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,'$P(Evenness \geq 0.3)$','FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')


  figure(14)
% %hold on
%title('Seed2 200, As.Ad 4, Nat. Ad. 0.2','Interpreter','latex')
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
%     
%     % Determine where the binary threshold is within the current colormap
%     crng = caxis(ax3);  % range of color values 
%     clrmap = ax3.Colormap; 
%     nColor = size(clrmap,1); 
%     binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
%     binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
%     
%     % Change colormap to binary
%     % White section first to label values less than threshold.
%     newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
%     ax3.Colormap = newColormap; 
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
    %caxis([0.5,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,'$P(Shelter Vol. \geq 0.3)$','FontSize',16,'Interpreter','latex');
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
%     
%     % Determine where the binary threshold is within the current colormap
%     crng = caxis(ax3);  % range of color values 
%     clrmap = ax3.Colormap; 
%     nColor = size(clrmap,1); 
%     binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
%     binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
%     
%     % Change colormap to binary
%     % White section first to label values less than threshold.
%     newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
%     ax3.Colormap = newColormap; 
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
    %caxis([0.5,1])
    % plot site locations
    txt = text(ax4,store_map(:,3),store_map(:,2), cellstr(num2str(store_map(:,1))), 'FontSize', 12, 'Color', 'k','Interpreter','latex');
    ylabel(cb4,'$P(Shelter Vol. \geq 0.3)$','FontSize',16,'Interpreter','latex');
    set(txt,'Rotation',30)
    set(cb4,'TickLabelInterpreter','latex')