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
    
    if orient == "seed"
        target_col = 1;
    elseif orient == "shade"
        target_col = 2;
    end

    res_type = ndims(rankings);
    switch res_type
        case 3
            mean_r = func(squeeze(rankings(:, :, target_col)), 1)';
        case 5
            mean_r = func(squeeze(func(squeeze(rankings(:, :, target_col, :, :)), 1)), [2,3]);
        otherwise
            error("Unknown number of ranking log dimensions.")
    end
    
    % Assign sites that are never considered a 0
    mean_r(mean_r == nsites+1) = 0;
end