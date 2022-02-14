function mean_r = siteRanking(rankings, orient, func)
% Ranks over time for each site.
% If multiple scenarios are provided, returns the mean of total for each
% site.
%
% NOTE: Sites assigned a rank of nsites + 1 are not considered!
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
    else
        error(strcat("Unknown result set for site ranking: ", orient))
    end

    res_type = ndims(rankings);
    switch res_type
        case 3
            mean_r = func(squeeze(rankings(:, :, target_col)), 1)';
        case 5
            try
                mean_r = func(squeeze(func(squeeze(rankings(:, :, target_col, :, :)), 1)), [2,3]);
            catch err
                if strcmp(err.identifier, 'MATLAB:sizeDimensionsMustMatch')
                    mean_r = func(squeeze(func(squeeze(rankings(:, :, target_col, :, :)), 1)), [], [2,3]);
                elseif strcmp(err.identifier, 'MATLAB:var:invalidSizeWgts')
                    mean_r = func(squeeze(func(squeeze(rankings(:, :, target_col, :, :)), 1)), 0, [2,3]);
                else
                    rethrow(err)
                end
            end
            
        otherwise
            error("Unknown number of ranking log dimensions.")
    end
end