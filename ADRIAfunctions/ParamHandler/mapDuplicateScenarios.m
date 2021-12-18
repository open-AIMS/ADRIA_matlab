function [X_ss, u_r, g_idx] = mapDuplicateScenarios(X)
% Identify duplicate rows to avoid identical scenarios being run.
% Duplicate scenarios may be produced as a consequence of the sampling
% approach.
%
% Inputs:
%   X : table, of scenarios
%
% Outputs:
%   X_ss : table, unique subset of scenarios
%
% Example:
%   See usage in `examples/running_ADRIA/run_example.m`

[~, u_r, g_idx] = unique(X, 'rows', 'first');
X_ss = X(u_r, :);

end
