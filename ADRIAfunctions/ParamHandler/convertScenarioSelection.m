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
    % This approach adds a new column every loop, which is slow but works.
    % Columns may be of variable types is a pain to
    % write a clean approach using a pre-allocated table.
    if ~istable(sel_values)
        if iscell(sel_values)
            sel_values = cell2mat(sel_values);
        end

        sel_values = array2table(sel_values, 'VariableNames', p_opts.name);
    end

    converted = table;
    for p = 1:length(p_opts.name)
        pname = p_opts.name(p);
        ptype = p_opts.ptype(p);
        selection = sel_values.(pname);

        converted.(pname) = NaN(length(selection), 1);
        for sel = 1:length(selection)
            % convert from cell array to matrix if needed
            if ptype == "categorical" || ptype == "integer"
                tmp = floor(selection(sel));
                if tmp == p_opts.upper_bound(p)
                    % subtract a small constant to ensure flooring works
                    % as intended when the value is at upper limit
                    tmp = max(floor(tmp - 1e-6), 1);
                end

                tmp_p = p_opts.options{p};
                if iscell(tmp_p)
                    converted{sel, pname} = tmp_p{1}{tmp};
                else
                    % extract from container map
                    converted{sel, pname} = tmp_p(tmp);
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

