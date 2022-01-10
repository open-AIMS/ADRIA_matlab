function param_spec = extractCoralSamples(samples, param_spec)
% Extract coral specific sample values from parameter table.
% WARNING: Assumes parameters are in the same order between `samples` and
% `param_spec`.
%
% Input:
%     samples    : table, of coral parameter values
%     param_spec : struct, of coral specifications
%
% Output:
%     param_spec : table, of sampled parameters
% p_delimiter = '__';  % parameter delimiter to search for

varnames = string(samples.Properties.VariableNames);
for coral_id = string(param_spec.coral_id)'
    vals = samples{:, contains(varnames, coral_id)};
    nlen = length(vals)-1 ;
    
    % Batch assign sample values to parameter spec table.
    % This is for performance, at the cost of flexibility
    param_spec{param_spec.coral_id == coral_id, end-nlen:end} = vals;
end

end