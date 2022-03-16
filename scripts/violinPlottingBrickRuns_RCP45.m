%% Loading counterfactual and intervention data
out_45 = load('./Outputs/brick_runs_RCP45.mat');

%% Violin plots with site spread
yr = linspace(2026,2099,74);
% first, extract counterfactual and intervention Seed 500, Aadpt 4, Natad
% 0.05
tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
tgt_ind_int = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));

selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_cf);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_cf);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_cf);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_cf);

%% plot every 5 yrs
fig = figure(1)
subplot(2,2,1)
hold on
plot(yr(1),selected_int_TC.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_TC.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.6])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Coral Cover','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,2)
hold on
plot(yr(1),selected_int_Ev.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ev.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.95])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Evenness','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,3)
hold on
plot(yr(1),selected_int_SV.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_SV.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.3])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Relative Shelter Volume','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,4)
hold on
plot(yr(1),selected_int_Ju.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ju.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.25])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Juveniles','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

%% extract counterfactual and intervention Seed 500, Aadpt 0, Natad
% 0
tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
tgt_ind_int = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==1));

selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_cf);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_cf);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_cf);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_cf);

%% plot every 5 yrs
fig = figure(1)
subplot(2,2,1)
hold on
plot(yr(1),selected_int_TC.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_TC.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.6])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Coral Cover','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,2)
hold on
plot(yr(1),selected_int_Ev.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ev.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.95])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Evenness','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,3)
hold on
plot(yr(1),selected_int_SV.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_SV.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.3])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Relative Shelter Volume','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,4)
hold on
plot(yr(1),selected_int_Ju.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ju.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.25])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Juveniles','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off
%% extract intervention Seed 500, Aadpt 4, Natad
% 0.05 comparison with delayed seeding and shading - starting year 2 vs.
% year 11
tgt_ind_int1 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
tgt_ind_int2 = find((out_45.inputs.Seedyr_start==16)&(out_45.inputs.Shadeyr_start==16)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int1);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int2);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int1);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int2);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int1);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_int2);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int1);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int2);

%% plot every 5 yrs
fig = figure(1)
subplot(2,2,1)
hold on
plot(yr(1),selected_int_TC.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_TC.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.6])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Coral Cover','Fontsize',16,'Interpreter','latex')
ll = legend('Delayed','Not Delayed')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,2)
hold on
plot(yr(1),selected_int_Ev.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ev.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.95])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Evenness','Fontsize',16,'Interpreter','latex')
ll = legend('Delayed','Not Delayed')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,3)
hold on
plot(yr(1),selected_int_SV.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_SV.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.3])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Relative Shelter Volume','Fontsize',16,'Interpreter','latex')
ll = legend('Delayed','Not Delayed')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,4)
hold on
plot(yr(1),selected_int_Ju.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ju.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.25])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Juveniles','Fontsize',16,'Interpreter','latex')
ll = legend('Delayed','Not Delayed')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

%% extract intervention Seed 500, Aadpt 4, Natad
% Guided vs. unguided
tgt_ind_int1 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
tgt_ind_int2 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==0));
selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int1);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int2);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int1);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int2);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int1);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_int2);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int1);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int2);

%% plot every 5 yrs
fig = figure(1)
subplot(2,2,1)
hold on
plot(yr(1),selected_int_TC.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_TC.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.6])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Coral Cover','Fontsize',16,'Interpreter','latex')
ll = legend('Unguided','Guided')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,2)
hold on
plot(yr(1),selected_int_Ev.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ev.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.95])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Evenness','Fontsize',16,'Interpreter','latex')
ll = legend('Unguided','Guided')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,3)
hold on
plot(yr(1),selected_int_SV.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_SV.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.3])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Relative Shelter Volume','Fontsize',16,'Interpreter','latex')
ll = legend('Unguided','Guided')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,4)
hold on
plot(yr(1),selected_int_Ju.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ju.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.25])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Juveniles','Fontsize',16,'Interpreter','latex')
ll = legend('Unguided','Guided')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

%% extract intervention Seed 500, Aadpt 4, Natad
% Guided vs. unguided
tgt_ind_int1 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
tgt_ind_int2 = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==500000)&(out_45.inputs.Seed2==500000)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));
selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int1);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int2);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int1);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int2);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int1);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_int2);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int1);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int2);

%% plot every 5 yrs
fig = figure(1)
subplot(2,2,1)
hold on
plot(yr(1),selected_int_TC.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_TC.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.6])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Coral Cover','Fontsize',16,'Interpreter','latex')
ll = legend('Unguided','Guided')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,2)
hold on
plot(yr(1),selected_int_Ev.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ev.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.95])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Evenness','Fontsize',16,'Interpreter','latex')
ll = legend('Unguided','Guided')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,3)
hold on
plot(yr(1),selected_int_SV.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_SV.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.3])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Relative Shelter Volume','Fontsize',16,'Interpreter','latex')
ll = legend('Unguided','Guided')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,4)
hold on
plot(yr(1),selected_int_Ju.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ju.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.25])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Juveniles','Fontsize',16,'Interpreter','latex')
ll = legend('Unguided','Guided')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

%% extract counterfactual and intervention Seed Aadpt 4, Natad
% 0.05, fogging 0.2
tgt_ind_cf = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==0)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0)&(out_45.inputs.Natad==0)&(out_45.inputs.Aadpt==0)&(out_45.inputs.Guided==0));
tgt_ind_int = find((out_45.inputs.Seedyr_start==2)&(out_45.inputs.Shadeyr_start==2)&(out_45.inputs.Shadefreq==1)&(out_45.inputs.Seedfreq==3)&(out_45.inputs.Shadeyrs==20)&(out_45.inputs.Seedyrs==5)&(out_45.inputs.Seed1==0)&(out_45.inputs.Seed2==0)&(out_45.inputs.SRM==0)&(out_45.inputs.fogging==0.2)&(out_45.inputs.Natad==0.05)&(out_45.inputs.Aadpt==4)&(out_45.inputs.Guided==1));

selected_int_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_int);
selected_cf_TC = filterSummary(out_45.coralTaxaCover_x_p_total_cover, tgt_ind_cf);
selected_int_Ev = filterSummary(out_45.coralEvenness, tgt_ind_int);
selected_cf_Ev = filterSummary(out_45.coralEvenness, tgt_ind_cf);
selected_int_SV = filterSummary(out_45.shelterVolume, tgt_ind_int);
selected_cf_SV = filterSummary(out_45.shelterVolume, tgt_ind_cf);
selected_int_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_int);
selected_cf_Ju = filterSummary(out_45.coralTaxaCover_x_p_juveniles, tgt_ind_cf);

%% plot every 5 yrs
fig = figure(1)
subplot(2,2,1)
hold on
plot(yr(1),selected_int_TC.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_TC.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.6])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Coral Cover','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,2)
hold on
plot(yr(1),selected_int_Ev.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ev.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ev.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.95])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Evenness','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,3)
hold on
plot(yr(1),selected_int_SV.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_SV.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_SV.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.3])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Relative Shelter Volume','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off

subplot(2,2,4)
hold on
plot(yr(1),selected_int_Ju.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_Ju.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_Ju.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.25])
xlabel('Year','Fontsize',16,'Interpreter','latex')
ylabel('Juveniles','Fontsize',16,'Interpreter','latex')
ll = legend('Counterf.','Interv.')
set(ll,'Interpreter','latex','Fontsize',12)
hold off
