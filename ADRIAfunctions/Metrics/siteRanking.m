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
    
    % Make non-selected sites affect stats negatively
    % Explanation: Lower values are of higher rank
    % but we use 0 to mean not considered. Taking the average
    % will affect rankings in the positive direction, whereas we want them
    % to be ranked lower
    nsites = size(rankings);
    nsites = nsites(2);
    rankings(rankings == 0) = nsites + 1;
    
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