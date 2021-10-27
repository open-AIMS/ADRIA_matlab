function av_C = ObjectiveFunc(x,a,b)
% x = [Guided,Seed1,Seed2,SRM,Aadpt,Natad,RCP]
Interv = struct('Guided', 1, ...
                       'PrSites',b , ...
                       'Seed1', x(1), ...
                       'Seed2', x(2), ...
                       'SRM', x(3), ...
                       'Aadpt', x(4), ...
                       'Natad',x(5), ...
                       'Seedyrs', 10, ...
                       'Shadeyrs', 1, ...
                       'sims', 30,...
                       'RCP', x(6));
CrtWts = CriteriaWeights();             
reef_condition_metrics = runADRIA(Interv, CrtWts, a);
av_C = mean(squeeze(reef_condition_metrics.C));
end
