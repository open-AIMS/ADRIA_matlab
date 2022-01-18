ai = ADRIA();
ai.loadConnectivity('MooreTPmean.xlsx');

X = ai.sample_defaults;
X.Guided = 2;

Y = ai.run(X, sampled_values=true, nreps=3);

[~, ~, coral_params] = ai.splitParameterTable(X);

met = collectMetrics(Y, coral_params, {@coralTaxaCover});

assert(all(met.coralTaxaCover.total_cover < 1.0, 'all'), 'Non-relative cover found!');
