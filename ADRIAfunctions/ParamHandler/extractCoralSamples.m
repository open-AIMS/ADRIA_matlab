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

% NOTE: Order of column names have to line up with order of values
%       in updating the values in the loop below.
col_names = string(param_spec.Properties.VariableNames(6:end));

unique_coral_names = unique(replace(lower(param_spec.name), " ", "_"));
num_taxa = length(unique_coral_names);
num_params = length(col_names);
for c_idx = 1:num_taxa
    coral_name = unique_coral_names(c_idx);
    idx = contains(param_spec.coral_id, coral_name);
    
    % find and assign parameter values related to this coral taxa
    param_spec{idx, col_names} = ...
        reshape(samples{:, contains(varnames, coral_name)}, num_params, num_taxa)';
end

end