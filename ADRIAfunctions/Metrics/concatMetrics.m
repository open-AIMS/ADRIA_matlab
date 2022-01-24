function concated = concatMetrics(Y_all, attr)
% Join collected metric results (by `collectMetrics()`) together.
    nested = split(attr, ".");
    
    if isstruct(Y_all)
        % Extract indicated field if not a collection of gathered results
        concated = getfield(Y_all, nested{:});
        return
    end
    
    a = getfield(Y_all{1}, nested{:});
    b = getfield(Y_all{2}, nested{:});
    a = cat(length(size(a))+1, a, b);
    
    run_dim = length(size(a));
    
    for i = 3:length(Y_all)
        a = cat(run_dim, a, getfield(Y_all{i}, nested{:}));
    end
    
    % Reorder into expected dimensions
    concated = permute(a, [1:(run_dim-2), run_dim, run_dim-1]);
end
