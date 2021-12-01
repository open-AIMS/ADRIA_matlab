%% Example for simple usage of the optimisation function ADRIAOptimisation
%% 1 : only optimise for average total coral cover av_TC

% use simplest MDCA algorithm for now
alg = 1;

rcp = 60;

% optimisation specification - want to optimise TC and CES
names_vec = cell(2,1);
names_vec{1} = 'TC';
names_vec{2} = 'CES';

% load Moore reef data
[TP_data, site_ranks, strongpred] = ADRIA_TP('Inputs/MooreTPmean.xlsx', 0.1);
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(rcp), ".nc");

% perform optimisation (takes a while, be warned, improvements to
% efficiency to be made)
[x,fval] = multiObjOptimization(alg, names_vec, fn, TP_data, site_ranks, strongpred,rcp);

% print results (also automatically saved to a struct in a .mat file) 
sprintf('Optimal intervention values were found to be Seed1: %1.4f, Seed2: %1.4f, SRM: %2.0f, AsAdt: %2.0f, NatAdt: %1.2f, with av_TC = %1.4f',...
    x(1),x(2),x(3),x(4),x(5),fval);

