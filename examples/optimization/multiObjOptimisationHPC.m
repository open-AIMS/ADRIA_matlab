% Script for running multi-objective optimisation on the hpc
% set up to optimise over all interventions for the 3 ecological metrics
% 'TC'- total coral cover, 'E' - evenness and 'S' - structural complexity
% ES variables can be added later

% use order ranking (could add as shell variable later to compare MCDA
% algs)
alg = 1;  

% get shell variables
rcp = str2num(getenv('RCP')); % RCP

% optimisation specification - want to optimise for TC,E and S
names_vec = cell(3,1);
names_vec{1} = 'TC';
names_vec{2} = 'E';
names_vec{3} = 'S';

% load Moore reef data
[TP_data, site_ranks, strongpred] = siteConnectivity('Inputs/MooreTPmean.xlsx', 0.1);
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(rcp), ".nc");

% perform optimisation 
[x,fval] = multiObjOptimization(alg, names_vec, fn, TP_data, site_ranks, strongpred, prsites,rcp);

% label file with key parameters (file type maybe should be changed)
filename = sprintf('ADRIA_opt_out_RCP%2.0f_PrSites%1.0d_Alg%1.0d.csv',rcp,prsites,alg);

% Save as CSV
saveData(x, filename)

