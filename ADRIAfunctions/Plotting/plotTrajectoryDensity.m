function fig = plotTrajectoryDensity(metric, opts)
% Plots temporal boxplot (representing simulation trajectories) over time 
% using summary statistics.
%
% Summary stats can be obtained by applying `summarizeMetrics()` after
% collating the metric results.
%
% Inputs:
%   metric   : struct, of summary statistics for given metric
%   extremes : logical, whether to show min/max extremes or not.
%   title  : string, plot title (optional)
%   ylabel  : string, y-axis label (optional)
%
% Outputs:
%   fig : figure object
%
% Example:
%   >> ai.runToDisk(sample_table, sampled_values=true, nreps=n_reps, ...
%                   file_prefix=file_prefix, batch_size=4, 
%                   collect_logs=["site_rankings"]);
%
%   >> % Collect the desired metrics from the result files
%   >> desired_metrics = {@shelterVolume}
%   >> Y = ai.gatherResults(file_prefix, desired_metrics);
%
%   >> % Calculate coral shelter volume per ha
%   >> SV_per_ha = concatMetrics(Y, "shelterVolume");
%
%   >> RCI = ReefConditionIndex(TC, evenness, SV_per_ha, juv);
%
%   >> % Collate summary stats
%   >> x = struct('SV_per_ha', SV_per_ha);
%   >> met_summaries = summarizeMetrics(x);
%   >> plotTrajectory(met_summaries.SV_per_ha, ptitle="Example");
arguments
    metric struct
    opts.nreps = 50
    opts.extremes logical = false
    opts.title string = ""  % plot title
    opts.ylabel string = ""
end

fig = figure;
hold on

x = 1:size(metric.mean, 1);
x2 = [x fliplr(x)];

lower_whisker = squeeze(min(metric.min, [], 2));
upper_whisker = squeeze(max(metric.max, [], 2));

if opts.extremes
    % extremes (whiskers)
    whisker_fill = [lower_whisker', fliplr(upper_whisker')];
    fill(x2, whisker_fill, 'cyan', FaceAlpha=0.1, EdgeAlpha=0.1);
end

% Average trajectory
sim_mean = squeeze(mean(metric.mean, 2));

% Standard deviation
sim_stdev = squeeze(mean(metric.std, 2));

% x = 1:size(metric.mean, 1);

% Means
plot(mean(sim_mean, 2), 'blue', 'LineWidth', 2);
plot(sim_mean, 'LineWidth', 1, color=[0, 0, 1, 0.3]);

% Outer ~95.45% CI (outer box)
bot_lim = max(sim_mean - sim_stdev*2, 0.0);
plot(bot_lim, color=[0, 0, 1, 0.3])
plot(mean(bot_lim, 2), color=[0, 0, 1, 0.3], LineWidth=2);

top_lim = min(sim_mean + sim_stdev*2, 1.0);
plot(top_lim, color=[0, 0, 1, 0.3]);
plot(mean(top_lim, 2), color=[0, 0, 1, 0.3], LineWidth=2);

% Just bootstrap between 0 and 2 standard deviations
nreps = opts.nreps;
r_stdev = 2*rand(nreps,1);

% Randomly select which stdev to use
r_std = randsample(8, nreps, true);

% Plot trajectories
for i = 1:nreps
    std_m = r_stdev(i);  %std multiplier
    stdev = (std_m*sim_stdev(r_std(i)));
    plot(max(sim_mean - stdev, lower_whisker), color=[0.75, 0, 0.75, 0.1]);
    plot(min(sim_mean + stdev, upper_whisker), color=[0.75, 0, 0.75, 0.1]);
end
    
% ~68.27% CI (inner box)
bot_lim = max(sim_mean - sim_stdev, lower_whisker);
% plot(bot_lim, color=[0, 0, 1, 0.3])
plot(mean(bot_lim, 2), color=[0, 0, 1, 0.3], LineWidth=2);

top_lim = min(sim_mean + sim_stdev, upper_whisker);
% plot(top_lim, color=[0, 0, 1, 0.3]);
plot(mean(top_lim, 2), color=[0, 0, 1, 0.3], LineWidth=2);

% inner_fill = [max(sim_mean - sim_stdev, lower_whisker)', fliplr(min(sim_mean + sim_stdev, upper_whisker)')];
% fill(x2, inner_fill, 'blue', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.3);

plot(sim_mean, 'blue', 'LineWidth', 2);

xlabel("Timestep");

if opts.title ~= ""
    title(opts.title);
end

if opts.ylabel ~= ""
    ylabel(opts.ylabel);
end

hold off;

end