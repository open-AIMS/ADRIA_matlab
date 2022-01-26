function mean_r = siteRanking(rankings, orient, func)
% Ranks over time for each site.
% If multiple scenarios are provided, returns the mean of total for each
% site.
%
% Inputs:
%     rankings : matrix, logged time series from ADRIA runs.
%     orient   : str, gather metrics for 'seed' or 'shade'
%     func     : function, aggregation method (defaults to `mean`)
%
% Outputs:
%     s : matrix[nsites, 1],
    arguments
        rankings double
        orient string
        func = @mean
    end
    
    res_type = ndims(rankings);
    switch res_type
        case 3
            if orient == "seed"
                mean_r = func(squeeze(rankings(:, :, 1)), 1)';
            elseif orient == "shade"
                mean_r = func(squeeze(rankings(:, :, 2)), 1)';
            end
        case 5
            if orient == "seed"
                mean_r = func(squeeze(func(squeeze(rankings(:, :, 1, :, :)), 1)), [2,3]);
            elseif orient == "shade"
                mean_r = func(squeeze(func(squeeze(rankings(:, :, 2, :, :)), 1)), [2,3]);
            end
        otherwise
            error("Unknown number of ranking log dimensions.")
    end
        
     
end