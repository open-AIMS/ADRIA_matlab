% Example script showcasing how monte carlo parameter combinations
% can be generated.

inter_opts = interventionDetails();
criteria_opts = criteriaDetails();
coral_opts = coralDetails();

% all available parameter options
combined_opts = [inter_opts; criteria_opts; coral_opts];

% Generate using simple monte carlo
% Create selection table based on lower/upper parameter bounds
N = 20;
p_sel = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound(p);
    b = combined_opts.upper_bound(p);
    
    selection = (b - a).*rand(N, 1) + a;
    
    p_sel.(combined_opts.name(p)) = selection;
end


converted_tbl = convertScenarioSelection(p_sel, combined_opts);

converted_tbl
