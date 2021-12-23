function param_table = paramTableBuilder(name, ptype, defaults, raw_bounds, varargin)
% Build parameter detail table

% preallocate array
opts(1:length(ptype), 1) = {NaN};

% build combinations of categorical options
for i = 1:length(ptype)
    tmp_ptype = ptype(i);
    if tmp_ptype ~= "categorical" && tmp_ptype ~= "integer"
        continue
    end

    this_bound = raw_bounds(i, :);
    if tmp_ptype == "integer"
        l_val = this_bound(1);
        u_val = this_bound(2);

        if length(this_bound(1)) > 1
            % parameter holds an arrays as options
            % e.g. lower := [0, 0], upper := [1, 1]
            t = [l_val; u_val]';
            tmp = paramCombinations({t(1, :); t(2, :)});
            opts{i, :} = {containers.Map(1:length(tmp), tmp)};
        else
            opts{i, :} = {paramCombinations({l_val:u_val})};
        end
    else
        % simply map integer id to categorical value
        % e.g. 1 => "Option A", 2 => "Option B"
        opts{i, :} = containers.Map(1:length(this_bound), this_bound);
    end
end

% build option bounds (1, N+1)
% e.g., for 3 categorical options this would be 1, 4
%       for real valued options, it would match given lower/upper bounds
lower_bound(1:length(ptype), 1) = [NaN];
upper_bound(1:length(ptype), 1) = [NaN];
for i = 1:length(opts)
    this_bound = raw_bounds(i, :);
    lower = this_bound(1);
    upper = this_bound(2);

    if ptype(i) == "float"
        lower_bound(i, :) = lower;
        upper_bound(i, :) = upper;
    else
        lower_bound(i, :) = 1;
        tmp = opts{i, :};
        if iscell(tmp)
            tmp = tmp{1};
            upper_bound(i, :) = length(tmp)+1;
        else
            upper_bound(i, :) = length(tmp)+1;
        end
    end
end

options = opts;
raw_defaults = defaults;
sample_defaults = defaults;
param_table = table(name, ptype, sample_defaults, lower_bound, upper_bound, ...
                    options, raw_defaults, raw_bounds);

% Update "raw_default" column with user-provided values (if given)
varargin = varargin{:};
if nargin > 0
    valid_names = name(:);
    for name_val = [varargin(1:2:end); varargin(2:2:end)]
        [name, val] = name_val{:};
        if isempty(find(contains(valid_names, name), 1))
            error("Parameter '%s' is invalid", name)
        end

        assert(~isempty(val), strcat("Provided value for ", name, " is empty!"));

        param_table{param_table.name == name, "raw_defaults"} = val;
    end
end

% Update "sample_defaults" to match specified values in the "raw" column
cats = param_table((param_table.ptype == "integer") | (param_table.ptype == "categorical"), :);
cat_opts = cats.options;
num_entries = length(cat_opts);
for ci = 1:num_entries
    cont = cat_opts{ci};
    default_val = cats.raw_defaults(ci);

    if iscell(cont)
        % not a map container, so use index value
        poss_vals = cell2mat(cont{:});
        idx = find(poss_vals == default_val);
        mapped_default_val = idx;
    else
        poss_vals = values(cont);
        tmp_keys = keys(cont);
        tmp = tmp_keys([poss_vals{:}] == default_val);
        mapped_default_val = tmp{1};
    end

    if iscell(mapped_default_val)
        assign_val = mapped_default_val;
    else
        assign_val = num2cell(mapped_default_val);
    end

    param_table(param_table.name == cats.name(ci), "sample_defaults") = assign_val;
end

end
