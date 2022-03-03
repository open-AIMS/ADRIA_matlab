% Tests to ensure runs work without error.
% NOTE: Does not check the GA-based guided deployment!

%% Run unguided
ai = ADRIA();
ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')

X = ai.sample_defaults;
X.Guided = 0;

Y = ai.run(X, sampled_values=true, nreps=3);

%% Run guided

ai = ADRIA();
ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')

X = ai.sample_defaults;

for i = 1:3
    X.Guided = i;
    Y = ai.run(X, sampled_values=true, nreps=3);
end


%% Run parameter extremes

% Run extreme parameter bounds to catch edge cases
ai = ADRIA();
ai.loadConnectivity('../Inputs/Moore/connectivity/2015/moore_d3_2015_transfer_probability_matrix_wide.csv');
ai.loadSiteData('../Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv')

bounds = ai.sample_bounds;

X = ai.sample_defaults;

X{:, :} = bounds.lower_bound';
ai.run(X, sampled_values=true, nreps=3);

X{:, :} = bounds.upper_bound';
X.Guided = 3;
ai.run(X, sampled_values=true, nreps=3);