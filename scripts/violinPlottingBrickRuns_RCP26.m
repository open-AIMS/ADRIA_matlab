%% Loading counterfactual and intervention data
out_26 = load('./Outputs/brick_runs_RCP26.mat');

%% Violin plots with site spread
yr = linspace(2026,2099,74);
% first, extract counterfactual and intervention Seed 500, Aadpt 4, Natad
% 0.05
tgt_ind_cf = find((out_26.inputs.Seedyr_start==2)&(out_26.inputs.Shadeyr_start==2)&(out_26.inputs.Seedyrs==5)&(out_26.inputs.Shadeyrs==20)&(out_26.inputs.Shadefreq==1)&(out_26.inputs.Seedfreq==0)&(out_26.inputs.Seed1==0)&(out_26.inputs.Seed2==0)&(out_26.inputs.SRM==0)&(out_26.inputs.fogging==0)&(out_26.inputs.Natad==0)&(out_26.inputs.Aadpt==0)&(out_26.inputs.Guided==0));
tgt_ind_int = find((out_26.inputs.Seedyr_start==2)&(out_26.inputs.Shadeyr_start==2)&(out_26.inputs.Shadefreq==1)&(out_26.inputs.Seedfreq==3)&(out_26.inputs.Shadeyrs==20)&(out_26.inputs.Seedyrs==5)&(out_26.inputs.Seed1==500000)&(out_26.inputs.Seed2==500000)&(out_26.inputs.SRM==0)&(out_26.inputs.fogging==0)&(out_26.inputs.Natad==0.05)&(out_26.inputs.Aadpt==4)&(out_26.inputs.Guided==1));

selected_int_TC = filterSummary(out_26.coralTaxaCover_x_p_total_cover, tgt_ind_int);
selected_cf_TC = filterSummary(out_26.coralTaxaCover_x_p_total_cover, tgt_ind_cf);
selected_int_Ev = filterSummary(out_26.coralEvenness, tgt_ind_int);
selected_cf_Ev = filterSummary(out_26.coralEvenness, tgt_ind_cf);
selected_int_SV = filterSummary(out_26.shelterVolume, tgt_ind_int);
selected_cf_SV = filterSummary(out_26.shelterVolume, tgt_ind_cf);
selected_int_Ju = filterSummary(out_26.coralTaxaCover_x_p_juveniles, tgt_ind_int);
selected_cf_Ju = filterSummary(out_26.coralTaxaCover_x_p_juveniles, tgt_ind_cf);

%% plot every 5 yrs
fig = figure(1)
subplot(2,2,1)
hold on
plot(yr(1),selected_int_TC.mean(1,1),'.','MarkerFaceColor',[204/255,0,0],'MarkerSize',12)
plot(yr(1),selected_cf_TC.mean(1,1),'.','MarkerFaceColor',[51/255,153/255,1],'MarkerSize',12)
al_goodplot(selected_int_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [204/255,0,0], 'left')
al_goodplot(selected_cf_TC.mean(1:5:end,:)', yr(1:5:end), 0.5, [51/255,153/255,1], 'right')
xlim([2026,2100])
ylim([0,0.8])
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
ylim([0,0.4])
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
