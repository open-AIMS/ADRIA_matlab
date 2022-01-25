ai = ADRIA();
ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial.csv')

X = ai.sample_defaults;
X.Guided = 2;

Y = ai.run(X, sampled_values=true, nreps=3);

[~, ~, coral_params] = ai.splitParameterTable(X);

met = collectMetrics(Y, coral_params, {@coralTaxaCover});

assert(all(met.coralTaxaCover.total_cover < 1.0, 'all'), 'Non-relative cover found!');
