function param_table = paramTableBuilder(name, ptype, defaults, raw_bounds)
% Build parameter detail table

% preallocate array
opts(1:length(ptype)) = {NaN};

% build combinations of categorical options
for i = 1:length(ptype)
    tmp_ptype = ptype(i);
    if tmp_ptype ~= "categorical" && tmp_ptype ~= "integer"
        continue
    end
    
    this_bound = raw_bounds{i};
    if tmp_ptype == "integer"
        lower = this_bound(1);
        upper = this_bound(2);
        
        if length(this_bound(1)) > 1
            % parameter holds an arrays as options
            % e.g. lower := [0, 0], upper := [1, 1]
            t = [lower; upper]';
            tmp = paramCombinations({t(1, :); t(2, :)});
            opts{i} = {containers.Map(1:length(tmp), tmp)};
        else
            opts{i} = {paramCombinations({lower:upper})};
        end
    else
        % simply map integer id to categorical value
        % e.g. 1 => "Option A", 2 => "Option B"
        opts{i} = {containers.Map(1:length(this_bound), this_bound)};
    end
end

options = opts';

% build option bounds (1, N+1)
% e.g., for 3 categorical options this would be 1, 4
%       for real valued options, it would match given lower/upper bounds
lower_opt_bound(1:length(ptype)) = {NaN};
upper_opt_bound(1:length(ptype)) = {NaN};
for i = 1:length(options)
    this_bound = raw_bounds{i};
    lower = this_bound(1);
    upper = this_bound(2);

    try
        lower_opt_bound{i} = 1;
        upper_opt_bound{i} = length(options{i}{1});
    catch
        lower_opt_bound{i} = lower;
        upper_opt_bound{i} = upper;
    end
end

lower_bound = lower_opt_bound';
upper_bound = upper_opt_bound';

param_table = table(name, ptype, defaults, lower_bound, upper_bound, ...
                    options, raw_bounds);
end
