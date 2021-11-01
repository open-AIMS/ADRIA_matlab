function converted = convertScenarioSelection(sel_values, p_opts)
% Handles conversion of raw categorical option selections and maps these
% back to their discrete values
%
% Inputs:
%     sel_values : table, of parameter value selections
%     options    : table, of parameter options (value ranges, etc)

    % For each selection, map the option id back to intended values
    % Note:
    % This approach adds a new row every loop, which is slow but works.
    % Columns may be of variable type/length and its a pain to 
    % write a clean approach using a pre-allocated table.
    converted = table;
    
    for p = 1:length(p_opts.name)
        pname = p_opts.name(p);
        ptype = p_opts.ptype(p);
        selection = sel_values.(pname);
        % col(1:length(selection)) = {NaN};
        % converted(:, p) = {1:length(selection)};
        for sel = 1:length(selection)
            % convert from cell array to matrix if needed
            if ptype == "categorical"
                try
                    converted{sel, pname} = cell2mat(p_opts.options{p}{1}(selection(sel)));
                catch
                    converted{sel, pname} = p_opts.options{p}{1}(selection(sel));
                end
            elseif ptype == "float"
                % values should already be in expected range
                % so no conversion necessary
                converted{sel, pname} = selection(sel);
            else
                warning(strcat("Unknown parameter type! Skipping ", pname))
            end
        end
    end

end

