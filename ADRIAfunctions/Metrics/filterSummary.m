function filtered = filterSummary(summarized, idx, other)
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
        summarized       % summarized results
        idx              % scenario indices to filter to
        other.time_idx = NaN   % time steps to filter to
        other.site_idx = NaN   % site indices to filter to
    end
    
    time_idx = other.time_idx;
    site_idx = other.site_idx;
    
    mean_res = summarized.mean;
    nd = ndims(mean_res);

    % Need to filter the last dimension (i.e., by scenario), but we don't 
    % always know the number of dimensions up front, so this approach takes 
    % care of that.
    sz = size(mean_res);
    sel = repmat({1}, 1, nd);
    filter_time = ~all(isnan(time_idx));
    filter_sites = ~all(isnan(site_idx));
    filter_scens = ~all(isnan(idx));
    for s = 1:nd
        if s == 1 && filter_time
            sel{s} = time_idx;
        elseif (s == (nd-1)) && filter_sites
            sel{s} = site_idx;
        elseif s == nd && filter_scens
            sel{s} = idx;
        else            
            sel{s} = 1:sz(s);
        end
    end

    fnames = fieldnames(summarized);
    filtered = struct();
    for fn = string(fnames)'
        filtered.(fn) = summarized.(fn)(sel{:});
    end
end