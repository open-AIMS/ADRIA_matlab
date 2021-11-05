function param_table = paramTableBuilder(name, ptype, defaults, lower_bound, upper_bound)
% Build parameter detail table

% preallocate array
opts(1:length(ptype)) = {NaN};

% build combinations of categorical options
for i = 1:length(ptype)
    if ptype(i) ~= "categorical"
        continue
    end
    
    if length(lower_bound{i}) > 1
        % parameter holds an arrays as options
        % e.g. lower := [0, 0], upper := [1, 1]
        t = [lower_bound{i}; upper_bound{i}]';
        tmp = paramCombinations({t(1, :); t(2, :)});
        opts{i} = {containers.Map(1:length(tmp), tmp)};
    else
        opts{i} = {paramCombinations({lower_bound{i}:upper_bound{i}})};
    end
end

options = opts';

% build option bounds (1, N+1)
% e.g., for 3 categorical options this would be 1, 4
%       for real valued options, it would match given lower/upper bounds
option_bounds(1:length(ptype)) = {NaN};
for i = 1:length(options)
    try
        option_bounds{i} = [1, length(options{i}{1})+1];
    catch
        option_bounds{i} = [lower_bound{i}, upper_bound{i}];
    end
end

option_bounds = option_bounds';

param_table = table(name, ptype, defaults, lower_bound, upper_bound, ...
                    options, option_bounds);
end
