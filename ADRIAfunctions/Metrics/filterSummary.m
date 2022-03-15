function filtered = filterSummary(summarized, idx)
% Filter summarized result set down to a few targeted scenarios.
%
% Examples:
% 
% >> filterSummary(Y.coralEvenness, find(Y.inputs.Seedyr_start == 16))
%
% >> target_scenarios = find((Y.inputs.Seedyr_start == 16) & ...
%      (Y.inputs.Shadeyr_start == 2));
% >> filterSummary(Y.coralEvenness, target_scenarios)
    arguments
        summarized % summarized results
        idx        % indices to filter to
    end
    
    mean_res = summarized.mean;
    nd = ndims(mean_res);

    % Need to filter the last dimension (i.e., by scenario), but we don't 
    % know the number of dimensions up front, so this approach takes care 
    % of that.
    sz = size(mean_res);
    sel = repmat({1}, 1, nd);
    for s = 1:nd
        if s < nd
            sel{s} = 1:sz(s);
        else
            sel{s} = idx;
        end
    end

    fnames = fieldnames(summarized);
    filtered = struct();
    for fn = string(fnames)'
        filtered.(fn) = summarized.(fn)(sel{:});
    end
end