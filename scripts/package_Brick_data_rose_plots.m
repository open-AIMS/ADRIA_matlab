%% Loading counterfactual and intervention data
out_45 = load('./Outputs/brick_runs_RCP45_2.mat');
out_45_RCI = load('./Outputs/brick_runs_RCP45_RCI_no_evenness.mat');

% load extra runs for fogging
fog_runs = load("./Outputs/reruns_long_fog_brick_scens_all_metrics.mat");
sites = 1:561;
%% Create data table of interv - cf for 8 scenarios
% 1: Just seed
% 2: Seed + 4DHW
% 3: Seed + 8DHW
% 4: Seed + 4DHW + 0.05 Natad
% 5: Just fog
% 6: fog + 4DHW
% 7: fog + 8DHW
% 8: fog + 4DHW + 0.05 Natad

% table will have columns sites(top 10) %change from cf
% (Coral Cover, Evenness, Shelter Volume, Juveniles, RCI)

%% counterfactual
tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_cf);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_cf);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_cf);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_cf);
selected_cf_RCI = filterSummary(out_45_RCI, tgt_ind_cf);

selected_cf_TC = squeeze(mean(selected_cf_TC.mean,1));
selected_cf_SV = squeeze(mean(selected_cf_SV.mean,1));
selected_cf_Ju = squeeze(mean(selected_cf_Ju.mean,1));
selected_cf_Ev = squeeze(mean(selected_cf_Ev.mean,1));
selected_cf_RCI = squeeze(mean(selected_cf_RCI.mean,1));

%% first, non fogging runs
% ranks data
site_rankings = squeeze(out_45.site_rankings(:,1,:));

%% 1: Just seed
tgt_ind_int1 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==1));
selected_int1_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int1);
selected_int1_SV = filterSummary(out_45.shelterVolume, tgt_ind_int1);
selected_int1_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int1);
selected_int1_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int1);
selected_int1_RCI = filterSummary(out_45_RCI, tgt_ind_int1);

selected_int1_TC = squeeze(mean(selected_int1_TC.mean,1));
selected_int1_SV = squeeze(mean(selected_int1_SV.mean,1));
selected_int1_Ju = squeeze(mean(selected_int1_Ju.mean,1));
selected_int1_Ev = squeeze(mean(selected_int1_Ev.mean,1));
selected_int1_RCI = squeeze(mean(selected_int1_RCI.mean,1));

% find top 10 sites for this scenario
site_ranks1 = site_rankings(:,tgt_ind_int1);
temp_ranks = [sites',site_ranks1];
temp_order = sortrows(temp_ranks,2,'ascend');
sites1 = temp_order(:,1);

mean_tc1 = ((selected_int1_TC(:,sites1)-selected_cf_TC(:,sites1))./selected_cf_TC(:,sites1))'.*100;
mean_sv1 = ((selected_int1_SV(:,sites1)-selected_cf_SV(:,sites1))./selected_cf_SV(:,sites1))'.*100;
mean_ju1 = ((selected_int1_Ju(:,sites1)-selected_cf_Ju(:,sites1))./selected_cf_Ju(:,sites1))'.*100;
mean_ev1 = ((selected_int1_Ev(:,sites1)-selected_cf_Ev(:,sites1))./selected_cf_Ev(:,sites1))'.*100;
mean_rci1 = ((selected_int1_RCI(:,sites1)-selected_cf_RCI(:,sites1))./selected_cf_RCI(:,sites1))'.*100;
table1 = table([sites1,mean_tc1,mean_sv1,mean_ju1,mean_ev1,mean_rci1]);
writetable(table1,'scen1_table_Brickruns.csv')

%% 2: Seed + 4DHW
tgt_ind_int2 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
selected_int2_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int2);
selected_int2_SV = filterSummary(out_45.shelterVolume, tgt_ind_int2);
selected_int2_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int2);
selected_int2_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int2);
selected_int2_RCI = filterSummary(out_45_RCI, tgt_ind_int2);

selected_int2_TC = squeeze(mean(selected_int2_TC.mean,1));
selected_int2_SV = squeeze(mean(selected_int2_SV.mean,1));
selected_int2_Ju = squeeze(mean(selected_int2_Ju.mean,1));
selected_int2_Ev = squeeze(mean(selected_int2_Ev.mean,1));
selected_int2_RCI = squeeze(mean(selected_int2_RCI.mean,1));

% find top 10 sites for this scenario
site_ranks2 = site_rankings(:,tgt_ind_int2);
temp_ranks = [sites',site_ranks2];
temp_order = sortrows(temp_ranks,2,'ascend');
sites2 = temp_order(:,1);

mean_tc2 = ((selected_int2_TC(:,sites2)-selected_cf_TC(:,sites2))./selected_cf_TC(:,sites2))'.*100;
mean_sv2 = ((selected_int2_SV(:,sites2)-selected_cf_SV(:,sites2))./selected_cf_SV(:,sites2))'.*100;
mean_ju2 = ((selected_int2_Ju(:,sites2)-selected_cf_Ju(:,sites2))./selected_cf_Ju(:,sites2))'.*100;
mean_ev2 = ((selected_int2_Ev(:,sites2)-selected_cf_Ev(:,sites2))./selected_cf_Ev(:,sites2))'.*100;
mean_rci2 = ((selected_int2_RCI(:,sites2)-selected_cf_RCI(:,sites2))./selected_cf_RCI(:,sites2))'.*100;
table2 = table([sites2,mean_tc2,mean_sv2,mean_ju2,mean_ev2,mean_rci2]);
writetable(table2,'scen2_table_Brickruns.csv');

%% 3: Seed + 8DHW
tgt_ind_int3 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==8)&(out_45.inputs.Guided==1));
selected_int3_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int3);
selected_int3_SV = filterSummary(out_45.shelterVolume, tgt_ind_int3);
selected_int3_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int3);
selected_int3_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int3);
selected_int3_RCI = filterSummary(out_45_RCI, tgt_ind_int3);

selected_int3_TC = squeeze(mean(selected_int3_TC.mean,1));
selected_int3_SV = squeeze(mean(selected_int3_SV.mean,1));
selected_int3_Ju = squeeze(mean(selected_int3_Ju.mean,1));
selected_int3_Ev = squeeze(mean(selected_int3_Ev.mean,1));
selected_int3_RCI = squeeze(mean(selected_int3_RCI.mean,1));

% find top 10 sites for this scenario
site_ranks3 = site_rankings(:,tgt_ind_int3);
temp_ranks = [sites',site_ranks3];
temp_order = sortrows(temp_ranks,2,'ascend');
sites3 = temp_order(:,1);

mean_tc3 = ((selected_int3_TC(:,sites3)-selected_cf_TC(:,sites3))./selected_cf_TC(:,sites3))'.*100;
mean_sv3 = ((selected_int3_SV(:,sites3)-selected_cf_SV(:,sites3))./selected_cf_SV(:,sites3))'.*100;
mean_ju3 = ((selected_int3_Ju(:,sites3)-selected_cf_Ju(:,sites3))./selected_cf_Ju(:,sites3))'.*100;
mean_ev3 = ((selected_int3_Ev(:,sites3)-selected_cf_Ev(:,sites3))./selected_cf_Ev(:,sites3))'.*100;
mean_rci3 = ((selected_int3_RCI(:,sites3)-selected_cf_RCI(:,sites3))./selected_cf_RCI(:,sites3))'.*100;
table3 = table([sites3,mean_tc3,mean_sv3,mean_ju3,mean_ev3,mean_rci3]);
writetable(table3,'scen3_table_Brickruns.csv');

%% 4: Seed + 4DHW + 0.05 Natad

tgt_ind_int4 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==8)&(out_45.inputs.Guided==1));
selected_int4_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int4);
selected_int4_SV = filterSummary(out_45.shelterVolume, tgt_ind_int4);
selected_int4_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int4);
selected_int4_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int4);
selected_int4_RCI = filterSummary(out_45_RCI, tgt_ind_int4);

selected_int4_TC = squeeze(mean(selected_int4_TC.mean,1));
selected_int4_SV = squeeze(mean(selected_int4_SV.mean,1));
selected_int4_Ju = squeeze(mean(selected_int4_Ju.mean,1));
selected_int4_Ev = squeeze(mean(selected_int4_Ev.mean,1));
selected_int4_RCI = squeeze(mean(selected_int4_RCI.mean,1));

% find top 10 sites for this scenario
site_ranks4 = site_rankings(:,tgt_ind_int4);
temp_ranks = [sites',site_ranks4];
temp_order = sortrows(temp_ranks,2,'ascend');
sites4 = temp_order(:,1);

mean_tc4 = ((selected_int4_TC(:,sites4)-selected_cf_TC(:,sites4))./selected_cf_TC(:,sites4))'.*100;
mean_sv4 = ((selected_int4_SV(:,sites4)-selected_cf_SV(:,sites4))./selected_cf_SV(:,sites4))'.*100;
mean_ju4 = ((selected_int4_Ju(:,sites4)-selected_cf_Ju(:,sites4))./selected_cf_Ju(:,sites4))'.*100;
mean_ev4 = ((selected_int4_Ev(:,sites4)-selected_cf_Ev(:,sites4))./selected_cf_Ev(:,sites4))'.*100;
mean_rci4 = ((selected_int4_RCI(:,sites4)-selected_cf_RCI(:,sites4))./selected_cf_RCI(:,sites4))'.*100;
table4 = table([sites4,mean_tc4,mean_sv4,mean_ju4,mean_ev4,mean_rci4]);
writetable(table4,'scen4_table_Brickruns.csv');

%% Next, fogging runs
%% 5: Just fog
selected_int5_TC = squeeze(mean(fog_runs.reruns_2.TC_mean,1));
selected_int5_SV = squeeze(mean(fog_runs.reruns_2.SV_mean,1));
selected_int5_Ju = squeeze(mean(fog_runs.reruns_2.Ju_mean,1));
selected_int5_Ev = squeeze(mean(fog_runs.reruns_2.Ev_mean,1));
selected_int5_RCI = squeeze(mean(fog_runs.reruns_2.RCI_mean,1));

% find top 10 sites for this scenario
site_ranks5 = squeeze(mean(mean(fog_runs.reruns_2.site_rankings,5),1));
temp_ranks = [sites',site_ranks5(:,1)];
temp_order = sortrows(temp_ranks,2,'ascend');
sites5 = temp_order(:,1);

mean_tc5 = ((selected_int5_TC(:,sites5)-selected_cf_TC(:,sites5))./selected_cf_TC(:,sites5))'.*100;
mean_sv5 = ((selected_int5_SV(:,sites5)-selected_cf_SV(:,sites5))./selected_cf_SV(:,sites5))'.*100;
mean_ju5 = ((selected_int5_Ju(:,sites5)-selected_cf_Ju(:,sites5))./selected_cf_Ju(:,sites5))'.*100;
mean_ev5 = ((selected_int5_Ev(:,sites5)-selected_cf_Ev(:,sites5))./selected_cf_Ev(:,sites5))'.*100;
mean_rci5 = ((selected_int5_RCI(:,sites5)-selected_cf_RCI(:,sites5))./selected_cf_RCI(:,sites5))'.*100;
table5 = table([sites5,mean_tc5,mean_sv5,mean_ju5,mean_ev5,mean_rci5]);
writetable(table5,'scen5_table_Brickruns.csv');

%% 6: fog + 4DHW
selected_int6_TC = squeeze(mean(fog_runs.reruns_3.TC_mean,1));
selected_int6_SV = squeeze(mean(fog_runs.reruns_3.SV_mean,1));
selected_int6_Ju = squeeze(mean(fog_runs.reruns_3.Ju_mean,1));
selected_int6_Ev = squeeze(mean(fog_runs.reruns_3.Ev_mean,1));
selected_int6_RCI = squeeze(mean(fog_runs.reruns_3.RCI_mean,1));

% find top 10 sites for this scenario
site_ranks6 = squeeze(mean(mean(fog_runs.reruns_3.site_rankings,5),1));
temp_ranks = [sites',site_ranks6(:,1)];
temp_order = sortrows(temp_ranks,2,'ascend');
sites6 = temp_order(:,1);

mean_tc6 = ((selected_int6_TC(:,sites6)-selected_cf_TC(:,sites6))./selected_cf_TC(:,sites6))'.*100;
mean_sv6 = ((selected_int6_SV(:,sites6)-selected_cf_SV(:,sites6))./selected_cf_SV(:,sites6))'.*100;
mean_ju6 = ((selected_int6_Ju(:,sites6)-selected_cf_Ju(:,sites6))./selected_cf_Ju(:,sites6))'.*100;
mean_ev6 = ((selected_int6_Ev(:,sites6)-selected_cf_Ev(:,sites6))./selected_cf_Ev(:,sites6))'.*100;
mean_rci6 = ((selected_int6_RCI(:,sites6)-selected_cf_RCI(:,sites6))./selected_cf_RCI(:,sites6))'.*100;
table6 = table([sites6,mean_tc6,mean_sv6,mean_ju6,mean_ev6,mean_rci6]);
writetable(table6,'scen6_table_Brickruns.csv');

%% 7: fog + 8DHW
selected_int7_TC = squeeze(mean(fog_runs.reruns_5.TC_mean,1));
selected_int7_SV = squeeze(mean(fog_runs.reruns_5.SV_mean,1));
selected_int7_Ju = squeeze(mean(fog_runs.reruns_5.Ju_mean,1));
selected_int7_Ev = squeeze(mean(fog_runs.reruns_5.Ev_mean,1));
selected_int7_RCI = squeeze(mean(fog_runs.reruns_5.RCI_mean,1));

% find top 10 sites for this scenario
site_ranks7 = squeeze(mean(mean(fog_runs.reruns_5.site_rankings,5),1));
temp_ranks = [sites',site_ranks7(:,1)];
temp_order = sortrows(temp_ranks,2,'ascend');
sites7 = temp_order(:,1);

mean_tc7 = ((selected_int7_TC(:,sites7)-selected_cf_TC(:,sites7))./selected_cf_TC(:,sites7))'.*100;
mean_sv7 = ((selected_int7_SV(:,sites7)-selected_cf_SV(:,sites7))./selected_cf_SV(:,sites7))'.*100;
mean_ju7 = ((selected_int7_Ju(:,sites7)-selected_cf_Ju(:,sites7))./selected_cf_Ju(:,sites7))'.*100;
mean_ev7 = ((selected_int7_Ev(:,sites7)-selected_cf_Ev(:,sites7))./selected_cf_Ev(:,sites7))'.*100;
mean_rci7 = ((selected_int7_RCI(:,sites7)-selected_cf_RCI(:,sites7))./selected_cf_RCI(:,sites7))'.*100;
table7 = table([sites7,mean_tc7,mean_sv7,mean_ju7,mean_ev7,mean_rci7]);
writetable(table7,'scen7_table_Brickruns.csv');

%% 8: fog + 4DHW + 0.05 Natad
selected_int8_TC = squeeze(mean(fog_runs.reruns_6.TC_mean,1));
selected_int8_SV = squeeze(mean(fog_runs.reruns_6.SV_mean,1));
selected_int8_Ju = squeeze(mean(fog_runs.reruns_6.Ju_mean,1));
selected_int8_Ev = squeeze(mean(fog_runs.reruns_6.Ev_mean,1));
selected_int8_RCI = squeeze(mean(fog_runs.reruns_6.RCI_mean,1));

% find top 10 sites for this scenario
site_ranks8 = squeeze(mean(mean(fog_runs.reruns_6.site_rankings,5),1));
temp_ranks = [sites',site_ranks8(:,1)];
temp_order = sortrows(temp_ranks,2,'ascend');
sites8 = temp_order(:,1);

mean_tc8 = ((selected_int8_TC(:,sites8)-selected_cf_TC(:,sites8))./selected_cf_TC(:,sites8))'.*100;
mean_sv8 = ((selected_int8_SV(:,sites8)-selected_cf_SV(:,sites8))./selected_cf_SV(:,sites8))'.*100;
mean_ju8 = ((selected_int8_Ju(:,sites8)-selected_cf_Ju(:,sites8))./selected_cf_Ju(:,sites8))'.*100;
mean_ev8 = ((selected_int8_Ev(:,sites8)-selected_cf_Ev(:,sites8))./selected_cf_Ev(:,sites8))'.*100;
mean_rci8 = ((selected_int8_RCI(:,sites8)-selected_cf_RCI(:,sites8))./selected_cf_RCI(:,sites8))'.*100;
table8 = table([sites8,mean_tc8,mean_sv8,mean_ju8,mean_ev8,mean_rci8]);
writetable(table8,'scen8_table_Brickruns.csv');
