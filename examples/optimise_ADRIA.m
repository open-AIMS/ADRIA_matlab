% MARKED FOR DEPRECATION

a = 1; % alg_ind
b = 3; % PrSites
% initialise parameters
% x0 = [Guided,Seed1,Seed2,SRM,Aadpt,Natad,RCP]
x0 = [1 0 0 0 0 0 60];
ObjectiveFunction = @(x) -1*parameterized_objective(x,a,b);
% upper bounds on x
ub = [0.001,0.001,12,12,0.1,85];
lb = [0,0,0,0,0,26];

x = simulannealbnd(ObjectiveFunction,x0,lb,ub);