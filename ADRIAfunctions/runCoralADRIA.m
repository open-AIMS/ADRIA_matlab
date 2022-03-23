function results = runCoralADRIA(intervs, crit_weights, coral_params, sim_params, ...
                           TP_data, site_ranks, strongpred, initial_cover, ...
                           n_reps, wave_scen, dhw_scen, site_data, collect_logs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ADRIA: Adaptive Dynamic Reef Intervention Algorithm %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run all simulations.
%
% Inputs:
%    interv       : table, of intervention scenarios
%    crit_weights : table, of criteria weights for each scenario
%    coral_params : table, of coral parameter values for each scenario
%    sim_params   : struct, of simulation constants
%    TP_data      : matrix, of transition probabilities (connectivity)
%    site_ranks   :
%    strongpred   : matrix, strongest predecessor for each site
%    initial_cover: matrix[timesteps, nsites, N], initial coral cover data
%    n_reps       : int, number of replicates to use
%    wave_scen    : matrix[timesteps, nsites, N], spatio-temporal wave damage scenario
%    dhw_scen     : matrix[timesteps, nsites, N], degree heating weeek scenario
%    site_data    : table, of site data
%    collect_logs : string, of what logs to collect
%                     "seed", "shade", "site_rankings" etc.
%
% Output:
%    results : struct,
%          - Y, [n_timesteps, n_sites, N, n_reps]
%          - seed_log, [n_timesteps, n_sites, N, n_species, n_reps]
%          - shade_log, [n_timesteps, n_sites, N, n_reps]
%
% Model guides the selection of
% (1) reef sites for the deployment of restoration and adaptation interventions, and
% (2) which interventions in the portfolio to deploy given a set of decision criteria

% Scale: ADRIA is developed for fine-scale interventions, but should work at any scale.
% Inputs: spatially and temporally dynamic layers of DHW, risk from wave damage (routine),
% water-column chlorophyll and connectivity. These layers are produced from eReefs RECOMs.
% Larval connectivity (work in progress) is dynamic and varies with multiple env variables.
% Coral models: currently uses a four-species dynamic community model as a place-holder:
% (1) thermally sensitive unenhanced, (2) thermally sensitive enhanced,
% (3) hardier unenhanced and (4) hardier enhanced.
% Focus areas: uses a set of 26 reef sites (as options for interventions). These
% are the contingencies from which a subset of sites are selected for intervention.
% The selection process is annual and occurs as a dynamic multi-criteria decision analysis using
% coral cover, predicted thermal stress, predicted wave stress and connectivity as key criteria.
% Interventions simulated are (1) outplanting of enhanced (warm-adapted) corals, site-scale solar
% radiation management (i.e. fogging) and rubble stabilisation.

% ADRIA produces coral projections (cover) for different climate change scenarios and intervention
% strategies as pairs consisting (1) the counterfactual (i.e. the do nothing option) and (2)
% the intervention. Each pair is then simulated 500 to 100 times to produce a distribution of net
% predicted outcomes for each climate change scenario and intervention strategy. Each intervention
% strategy is further partitioned into different tactics by simulating deployment decision makers
% who employ different risk criteria and objective functions to the decision problem. This enables
% the user to examine the optimality of different tactics relative to the uninformed (random or
% haphazard) selection protocol.

% Size of a site = 50 m by 200 m  = 10^4 m2 = 1 hectare
% Max number of sites targeted for intervention = 6;
% Min number of sites targeted = 5. This may occur in years where a deployment mission is aborted e.g. due to storm risk

% A: start modelling at 1 year of age and surviving.
% Size of an outplanted juvenile = 5 cm2 = 5*10^(-4) m2/cm2 =5*10^(-4)
% (modeliiing from equivalent of 1 year of size) -> factor in mortality differences via treatment
% B: Ten corals per m2 makes 3% coral cover
% Max number of corals deployed per group of sites per year = 1000,000
% Absolute cover of all deployed corals = 10^6 corals *3*10^-3) m2/coral = 3000 m2
% Relative cover of all deployed corals = 3000m2/100,000m2 = 3 percent
N = height(intervs);

timesteps = sim_params.tf;
nsites = height(site_data);

% generate template struct for coral parameters
coral_spec = coralSpec();

% Create output matrices
n_species = height(coral_spec);  % total number of species considered

if ~exist('collect_logs', 'var')
    collect_logs = [];
end

Y = ndSparse(zeros(timesteps, n_species, nsites, N, n_reps));
if any(ismember("seed", collect_logs))
    seed = ndSparse(zeros(timesteps, n_species, nsites, N, n_reps));
end

if any(ismember("shade", collect_logs))
    shade = ndSparse(zeros(timesteps, nsites, N, n_reps));
end

if any(ismember("site_rankings", collect_logs))
    rankings = ndSparse(zeros(timesteps, nsites, 2, N, n_reps));
end

% Catch for special edge case when only a single scenario is available
coral_cover_dims = ndims(initial_cover);
if coral_cover_dims == 3
    initial_cover = initial_cover(:, :, 1:n_reps);
elseif coral_cover_dims == 2
    initial_cover = repmat(initial_cover, 1, 1, n_reps);
end


parfor i = 1:N
    scen_it = intervs(i, :);
    scen_crit = crit_weights(i, :);
    
    % Note: This slows things down considerably
    % Could rejig everything to use (subset of) the table directly...
    c_params = extractCoralSamples(coral_params(i, :), coral_spec);

    for j = 1:n_reps
        res = coralScenario(scen_it, scen_crit, ...
                               c_params, sim_params, ...
                               TP_data, site_ranks, strongpred, ...
                               initial_cover(:, :, j), ...
                               wave_scen(:, :, j), dhw_scen(:, :, j), ...
                               site_data, collect_logs);
        Y(:, :, :, i, j) = res.Y;
        
        if any(strlength(collect_logs) > 0)
            % TODO: Generalize so we're not manually adding logs
            %       as we add them...
            if any(ismember("seed", collect_logs))
                seed(:, :, :, i, j) = res.seed_log;
            end

            if any(ismember("shade", collect_logs))
                shade(:, :, i, j) = res.shade_log;
            end

            if any(ismember("site_rankings", collect_logs))
                rankings(:, :, :, i, j) = res.site_rankings;
            end
        end
    end
end

results = struct('Y', full(Y));

% Store the average locations/ranks for each climate replicate
if any(ismember("seed", collect_logs))
    results.seed_log = full(mean(seed, ndims(seed)));
end

if any(ismember("shade", collect_logs))
    results.shade_log = full(mean(shade, ndims(shade)));
end

if any(ismember("site_rankings", collect_logs))
    rankings(rankings == 0) = nsites + 1;
    results.site_rankings = full(mean(rankings, ndims(rankings)));
end

end
