function summarized = summarizeMetrics(metrics)
% Produce summary statistics for the given metric results from
% `concatMetrics()`
%
% Inputs:
%    metrics : struct, of metric values
%
% Outputs:
%   summarized : struct, nested by given metric names, with their means, medians, 
%                  minimums, maximums, and standard deviations, e.g.,
%                  metrics = struct('TC', TC);
%
% Example:
%               >> evenness = concatMetrics(Y, "coralEvenness");
%               >> metrics = struct('evenness', evenness);
%               >> x = summarizeMetrics(metrics);
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
    
    % full result set
    nd = ndims(metric);
    summarized.(fn).mean = mean(metric, nd);
    summarized.(fn).median = median(metric, nd);
    summarized.(fn).min = min(metric, [], nd);
    summarized.(fn).max = max(metric, [], nd);
    summarized.(fn).std = std(metric, 0, nd);
end
end