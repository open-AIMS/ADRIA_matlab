function est = estimateRuntime(n_sims)
% Estimate total runtime based on a separate early indicative trial.
%
% NOTE: 
%     Assumes all detected cores are used.
%     These are indicative estimates only with no guarantee of accuracy
%     or reliability.

    % Estimate from original run set
    trial_runtime = 6.9311;  % trial run time
    trial_CPU_freq = 3800;     % boost frequency
    
    this_comp = cpuinfo();
    tmp = split(this_comp.Clock, " ");
    tmp = tmp(1);
    this_CPU_freq = str2double(tmp{1});
    avail_cores = this_comp.TotalCores;
    
    est_run = (trial_CPU_freq / this_CPU_freq) * trial_runtime;
    est = max(est_run, ((n_sims * est_run) / avail_cores));
    est = round(est, 2);
end