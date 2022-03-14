function concated = concatMetrics(Y_all, attr, agg_func)
% Join collected metric results (by `collectMetrics()`) together.
arguments
    Y_all
    attr
    agg_func = @(x, dim) x
end
    nested = split(attr, ".");
    entry = nested{:};
    
    if isstruct(Y_all)
        % Extract indicated field if not a collection of gathered results
        concated = squeeze(Y_all.(entry));
        return
    end
    
    concated = getfield(Y_all{1}, entry);
    a_nd = ndims(concated);
    
    concated = agg_func(concated, a_nd);
    b = agg_func(getfield(Y_all{2}, entry), a_nd);

    concated = squeeze(cat(a_nd+1, concated, b));
    nd = ndims(concated);
    
    clear b;

    for i = 3:length(Y_all)
        concated = cat(nd, concated, agg_func(getfield(Y_all{i}, entry), a_nd));
    end

    % Reorder into expected dimensions if needed
    if nd > 3
        x = size(concated);
        if length(Y_all) ~= x(end-1)
            concated = squeeze(permute(concated, [1:(nd-2), nd, nd-1]));
        end
    end

%     if isa(concated, "ndSparse")
%         concated = full(concated);
%     end
end
