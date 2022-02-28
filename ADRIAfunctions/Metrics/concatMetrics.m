function concated = concatMetrics(Y_all, attr)
% Join collected metric results (by `collectMetrics()`) together.
    nested = split(attr, ".");
    
    if isstruct(Y_all)
        % Extract indicated field if not a collection of gathered results
        concated = squeeze(getfield(Y_all, nested{:}));
        return
    end
    
    concated = getfield(Y_all{1}, nested{:});
    b = getfield(Y_all{2}, nested{:});

    concated = cat(ndims(concated)+1, concated, b);
    nd = ndims(concated);

    for i = 3:length(Y_all)
        concated = cat(nd, concated, getfield(Y_all{i}, nested{:}));
    end

    % Reorder into expected dimensions if needed
    if nd > 3
        x = size(concated);
        if length(Y_all) ~= x(end-1)
            concated = squeeze(permute(concated, [1:(nd-2), nd, nd-1]));
        end
    end

    if class(concated) == "ndSparse"
        concated = full(concated);
    end
end
