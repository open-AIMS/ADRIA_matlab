function param_spec = extractCoralSamples(samples, param_spec)
% Modify provided coral parameter table with sampled values.
%
% Input:
%     samples    : table,
%     param_spec : struct,
%
% Output:
%     param_spec : table, of sampled parameters
coral_ids = param_spec.coral_id;
n_coral_ids = length(coral_ids);
p_delimiter = '__';  % parameter delimiter to search for

sample_names = samples.Properties.VariableNames';

% function handle to extract variable name from column name
v_func = @(v) getfield(strsplit(v, p_delimiter), {2});

for c_id = 1:n_coral_ids
    c_name = coral_ids(c_id);
    col_idx = contains(sample_names, strcat(c_name, p_delimiter));
    tbl_ss = samples(:, col_idx);
    v_names = tbl_ss.Properties.VariableNames';
    tmp = cellfun(v_func, v_names, 'UniformOutput', false);
    n_vars = length(tmp);
    for vn = 1:n_vars
        param_spec{c_id, tmp{vn}{1}} = tbl_ss{1, vn};
    end
end

end