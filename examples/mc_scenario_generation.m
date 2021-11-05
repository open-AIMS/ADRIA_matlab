inter_opts = interventionDetails();
criteria_opts = criteriaDetails();


combined_opts = [inter_opts; criteria_opts];

% Generate using simple monte carlo
% Create selection table based on lower/upper parameter bounds
N = 20;
p_sel = table;
for p = 1:height(combined_opts)
    curr_row = combined_opts.option_bounds{p};
    
    if combined_opts.ptype{p} ~= "float"
        selection = randi(curr_row, N, 1);
    else
        a = curr_row(1);
        b = curr_row(2);
        selection = (b - a) .* rand(N, 1, 'double');
        % p_sel.(inter_opts.name{p}) = selection;
    end
    
    p_sel.(combined_opts.name{p}) = selection;
end


converted_tbl = convertScenarioSelection(p_sel, combined_opts);

% table2array(converted_tbl)
converted_tbl
