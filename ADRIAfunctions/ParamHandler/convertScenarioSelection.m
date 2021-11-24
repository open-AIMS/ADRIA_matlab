function converted = convertScenarioSelection(sel_values, p_opts)
% Converts selected discrete values back to their categorical options.
%
% Example:
%     If a parameter is of type `categorical` and can be `A` or `B`
%     The possible categorical options are `1 => A` and `2 => B`.
%
%     The `sel_values` array will hold values of `1` or `2`, and
%     this function maps this back to `A` or `B` for use with ADRIA.
%
% Inputs:
%     sel_values : table or array, of parameter value selections
%                    if array, converts to table using information in
%                    p_opts
%     p_opts     : table, of parameter options (value ranges, etc)
%
% Outputs:
%     converted : table, of selected parameter values mapped back
%                        to their actual values.
%
% See also:
%     `interventionDetails()`, `criteriaDetails()`

    % For each selection, map the option id back to intended values
    % Note:
    % This approach adds a new row every loop, which is slow but works.
    % Columns may be of variable type/length and its a pain to 
    % write a clean approach using a pre-allocated table.
    converted = table;
    
    if ~istable(sel_values)
        sel_values = array2table(sel_values, 'VariableNames', p_opts.name);
    end
    
    for p = 1:length(p_opts.name)
        pname = p_opts.name(p);
        ptype = p_opts.ptype(p);
        selection = sel_values.(pname);
        % col(1:length(selection)) = {NaN};
        % converted(:, p) = {1:length(selection)};
        for sel = 1:length(selection)
            % convert from cell array to matrix if needed
            if ptype == "categorical" || ptype == "integer"
                tmp = floor(selection(sel));
                if tmp == p_opts.upper_bound{p} % && tmp == selection(sel)
                    % subtract a small constant to ensure flooring works
                    % as intended when the value is at upper limit
                    tmp = max(floor(tmp - 1e-6), 1);
                end

                try
                    converted{sel, pname} = cell2mat(p_opts.options{p}{1}(tmp));
                catch
                    converted{sel, pname} = p_opts.options{p}{1}(tmp);
                end
            elseif ptype == "float"
                % values should already be in expected range
                % so no conversion necessary
                converted{sel, pname} = selection(sel);
            else
                warning(strcat("Unknown parameter type", ptype, ". Skipping ", pname))
            end
        end
    end

end

