function s = seedSelection(seed_log, orient)
% Total times each site or species got selected for seeding
% If multiple scenarios are provided, returns the mean of total for each
% site.
%
% Inputs:
%     shade_log : matrix, logged time series from ADRIA runs.
%     orient    : str, orientation of results. Report by "site" or 
%                     "species"
%
% Outputs:
%     s : matrix[nsites, 1], total (or mean of total) times a site was
%             selected for seeding if `orient` := "site"
%         matrix[nspecies, 1] total (or mean of total) tiomes a species
%             was selected for seeding, if `orient` := "species"
    arguments
        seed_log double
        orient string = "site"
    end

    res_type = ndims(seed_log);
    if ~ismember(res_type, [3,5])
        error("Unknown number of seed log dimensions.")
    end

    if orient == "site"
        % Get number of times a site was selected for seeding
        seed_log = logical(seed_log);

        % Single scenario: sum over time and species
        % Multi-scenario: Average of site selection over time, 
        %                 over scenarios/reps
        slice = [1,2];
    elseif orient == "species"
        % Get amount of coral
        
        % Single scenario: the total number of corals seeded
        % Multi-scenario: an average of total seeding over scenarios/reps
        slice = [1,3];
    else
        error("Unknown orientation option for seedSelection()")
    end
    
    switch res_type
        case 3
            % Single scenario run
            % sum of times a site was selected over time
            s = squeeze(sum(seed_log, slice));

        case 5
            % Multi-scenario run
            % Average of site selection over time, over scenarios/reps
            s = squeeze(mean(sum(seed_log, slice), [4,5]));
    end
end
