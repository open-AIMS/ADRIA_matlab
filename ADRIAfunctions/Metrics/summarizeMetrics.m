function summarized = summarizeMetrics(metrics)
% Produce summary statistics for the given metric results from
% `concatMetrics()`
%
% Inputs:
%    metrics : struct, of metric values
%
% Outputs:
%   x : struct, nested by given metric names, with their means, medians, 
%               minimums, maximums, and standard deviations, e.g.,
%               metrics = struct('TC', TC);
%
% Example:
%               >> evenness = concatMetrics(Y, "coralEvenness");
%               >> metrics = struct('evenness', evenness);
%               >> summarizeMetrics(metrics);
%
%               >> x.evenness.mean
%               >> x.evenness.median
%               >> x.evenness.std     
arguments
    metrics struct
end

summarized = struct();
fields = fieldnames(metrics);
for met_id = 1:length(fields)
    fn = fields{met_id};
    metric = metrics.(fn);
    
    summarized.(fn).mean = mean(metric, 4);
    summarized.(fn).median = median(metric, 4);
    summarized.(fn).min = min(metric, [], 4);
    summarized.(fn).max = max(metric, [], 4);
    summarized.(fn).std = std(metric, 0, 4);
end
end