function Y = runScenarios(intervs, crit_weights, params, ecol_params, ...
                          TP_data, site_ranks, strongpred, ...
                          n_reps, wave_scen, dhw_scen, alg_ind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ADRIA: Adaptive Dynamic Reef Intervention Algorithm %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run all simulations.
%
% Inputs:
%    interv      : table, of intervention scenarios
%    criteria    : table, of criteria weights for each scenario
%    params      : table, of environment parameter permutations
%    ecol_params : table, of ecological parameter permutations
%    wave_scen   : matrix[timesteps, nsites, N], spatio-temporal wave damage scenario
%    dhw_scen    : matrix[timesteps, nsites, N], degree heating weeek scenario
%    alg_ind     : int, MCDA ranking algorithm flag
%                  - 1, Order ranking
%                  - 2, TOPSIS
%                  - 3, VIKOR
%
% Output:
%    Y : struct,
%          - TC
%          - C
%          - E
%          - S
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
% Y = zeros(N, nreps);

% Create temporary struct
tmp_s.TC = 0;
tmp_s.C = 0;
tmp_s.E = 0;
tmp_s.S = 0;
Y = repmat(tmp_s, N, n_reps);

n_rep_scens = length(wave_scen);

parfor i = 1:N
    scen_it = intervs(i, :);
    scen_crit = crit_weights(i, :);
    scen_params = params(i, :);
    scen_ecol = ecol_params(i, :);
    
    % Select random subset of RCP conditions WITHOUT replacement
    rcp_scens = datasample(1:n_rep_scens, n_reps, 'Replace', false);
    w_scen = wave_scen(:, :, rcp_scens);
    d_scen = dhw_scen(:, :, rcp_scens);
    for j = 1:n_reps
        Y(i, j) = runADRIAScenario(scen_it, scen_crit, ...
                                   scen_params, scen_ecol, ...
                                   TP_data, site_ranks, strongpred, ...
                                   w_scen(:, :, j), d_scen(:, :, j), alg_ind);
    end
end

end
