function result_set = collectMetrics(Y, coral_params, metrics)
% Apply a set of metrics (collection of functions) to a result set.
    arguments
        Y double
        coral_params table
        metrics cell
    end
    
    result_set = struct();
    for met = metrics
        func = met{1};
        func_name = func2str(func);
        
        if contains(func_name, "@")
            tmp = regexp(func2str(func), ")", 'split', 'once');
            func_name = regexprep(tmp{2}, {'[%()^,. ]+', '_+$'}, {'_', ''});
        end

        result_set.(func_name) = func(Y, coral_params);
    end
end