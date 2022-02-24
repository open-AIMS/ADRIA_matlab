function fig = plotTrajectory(metric, opts)
% Plots temporal boxplot (representing simulation trajectories) over time 
% using summary statistics.
%
% Summary stats can be obtained by applying `summarizeMetrics()` after
% collating the metric results.
%
% Inputs:
%   metric   : struct, of summary statistics for given metric
%   extremes : logical, whether to show min/max extremes or not.
%   p_title  : string, plot title (optional)
%   y_label  : string, y-axis label (optional)
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
%   >> RCI = ReefConditionIndex(evenness, SV_per_ha, TC, juv);
%
%   >> % Collate summary stats
%   >> x = struct('SV_per_ha', SV_per_ha);
%   >> met_summaries = summarizeMetrics(x);
%   >> plotTrajectory(met_summaries.SV_per_ha, ptitle="Example");
arguments
    metric struct
    opts.extremes logical = false
    opts.title string = ""  % plot title
    opts.ylabel string = ""
end

fig = figure;
hold on

x = 1:size(metric.mean, 1);
x2 = [x fliplr(x)];

lower_whisker = min(metric.min, [], [3,2]);
upper_whisker = max(metric.max, [], [3,2]);

if opts.extremes
    % extremes (whiskers)
    whisker_fill = [lower_whisker', fliplr(upper_whisker')];
    fill(x2, whisker_fill, 'cyan', FaceAlpha=0.1, EdgeAlpha=0.1);
end

% Average trajectory
sim_mean = mean(metric.mean, [3,2]);

% Standard deviation
sim_stdev = mean(metric.std, [3,2]);

% ~95.45% CI (outer box)
x = 1:size(metric.mean, 1);
outer_fill = [max(sim_mean - sim_stdev*2, lower_whisker)' fliplr(min(sim_mean + sim_stdev*2, upper_whisker)')];
fill([x fliplr(x)], outer_fill, 'cyan', 'FaceAlpha', 0.4, 'EdgeAlpha', 0.0)
plot(max(sim_mean - sim_stdev*2, 0.0)', color=[0, 0, 1, 0.3])
plot(min(sim_mean + sim_stdev*2, 1.0)', color=[0, 0, 1, 0.3])

% ~68.27% CI (inner box)
inner_fill = [max(sim_mean - sim_stdev, lower_whisker)', fliplr(min(sim_mean + sim_stdev, upper_whisker)')];
fill(x2, inner_fill, 'blue', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.3);

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