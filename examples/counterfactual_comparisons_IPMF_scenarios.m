%% ADRIA runs with identical setting to IPMF

n_reps = 50;  % Number of replicate RCP scenarios
ai = ADRIA();

%% Parameter prep
% Collect details of available parameters
param_defaults = ai.raw_defaults;
sim_constants = ai.criterias;

% Get the coral parameters, which are not modified for this example
[~, ~, coral_params] = ai.splitParameterTable(param_defaults);

%% Load site specific data
ai.loadConnectivity('./Inputs/Moore/connectivity/2015');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv',...
    ["Acropora2026", "Goniastrea2026"]);

param_defaults.wave_stress = 0; % waves not considered as criteria
param_defaults.Shadeyrs = 0; % no shading

%% counterfactual 1 - no seeding, no shading, natad = 0.2
param_defaults.Seed1 = 0;
param_defaults.Seed2 = 0;
param_defaults.Natad = 0.2;

Y_count1 = ai.run(param_defaults,sampled_values = false,nreps = n_reps);

metrics_count1 = collectMetrics(Y_count1.Y,coral_params,{@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% No. 1 200,000 corals across 5 sites with Ass. adapt. = 0, nat. ad. = 0.2
param_defaults.Guided = 1;
param_defaults.Seed1 = 20000;
param_defaults.Seed2 = 20000;
param_defaults.Aadpt = 0;

Y_run1_1 = ai.run(param_defaults,sampled_values = false,nreps = n_reps);
metrics_run1_1 = collectMetrics(Y_run1_1.Y,coral_params,{@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% No. 2 with Ass. adapt. = 4
param_defaults.Aadpt = 4;

Y_run1_2 = ai.run(param_defaults,sampled_values = false,nreps = n_reps);
metrics_run1_2 = collectMetrics(Y_run1_2.Y,coral_params,{@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% No.3 with Ass. adapt. = 8
param_defaults.Aadpt = 8;

Y_run1_3 = ai.run(param_defaults,sampled_values = false,nreps = n_reps);
metrics_run1_3 = collectMetrics(Y_run1_3.Y,coral_params,{@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% counterfactual 2 - no seeding no shading, natad = 0
param_defaults.Guided = 0;
param_defaults.Seed1 = 0;
param_defaults.Seed2 = 0;
param_defaults.Natad = 0;

Y_count2 = ai.run(param_defaults,sampled_values = false,nreps = n_reps);
metrics_count2 = collectMetrics(Y_count2.Y,coral_params,{@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% No. 1 200,000 corals across 5 sites with Ass. adapt. = 0, nat. ad. = 0.2
param_defaults.Guided = 1;
param_defaults.Seed1 = 20000;
param_defaults.Seed2 = 20000;
param_defaults.Aadpt = 0;

Y_run2_1 = ai.run(param_defaults,sampled_values = false,nreps = n_reps);
metrics_run2_1 = collectMetrics(Y_run2_1.Y,coral_params,{@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% No. 2 with Ass. adapt. = 4
param_defaults.Aadpt = 4;

Y_run2_2 = ai.run(param_defaults,sampled_values = false,nreps = n_reps);
metrics_run2_2 = collectMetrics(Y_run2_2.Y,coral_params,{@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% No.3 with Ass. adapt. = 8
param_defaults.Aadpt = 8;

Y_run2_3 = ai.run(param_defaults,sampled_values = false,nreps = n_reps);
metrics_run2_3 = collectMetrics(Y_run2_3.Y,coral_params,{@coralTaxaCover, @coralSpeciesCover, ...
                     @coralEvenness, @shelterVolume});

%% Retrieve depth filtered sitesa for plotting
% depth_min = 5;
% depth_offset = 5;
% sdata = readtable('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv');
% site_data = sdata(:,[["site_id","k",["Acropora2026","Goniastrea2026"],"sitedepth","recom_connectivity"]]);
% site_data = sortrows(site_data, "recom_connectivity");
% max_depth = depth_min+depth_offset;
% depth_criteria = (site_data.sitedepth >-max_depth)&(site_data.sitedepth<-depth_min);
% depth_priority = site_data{depth_criteria,"recom_connectivity"};

%% Plotting coral cover vs. years
yrs = 1:25;
% difference to counterfactual with natural adaptation
difftot_run1_1 = squeeze(mean((metrics_run1_1.coralTaxaCover.total_cover-metrics_count1.coralTaxaCover.total_cover),2));
difftot_run1_2 = squeeze(mean((metrics_run1_2.coralTaxaCover.total_cover-metrics_count1.coralTaxaCover.total_cover),2));
difftot_run1_3 = squeeze(mean((metrics_run1_3.coralTaxaCover.total_cover-metrics_count1.coralTaxaCover.total_cover),2));

% difference to counterfactual without natural adaptation
difftot_run2_1 = squeeze(mean((metrics_run2_1.coralTaxaCover.total_cover-metrics_count2.coralTaxaCover.total_cover),2));
difftot_run2_2 = squeeze(mean((metrics_run2_2.coralTaxaCover.total_cover-metrics_count2.coralTaxaCover.total_cover),2));
difftot_run2_3 = squeeze(mean((metrics_run2_3.coralTaxaCover.total_cover-metrics_count2.coralTaxaCover.total_cover),2));

% ploting coral cover total over years with spread
figure(1)
subplot(1,2,1)
hold on
title('Difference in total cover, Nat Adt. = 0.2','Fontsize',18)
h1 = plot_distribution_prctile(yrs,difftot_run1_1')
h2 = plot_distribution_prctile(yrs,difftot_run1_2')
h3 = plot_distribution_prctile(yrs,difftot_run1_3')
xlabel('Yrs','Fontsize',16)
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
set(l1, 'Fontsize',16)
%ylim([0,0.0003])
ax=gca;
ax.FontSize = 14;
hold off

subplot(1,2,2)
hold on
title('Difference in total cover, Nat Adt. = 0','Fontsize',18)
h1 = plot_distribution_prctile(yrs,difftot_run2_1')
h2 = plot_distribution_prctile(yrs,difftot_run2_2')
h3 = plot_distribution_prctile(yrs,difftot_run2_3')
xlabel('Yrs','Fontsize',16)
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
set(l1, 'Fontsize',16)
%ylim([0,0.0003])
ax=gca;
ax.FontSize = 14;
hold off


%% ploting evenness
Ev_run1_1 = metrics_run1_1.coralEvenness;
Ev_run1_2 = metrics_run1_2.coralEvenness;
Ev_run1_3 = metrics_run1_3.coralEvenness;
Ev_count1 = metrics_count1.coralEvenness;

Ev_run2_1 = metrics_run2_1.coralEvenness;
Ev_run2_2 = metrics_run2_2.coralEvenness;
Ev_run2_3 = metrics_run2_3.coralEvenness;
Ev_count2 = metrics_count2.coralEvenness;
% ind_TC_run1_1 = ones(length(TC_run1_1(:)));
% ind_TC_run1_2 = 2*ones(length(TC_run1_1(:)));
% ind_TC_run1_3 = 3*ones(length(TC_run1_1(:)));
% ind_TC_count1 = zeros(length(TC_run1_1(:)));

% ploting coral cover total over years with spread
figure(2)
subplot(1,2,1)
hold on
title('Difference in coral evenness, Nat Adt. = 0.2','Fontsize',18)
h1 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run1_1,2,'omitnan'))'-squeeze(mean(Ev_count1,2,'omitnan'))')
h2 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run1_2,2,'omitnan'))'-squeeze(mean(Ev_count1,2,'omitnan'))')
h3 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run1_3,2,'omitnan'))'-squeeze(mean(Ev_count1,2,'omitnan'))')
xlabel('Yrs','Fontsize',16)
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
set(l1, 'Fontsize',16)
%ylim([0,0.0015])
ax=gca;
ax.FontSize = 14;
hold off

subplot(1,2,2)
hold on
title('Difference in coral evenness, Nat Adt. = 0','Fontsize',18)
h1 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run2_1,2,'omitnan'))'-squeeze(mean(Ev_count2,2,'omitnan'))')
h2 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run2_2,2,'omitnan'))'-squeeze(mean(Ev_count2,2,'omitnan'))')
h3 = plot_distribution_prctile(yrs,squeeze(mean(Ev_run2_3,2,'omitnan'))'-squeeze(mean(Ev_count2,2,'omitnan'))')
xlabel('Yrs','Fontsize',16)
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
%ylim([0,0.0015])
set(l1, 'Fontsize',16)
ax=gca;
ax.FontSize = 14;
hold off

%% Plotting Shelter Volume vs. years
% % difference to counterfactual with natural adaptation
SV_run1_1 = metrics_run1_1.shelterVolume;
SV_run1_2 = metrics_run1_2.shelterVolume;
SV_run1_3 = metrics_run1_3.shelterVolume;
SV_count1 = metrics_count1.shelterVolume;
 
SV_run2_1 = metrics_run2_1.shelterVolume;
SV_run2_2 = metrics_run2_2.shelterVolume;
SV_run2_3 = metrics_run2_3.shelterVolume;
SV_count2 = metrics_count2.shelterVolume;

figure(3)
subplot(1,2,1)
hold on
title('Shelter volume, Nat Adt. = 0.2','Fontsize',18)
h1 = plot_distribution_prctile(yrs,squeeze(mean(SV_run1_1,2,'omitnan'))'-squeeze(mean(SV_count1,2,'omitnan'))')
h2 = plot_distribution_prctile(yrs,squeeze(mean(SV_run1_2,2,'omitnan'))'-squeeze(mean(SV_count1,2,'omitnan'))')
h3 = plot_distribution_prctile(yrs,squeeze(mean(SV_run1_3,2,'omitnan'))'-squeeze(mean(SV_count1,2,'omitnan'))')
xlabel('Yrs','Fontsize',16)
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
%ylim([0,0.0015])
set(l1, 'Fontsize',16)
ax=gca;
ax.FontSize = 14;
hold off

subplot(1,2,2)
hold on
title('Shelter volume, Nat Adt. = 0','Fontsize',18)
h1 = plot_distribution_prctile(yrs,squeeze(mean(SV_run2_1,2,'omitnan'))'-squeeze(mean(SV_count2,2,'omitnan'))')
h2 = plot_distribution_prctile(yrs,squeeze(mean(SV_run2_2,2,'omitnan'))'-squeeze(mean(SV_count2,2,'omitnan'))')
h3 = plot_distribution_prctile(yrs,squeeze(mean(SV_run2_3,2,'omitnan'))'-squeeze(mean(SV_count2,2,'omitnan'))')
xlabel('Yrs','Fontsize',16)
l1 = legend([h1(1) h2(1) h3(1)],'Ass. Adt. = 0','Ass. Adt. = 4','Ass. Adt. = 8')
%ylim([0,0.0015])
set(l1, 'Fontsize',16)
ax=gca;
ax.FontSize = 14;
hold off

%% Parallel coordinate plots
% Year, Site, species, Coral cover
priority_sites = [221,203,229,155,216];
% sorting data into table
dat_table = zeros(length(10:2:length(yrs))*length(priority_sites)*6,5);
count = 0;
for l = 10:2:length(yrs)
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
                    dat_table(count,4) = squeeze(mean(metrics_run1_1.coralSpeciesCover(l,sp,priority_sites(kk),1,:),5));
                elseif run==2
                    dat_table(count,4) = squeeze(mean(metrics_run1_2.coralSpeciesCover(l,sp,priority_sites(kk),1,:),5));
                elseif run==3
                    dat_table(count,4) = squeeze(mean(metrics_run1_3.coralSpeciesCover(l,sp,priority_sites(kk),1,:),5));
                else
                    dat_table(count,4) = squeeze(mean(metrics_count1.coralSpeciesCover(l,sp,priority_sites(kk),1,:),5));
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
p.Color = [0.6350 0.0780 0.1840;0.6350 0.0780 0.1840;0.9290 0.6940 0.1250;0 0.4470 0.7410];
p.Title='Coral cover, top 5 ranked sites, years 10-25';
p.CoordinateTickLabels = coordvars;
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
            for run = 1:3
                count = count + 1;
                dat_table(count,1) = l;
                dat_table(count,2) = priority_sites(kk);
                dat_table(count,4) = run;
                if run==1
                    %str = strcat('metrics_run',num2str(run),'_1');
                    dat_table(count,3) = squeeze(mean(metrics_run1_1.coralTaxaCover.total_cover(l,priority_sites(kk),:)-metrics_count1.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));
                elseif run==2
                    dat_table(count,3) = squeeze(mean(metrics_run1_2.coralTaxaCover.total_cover(l,priority_sites(kk),:)-metrics_count1.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));
                else
                    dat_table(count,3) = squeeze(mean(metrics_run1_3.coralTaxaCover.total_cover(l,priority_sites(kk),:)-metrics_count1.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));
                end
            end
        end
end
figure(5)
%figure('Units','normalized','Position',[0.3 0.3 0.45 0.4])
coordvars = {'Year','Site','Difference in Coral Cover'}
runs = discretize(dat_table(:,4),[0,1.1,2.1,3.1],'categorical',{'Ass. Adt. 0','Ass. Adt. 4', 'Ass. Adt. 8'});
coordata = [1 2 3];
p = parallelplot([dat_table(:,1:3)],'CoordinateData',coordata,'GroupData',runs)
p.Color = [;0 0.4470 0.7410;0.6350 0.0780 0.1840;0.9290 0.6940 0.1250];
p.Title='Difference in coral cover to cf, top 10 ranked sites, years 10-25';
p.CoordinateTickLabels = coordvars;
p.FontSize = 16;
p.Jitter = 0.4;

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
                dat_table(count,3) = squeeze(mean(metrics_run1_3.coralTaxaCover.total_cover(l,priority_sites(kk),:)-metrics_count1.coralTaxaCover.total_cover(l,priority_sites(kk),:),3));

        end
end
figure(6)
%figure('Units','normalized','Position',[0.3 0.3 0.45 0.4])
coordvars = {'Year','Site','Difference in Coral Cover'}
sites = categorical(dat_table(:,2))
coordata = [1 2 3];
p = parallelplot([dat_table(:,1:3)],'CoordinateData',coordata,'GroupData',sites)
p.Color = parula(10)
p.Title='Difference in coral cover to cf, top 10 ranked sites, years 10-25';
p.CoordinateTickLabels = coordvars;
p.FontSize = 16;
p.Jitter = 0.4;