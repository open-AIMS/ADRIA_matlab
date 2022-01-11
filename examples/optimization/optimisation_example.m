%% Example for simple usage of the optimisation function ADRIAOptimisation
%% 1 : only optimise for average total coral cover av_TC

% use simplest MDCA algorithm for now
alg = 1;
rcp = 60;
Nreps = 50;

filename = 'MooreTPMean.xlsx';
% optimisation specification - want to optimise TC and CES
names_vec = cell(1,1);
names_vec{1} = 'TC';
%names_vec{2} = 'E';

% perform optimisation 
[x,fval] = multiObjOptimization(alg, rcp, Nreps, filename, names_vec);

% print results 
sprintf('Optimal intervention values were found to be Seed1: %1.4f, Seed2: %1.4f, SRM: %2.0f, AsAdt: %2.0f, NatAdt: %1.2f, with av_TC = %1.4f',...
    x(1),x(2),x(3),x(4),x(5),fval);

