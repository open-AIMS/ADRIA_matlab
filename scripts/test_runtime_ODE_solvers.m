
rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values

param_table = ai.raw_defaults;

%% Run ADRIA

% Load site specific data
ai.loadConnectivity('./Inputs/Moore/connectivity/2015/moore_d2_2015_transfer_probability_matrix_wide.csv',cutoff=0.1);
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);
n_reps = 20;
ai.loadDHWData('./Inputs/Moore/DHWs/dhwRCP45.mat', n_reps);

%% with ode45
odestr = "ode45";
tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc = odestr);
Y45 = res.Y;  % get raw results
tmp = toc;

N = size(Y45, 4);
disp(strcat("With ",odestr,". Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))

%% with ode23
odestr = "ode23";
tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr);
Y23 = res.Y;  % get raw results
tmp = toc;

N = size(Y23, 4);
disp(strcat("With ",odestr,". Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))

%% with stiff solver ode15s
% odestr = "ode15s";
% tic
% % Run a single simulation with `n_reps` replicates
% res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr);
% Y = res.Y;  % get raw results
% tmp = toc;
% 
% N = size(Y, 4);
% disp(strcat("With ",odestr, ". Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))
%% with variable order method ode113
odestr = "ode113";
tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr);
Y113 = res.Y;  % get raw results
tmp = toc;

N = size(Y113, 4);
disp(strcat("With",odestr,". Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))
%% plot difference to ode45
diff23 = sqrt(sum(sum(sum(sum((Y45-Y23).^2,2),3),4),5))