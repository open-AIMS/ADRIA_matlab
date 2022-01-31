% MARKED FOR DEPRECATION

function out = ObjectiveFunc(x,CrtWts,params,ecol_parms,algInd,prSites,RCP,optInd)
    % Objective function gives total coral cover TC as single output averaged
    % over sites and time.
    % Input : x - x = [Seed1,Seed2,SRM,Aadpt,Natad,RCP]
    %         algInd - indicate MCDA alg
    %         prSites - indicate site group
    %         RCP - RCP scenario
    %         opti_ind - indicate number of outputs to optimise over
    %
    % Output : out - scalar or vector with either 1: averaged total coral cover, 
    %                2: averaged total coral cover, evenness and structural
    %                compexity or 3: averaged total coral cover, evenness,structural
    %                compexity, cultural ES and provisional ES

    % set up intervention structure using default shading and seeding years and
    % sims 
    Interv = struct('Guided', 1, ...
                           'PrSites',prSites , ...
                           'Seed1', x(1), ...
                           'Seed2', x(2), ...
                           'SRM', x(3), ...
                           'Aadpt', x(4), ...
                           'Natad', x(5), ...
                           'Seedyrs', 10, ...
                           'Shadeyrs', 1, ...
                           'sims', 20,...
                           'RCP', RCP); 

    % run ADRIA to get TC output
    reef_condition_metrics = runADRIA(Interv,CrtWts,params,ecol_parms,algInd);

    % average over sites, time
    % no. of outputs depends on opti_ind variable
    if (sum(optInd(1:3)) > 0)&&(sum(optInd(4:end)) == 0)
        % no ES as output
        % av TC, E and S as output options
        av_TC = mean(reef_condition_metrics.TC,'all');
        av_E = mean(reef_condition_metrics.E,'all');
        av_S = mean(reef_condition_metrics.S,'all');
        out = [av_TC av_E av_S].*optInd(1:3);
    else
        % combination of ecological and ES outputs
        % av TC,E,S, CES and PES as output options
        av_TC = mean(reef_condition_metrics.TC,'all');
        av_E = mean(reef_condition_metrics.E,'all');
        av_S = mean(reef_condition_metrics.S,'all');
        ecosys_results = Corals_to_Ecosys_Services(reef_condition_metrics,0);
        av_CES = mean(ecosys_results.CultES,'all');
        av_PES = mean(ecosys_results.ProvES,'all');
        out = [av_TC av_E av_S av_CES av_PES].*optInd;
    end

end
