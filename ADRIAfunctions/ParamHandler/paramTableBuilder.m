function param_table = paramTableBuilder(name, ptype, defaults, raw_lower_bound, raw_upper_bound)
% Build parameter detail table

% preallocate array
opts(1:length(ptype)) = {NaN};

% build combinations of categorical options
for i = 1:length(ptype)
    if ptype(i) ~= "categorical"
        continue
    end
    
    if length(raw_lower_bound{i}) > 1
        % parameter holds an arrays as options
        % e.g. lower := [0, 0], upper := [1, 1]
        t = [raw_lower_bound{i}; raw_upper_bound{i}]';
        tmp = paramCombinations({t(1, :); t(2, :)});
        opts{i} = {containers.Map(1:length(tmp), tmp)};
    else
        opts{i} = {paramCombinations(...
                    {raw_lower_bound{i}:raw_upper_bound{i}})};
    end
end

options = opts';

% build option bounds (1, N+1)
% e.g., for 3 categorical options this would be 1, 4
%       for real valued options, it would match given lower/upper bounds
lower_opt_bound(1:length(ptype)) = {NaN};
upper_opt_bound(1:length(ptype)) = {NaN};
for i = 1:length(options)
    try
        lower_opt_bound{i} = 1;
        upper_opt_bound{i} = length(options{i}{1})+1;
    catch
        lower_opt_bound{i} = raw_lower_bound{i};
        upper_opt_bound{i} = raw_upper_bound{i};
    end
end

lower_bound = lower_opt_bound';
upper_bound = upper_opt_bound';

param_table = table(name, ptype, defaults, lower_bound, upper_bound, ...
                    options, raw_lower_bound, raw_upper_bound);
end
