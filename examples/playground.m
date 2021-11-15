inter_opts = interventionDetails();

test_mat = cell2mat(inter_opts.option_bounds);

ptype = inter_opts.ptype;
lower = test_mat(:, 1);
upper = test_mat(:, 2);

