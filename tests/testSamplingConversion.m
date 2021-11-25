% Tests to make sure values converted after sampling resolve to the
% expected parameter bounds.

% Conversion from real-valued samples to ADRIA usable values
% is necessary as almost all samplers/optimizers expect real-valued 
% parameters (e.g., floats) where as in practice ADRIA makes use of integer
% and categorical parameters

% Number of scenarios
N = 50;

% Collect details of available parameters
inter_opts = interventionDetails();
criteria_opts = criteriaDetails();

% Create main table listing all available parameter options
combined_opts = [inter_opts; criteria_opts];

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
p_sel = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound{p};
    b = combined_opts.upper_bound{p};
    
    selection = (b - a).*rand(N, 1) + a;
    
    p_sel.(combined_opts.name{p}) = selection;
end

% Convert sampled values to ADRIA usable values
converted_tbl = convertScenarioSelection(p_sel, combined_opts);

%% Check floats/integers
% Check that all values are above/below indicated bound
% and nothing is above/below limits
assert_lb = @(p_name, bnd) ...
             assert(any(converted_tbl.(p_name) >= bnd) & ...
                    all(~(converted_tbl.(p_name) < bnd)));

assert_ub = @(p_name, bnd) ...
             assert(any(converted_tbl.(p_name) <= bnd) & ...
                    all(~(converted_tbl.(p_name) > bnd)));

tmp = cell2mat(combined_opts.raw_bounds);
lb_vals = tmp(:, 1);
ub_vals = tmp(:, 2);

arrayfun(assert_lb, combined_opts.name, lb_vals);
arrayfun(assert_ub, combined_opts.name, ub_vals);

%% Check categoricals
% Collect all categorical parameters
cats = combined_opts(combined_opts.ptype == 'categorical', :);
valid_opts = cell2mat(values(cats.options{1}{1}));

cat_samples = converted_tbl(:, combined_opts.ptype == 'categorical');
cat_names = cat_samples.Properties.VariableNames;

% Check that all sampled categoricals are valid
for i = 1:length(cat_names)
    n = cat_names(1);
    vals = converted_tbl.(n{1});
    tmp = cats.options{:, 1};
    assert(all(ismember(vals, cell2mat(values(tmp{1})))));
end
