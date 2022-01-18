% Tests to make sure values converted after sampling resolve to the
% expected parameter bounds.
%
% Conversion from real-valued samples to ADRIA usable values
% is necessary as almost all samplers/optimizers expect real-valued 
% parameters (e.g., floats) where as in practice ADRIA makes use of integer
% and categorical parameters
%
% Parameter types
%  - categoricals: values have to be exact match
%  - integers: whole number values ranging between lower/upper
%  - float: values can range between lower/upper

% Number of scenarios
N = 50;

% Collect details of available parameters
inter_opts = interventionDetails();
criteria_opts = criteriaDetails();
coral_opts = coralDetails();

% Create main table listing all available parameter options
combined_opts = [inter_opts; criteria_opts; coral_opts];

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
p_sel = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound(p);
    b = combined_opts.upper_bound(p);
    
    selection = (b - a).*rand(N, 1) + a;
    
    p_sel.(combined_opts.name(p)) = selection;
end

% Convert sampled values to ADRIA usable values
converted_tbl = convertScenarioSelection(p_sel, combined_opts);

%% Check floats/integers
% Check that all values are above/below indicated bound
% and nothing is above/below limits
assert_lb = @(p_name, bnd) ...
             assert(any(converted_tbl.(p_name) >= bnd) & ...
                    all(~(converted_tbl.(p_name) < bnd)), ...
                    'Sample below expected bound!');

assert_ub = @(p_name, bnd) ...
             assert(any(converted_tbl.(p_name) <= bnd) & ...
                    all(~(converted_tbl.(p_name) > bnd)), ...
                    'Sample above expected bound!');

tmp = combined_opts.raw_bounds;
lb_vals = tmp(:, 1);
ub_vals = tmp(:, 2);

arrayfun(assert_lb, combined_opts.name, lb_vals);
arrayfun(assert_ub, combined_opts.name, ub_vals);

%% Check integer options
% Collect all integer parameters
int_idxs = combined_opts.ptype == 'integer';
int_opts = combined_opts(int_idxs, :);

int_samples = converted_tbl(:, int_idxs);
int_names = int_samples.Properties.VariableNames;

% Check that all sampled integer values are valid
for i = 1:length(int_names)
    n = int_names(i);
    vals = converted_tbl.(n{1});
    tmp = int_opts.options{i, 1};
    assert(all(ismember(vals, tmp)), ...
        'Invalid integer value sampled!');
end

%% Check categoricals
% Collect all categorical parameters
cat_idxs = combined_opts.ptype == 'categorical';
cats = combined_opts(cat_idxs, :);

cat_samples = converted_tbl(:, cat_idxs);
cat_names = cat_samples.Properties.VariableNames;

% Check that all sampled categoricals are valid
for i = 1:length(cat_names)
    n = cat_names(i);
    vals = converted_tbl.(n{1});
    tmp = cats.options{i, 1};
    assert(all(ismember(vals, cell2mat(values(tmp)))), ...
        'Invalid categorical value sampled!');
end

%% Check default value override
i_tbl = interventionDetails();
mod_i_tbl = interventionDetails(Guided=0, Seedyrs=13);

sample_val = mod_i_tbl{mod_i_tbl.name == "Seedyrs", "sample_defaults"};
raw_val = mod_i_tbl{mod_i_tbl.name == "Seedyrs", "raw_defaults"};

received = num2str(sample_val);
assert(sample_val == 13, ...
        strcat("Unexpected value: Sample Seedyrs, 13 == ", received));

received = num2str(raw_val);
assert(raw_val == 13, ...
        strcat("Unexpected value: Raw Seedyrs, 13 == ", received));

sample_val = mod_i_tbl{mod_i_tbl.name == "Guided", "sample_defaults"};
raw_val = mod_i_tbl{mod_i_tbl.name == "Guided", "raw_defaults"};

received = num2str(sample_val);
assert(sample_val == 0, ...
        strcat("Unexpected value: Sample Guided, 0 == ", received));

received = num2str(raw_val);
assert(raw_val == 0, ...
        strcat("Unexpected value: Raw Guided, 0 == ", received));

%% Check MCDA approach choice is properly respected
% ai = ADRIA();
% 
% X = ai.sample_defaults;
% X.Guided = 4;
% 
% ai.run(X, sampled_values=true, nreps=3);

