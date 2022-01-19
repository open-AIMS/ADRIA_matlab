%% Example for simple usage of the optimisation function ADRIAOptimisation
%% 1 : only optimise for average total coral cover av_TC

% use simplest MDCA algorithm for now
alg = 1;
rcp = 60;
Nreps = 50;

filename = 'MooreTPMean.xlsx';
% optimisation specification - want to optimise TC and CES

func_vec = {@coralTaxaCover, @coralSpeciesCover, @coralEvenness,@shelterVolume};
tic
% perform optimisation 
[x,fval] = multiObjOptimization(alg, rcp, Nreps, filename, func_vec);
toc
% print results 

