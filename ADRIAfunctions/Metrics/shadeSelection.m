function s = shadeSelection(shade_log)
% Total times each site got selected for shading
% If multiple scenarios are provided, returns the mean of total for each
% site.
%
% Inputs:
%     shade_log : matrix, logged time series from ADRIA runs.
%
% Outputs:
%     s : matrix[nsites, 1], total (or mean of total) times a site was
%             selected for shading.
    res_type = ndims(shade_log);
    switch res_type
        case 2
            s = sum(shade_log, 1)';

        case 4
            s = sum(mean(shade_log, [3,4]), 1)';
        otherwise
            error("Unknown number of shade log dimensions.")
    end
end