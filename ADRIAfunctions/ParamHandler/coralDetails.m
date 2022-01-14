function coral_params = coralDetails(varargin)
% Detail coral parameter values and expected ranges.
% Default values for each parameter can be specified
% to override default values.
%
% Inputs:
%    Argument list of parameters to override.
%
% Outputs:
%   table of name, ptype, defaults, lower_bound, upper_bound, options,
%   raw_lower_bound, raw_upper_bound, where
%       - `name` holds the parameter names
%       - `ptype` denotes the parameter type (categorical, integer, float)
%           - categoricals: values have to be exact match
%           - integers: whole number values ranging between lower/upper
%           - float: values can range between lower/upper
%       - `sample_defaults` indicates the default values modified for use
%           with samplers
%       - lower/upper bounds indicate the range of mapped ids
%       - `options` maps option ids to their values
%       - `raw_defaults` indicates the raw unmodified "best guess" value
%       - `raw_bounds` indicates the original value ranges

coral_spec = coralSpec();  % load default parameter table

coral_ids = coral_spec.coral_id;

% get last N columns, which relate to perturbable parameters
base_p_names = string(coral_spec.Properties.VariableNames(6:end))';

n_corals = length(coral_ids);
n_param_names = length(base_p_names);

% Coral ecosystems are highly uncertain.
% Here, we set arbitrary bounds +/- 40% of best guess values
i = 1;
name = string.empty;
defaults = zeros(n_corals * n_param_names, 1);
p_bounds = zeros(n_corals * n_param_names, 2);
for c_id = 1:n_corals
    row_name = coral_ids(c_id);
    for p_id = 1:n_param_names
        bp_name = base_p_names(p_id);
        name(i, :) = strcat(coral_ids(c_id), '__', bp_name);
        tmp = coral_spec(coral_spec.coral_id == row_name, bp_name);
        defaults(i, :) = tmp{1, :};
        p_bounds(i, :) = [defaults(i, :) * 0.6, defaults(i, :) * 1.4];
        i = i + 1;
    end
end

ptype = repmat("float", length(defaults), 1);

coral_params = paramTableBuilder(name, ptype, defaults, p_bounds, ...
                                 varargin);
end