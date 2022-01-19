function Y = runADRIA(intervs, crit_weights, coral_params, sim_params, ...
                          TP_data, site_ranks, strongpred, ...
                          n_reps, wave_scen, dhw_scen, alg_ind, ...
                          file_prefix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ADRIA: Adaptive Dynamic Reef Intervention Algorithm %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run all simulations.
%
% Inputs:
%    interv       : table, of intervention scenarios
%    criteria     : table, of criteria weights for each scenario
%    coral_params : table, of ecological parameter permutations
%    sim_params   : struct, of simulation constants
%    wave_scen    : matrix[timesteps, nsites, N], spatio-temporal wave damage scenario
%    dhw_scen     : matrix[timesteps, nsites, N], degree heating weeek scenario
%    alg_ind      : int, MCDA ranking algorithm flag
%                  - 1, Order ranking
%                  - 2, TOPSIS
%                  - 3, VIKOR
%    file_prefix : str, (optional) write results to netcdf instead of 
%                    storing in memory.
%                    If provided, output `Y` will be a struct of zeros.
%
% Output:
%    Y : struct,
%          - TC [n_timesteps, n_sites, N, n_reps]
%          - C  [n_timesteps, n_sites, N, n_species, n_reps]
%          - E  [n_timesteps, n_sites, N, n_reps]
%          - S  [n_timesteps, n_sites, N, n_reps]
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

[timesteps, nsites, ~] = size(wave_scen);

% Create output matrices
n_species = height(coral_params);  % total number of species considered

if ~exist('file_prefix', 'var')
    file_prefix = false;
    Y_TC = zeros(timesteps, nsites, N, n_reps);
    Y_C = zeros(timesteps, n_species, nsites, N, n_reps);
    Y_E = zeros(timesteps, nsites, N, n_reps);
    Y_S = zeros(timesteps, nsites, N, n_reps);
else
    % Create much smaller representative subset to return
    % if saving to disk (saves memory)
    Y_TC = zeros(timesteps, nsites, 1, n_reps);
    Y_C = zeros(timesteps, n_species, nsites, 1, n_reps);
    Y_E = zeros(timesteps, nsites, 1, n_reps);
    Y_S = zeros(timesteps, nsites, 1, n_reps);
end

parfor i = 1:N
    scen_it = intervs(i, :);
    scen_crit = crit_weights(i, :);
    % scen_params = params(i, :);
    % scen_ecol = ecol_params(i, :);
    
    % temp reassignment
    TC = zeros(timesteps, nsites, 1, n_reps);
    C = zeros(timesteps, n_species, nsites, 1, n_reps);
    E = zeros(timesteps, nsites, 1, n_reps);
    S = zeros(timesteps, nsites, 1, n_reps);

    for j = 1:n_reps
        tmp = runADRIAScenario(scen_it, scen_crit, ...
                               coral_params, sim_params, ...
                               TP_data, site_ranks, strongpred, ...
                               wave_scen(:, :, j), dhw_scen(:, :, j), alg_ind);

        TC(:, :, 1, j) = tmp.TC;
        C(:, :, :, 1, j) = tmp.C;
        E(:, :, 1, j) = tmp.E;
        S(:, :, 1, j) = tmp.S;
    end
    
    if isstring(file_prefix) || ischar(file_prefix)
        tmp_fn = strcat(file_prefix, '_[[', num2str(i), ']].nc');
        tmp_d = struct();
        tmp_d.TC = TC;
        tmp_d.C = C;
        tmp_d.E = E;
        tmp_d.S = S;
        saveData(tmp_d, tmp_fn);
        continue
    end
    
    Y_TC(:, :, i, :) = TC;
    Y_C(:, :, :, i, :) = C;
    Y_E(:, :, i, :) = E;
    Y_S(:, :, i, :) = S;
end

% Assign results outside of parfor
Y.TC = Y_TC;
Y.C = Y_C;
Y.E = Y_E;
Y.S = Y_S;

end
