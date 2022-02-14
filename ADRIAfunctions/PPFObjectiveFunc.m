function [val, ES1, ES2]= PPFObjectiveFunc(x,gam,ai,param_table,coral_parms,n_reps,funcs)

    Y = ai.run_ES(x,param_table,sampled_values=false,nreps=n_reps)
    metrics = collectMetrics(Y,coral_parms,@coralTaxaCover,@shelterVolume);
    ES1 = metrics.coralTaxaCover.total_cover;
    ES1 = mean(ES1./max(ES1,'all'),'all');
    ES2 = metrics.shelterVolume;
    ES2 = mean(ES2./max(ES2,'all'),'all');
    val = ES1*gam + (1-gam)*ES2;

end