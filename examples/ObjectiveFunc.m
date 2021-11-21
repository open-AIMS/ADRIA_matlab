function av_TC = ObjectiveFunc(x,a,b,c,d,CrtWts, params, ecol_parms)
% objective function gives total coral cover TC as single output averaged
% over sites and time.
% Input : x - x = [Seed1,Seed2,SRM,Aadpt,Natad,RCP]
%         a - alg_ind
%         b - PrSites
%         c - RCP
%         d - d = 1 indicates single reef metric output for ADRIA
% Output : av_TC - averaged total coral cover, scalar

% optimization functions use 1*N arrays so have to transpose x

% set up intervention structure
interv = struct('Guided', 1, ...
                       'PrSites',b , ...
                       'Seed1', x(1), ...
                       'Seed2', x(2), ...
                       'SRM', x(3), ...
                       'Aadpt', x(4), ...
                       'Natad',x(5), ...
                       'Seedyrs', 10, ...
                       'Shadeyrs', 1, ...
                       'sims', 20,...
                       'RCP', c);

% run ADRIA to get TC output
reef_condition_metrics = runADRIA(interv, CrtWts, params, ecol_parms, a,d);
% average over sites, time
av_TC = mean(reef_condition_metrics.(d),'all');
end
