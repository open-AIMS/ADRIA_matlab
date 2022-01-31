function est = estimateRuntime(n_sims, n_steps, n_sites)
% Estimate total runtime based on a separate indicative trial.
%
% NOTE: 
%     Assumes all detected cores are used.
%     These are indicative estimates only with no guarantee of accuracy
%     or reliability.
%
% Inputs:
%     n_sims  : int, number of simulations to be run
%     n_steps : int, number of time steps to be run
%     n_sites : int, number of sites considered
%
% Outputs:
%     est : float, estimated runtime (in seconds)

    % Estimate from original run set
    trial_runtime = 0.08;

    % run time per site/step
    rt_per_site_step = trial_runtime / 26 / 25;

    trial_CPU_freq = 3800;     % boost frequency
    
    this_comp = cpuinfo();
    tmp = split(this_comp.Clock, " ");
    tmp = tmp(1);
    this_CPU_freq = str2double(tmp{1});
    avail_cores = this_comp.TotalCores;
    
    expected_rt = rt_per_site_step * n_sites * n_steps;
    
    est_run = (trial_CPU_freq / this_CPU_freq) * expected_rt;
    est = max(est_run, ((n_sims * est_run) / avail_cores));
    est = round(est, 2);
end