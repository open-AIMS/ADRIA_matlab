N_sims =100;
algs = 1;
params = cell(7,1);
params{1} = [0,1];
params{2} = [1,2,3];
params{3} = [0,0.0005];
params{4} = [0,0.0005];
params{5} = [0,6];
params{6} = [0,6];
params{7} = [0,0.05];
t_s = 10;
RCPs = 60;


BBN_Compatible_Table_Func(params,t_s,RCPs,algs, N_sims)
