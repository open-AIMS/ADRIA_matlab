a = 1; % alg_ind
b = 3; % PrSites
c = 60; % RCP
d = 1; % out_ind

% initialise parameters
% x0 = [Guided,Seed1,Seed2,SRM,Aadpt,Natad]
x0 = [1 0 0 0 0 0 ];
ObjectiveFunction = @(x) -1*ObjectiveFunc(x,a,b,c,d);

% upper bounds on x
ub = [0.001,0.001,5,5,0.1];
lb = [0,0,0,0,0];

x = simulannealbnd(ObjectiveFunction,x0,lb,ub);