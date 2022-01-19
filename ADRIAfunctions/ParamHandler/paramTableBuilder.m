function param_table = paramTableBuilder(name, ptype, defaults, raw_bounds, varargin)
% Build parameter detail table

% preallocate array
options(1:length(ptype), 1) = {NaN};

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

        options{i, :} = paramCombinations({l_val:u_val});
    else
        % simply map integer id to categorical value
        % e.g. 1 => "Option A", 2 => "Option B"
        options{i, :} = containers.Map(1:length(this_bound), this_bound);
    end
end

% build option bounds (1, N+1)
% e.g., for 3 categorical options this would be 1, 4
%       for real valued options, it would match given lower/upper bounds
lower_bound(1:length(ptype), 1) = NaN;
upper_bound(1:length(ptype), 1) = NaN;
for i = 1:length(options)
    this_bound = raw_bounds(i, :);
    lower = this_bound(1);
    upper = this_bound(2);

    if ptype(i) == "float"
        lower_bound(i, :) = lower;
        upper_bound(i, :) = upper;
    else
        lower_bound(i, :) = floor(lower);
        upper_bound(i, :) = ceil(upper)+1;
    end
end

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

    if isfloat(cont)
        % not a map container, so use index value
        idx = find(cont == default_val);
        mapped_default_val = cont(idx);
    else
        % is map container
        poss_vals = values(cont);
        tmp_keys = keys(cont);
        tmp = tmp_keys([poss_vals{:}] == default_val);
        mapped_default_val = tmp{1};
    end

    param_table{param_table.name == cats.name(ci), "sample_defaults"} = mapped_default_val;
end

end
