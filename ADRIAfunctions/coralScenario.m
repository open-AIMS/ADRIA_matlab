function results = coralScenario(interv, criteria, coral_params, sim_params, ...
    TP_data, site_ranks, strongpred, init_cov, ...
    wave_scen, dhw_scen, site_data, collect_logs, odesolve,ode_opts)
% Run a single intervention scenario with given criteria and parameters
% If each input was originally a table, this is equivalent to a running
% a single row from each (i.e., a unique combination)
%
% Inputs:
%    interv       : table, row of intervention table
%    criteria     : table, row of criteria weights table
%    coral_params : table, row of coral parameters
%    sim_params   : struct, of simulation constants
%    TP_data      : matrix, transitional probability matrix
%    site_ranks   : matrix, of site centrality
%    strongpred   : matrix, of strongest predecessor for each site
%    init_cov     : matrix, of initial coral cover at time = 1
%    wave_scen    : matrix[timesteps, nsites], spatio-temporal wave damage scenario
%    dhw_scen     : matrix[timesteps, nsites], degree heating weeek scenario
%    site_data    : table, of site data. Should be pre-sorted by the
%                         `recom_connectivity` column
%    collect_logs : string, indication of what logs to collect - "seed", "shade", "site_rankings"
%    odesolve : function handle, designates the solver to be used to solve
%               the growth ode at each time step.
%    ode_opts : struct with labels 'abstol' and 'reltol', designates
%               tolerances to be used in ode solver.
% Outputs:
%    results     : struct, of 
%                  Y         - simulation results
%                  seed_log  - Sites seeded over time
%                  shade_log - Sites shaded over time
%
% Example:
%    See `single_scenario_example.m` in the `examples` directory.
%
% References:
%     1. Bozec, Y.-M., Rowell, D., Harrison, L., Gaskell, J., Hock, K., 
%          Callaghan, D., Gorton, R., Kovacs, E. M., Lyons, M., Mumby, P., 
%          & Roelfsema, C. (2021). 
%        Baseline mapping to support reef restoration and resilience-based 
%        management in the Whitsundays. 
%        https://doi.org/10.13140/RG.2.2.26976.20482

    %% Set up connectivity
    nsites = height(site_data);

    %% Set up structure for dMCDA
    nsiteint = sim_params.nsiteint;

    tf = sim_params.tf; % timeframe: total number of time steps

    % Set up result structure where necessary
    % coralsdeployed = zeros(params.tf,ninter); % = nsiteint*seedcorals*nnz(nprefsite);

    % years to start seeding/shading
    seed_start_year = interv.Seedyr_start;
    shade_start_year = interv.Shadeyr_start;

    %(pi*((2-1)/2)^2)/(10^2)
    seed1 = interv.Seed1; %tabular Acropora size class 2, per year per species per cluster
    seed2 = interv.Seed2; %corymbose Acropora size class 2, per year per species per cluster
    fogging = interv.fogging; % percent reduction in bleaching mortality through fogging
    srm = interv.SRM; % DHW equivalents reduced by some shading mechanism
    seed_years = interv.Seedyrs; %years to seed
    shade_years = interv.Shadeyrs; %years to shade

    % find yrs at which to reassess seeding site selection and indicate
    % these in yrslogseed
    yrslogseed = false(1, tf);
    if interv.Seedfreq > 0
        % set seed locations on specified years
        yrslogseed(seed_start_year:interv.Seedfreq:(seed_start_year + seed_years - 1)) = true;
    else
        % set once at specified start year
        yrslogseed(max(seed_start_year, 2)) = true;
    end

    % find yrs at which to reassess seeding site selection and indicate
    % these in yrslogseed
    yrslogshade = false(1, tf);
    if interv.Shadefreq > 0
        % set locations on specified years
        yrslogshade(shade_start_year:interv.Shadefreq:(shade_start_year + shade_years - 1)) = true;
    else
        % set once at specified start year
        yrslogshade(max(shade_start_year, 2)) = true;
    end

    prefseedsites = false;
    prefshadesites = false;

    strategy = interv.Guided; % Intervention strategy: 0 is random, 1 is guided
    is_guided = strategy > 0;
    if is_guided

        %% Weights for connectivity , waves (ww), high cover (whc) and low
        wtwaves = criteria.wave_stress; % weight of wave damage in MCDA
        wtheat = criteria.heat_stress; % weight of heat damage in MCDA
        wtconshade = criteria.shade_connectivity; % weight of connectivity for shading in MCDA
        wtconseed = criteria.seed_connectivity; % weight of connectivity for seeding in MCDA
        wthicover = criteria.coral_cover_high; % weight of high coral cover in MCDA (high cover gives preference for seeding corals but high for SRM)
        wtlocover = criteria.coral_cover_low; % weight of low coral cover in MCDA (low cover gives preference for seeding corals but high for SRM)
        wtpredecseed = criteria.seed_priority; % weight for the importance of seeding sites that are predecessors of priority reefs
        wtpredecshade = criteria.shade_priority; % weight for the importance of shading sites that are predecessors of priority reefs
        risktol = criteria.deployed_coral_risk_tol; % risk tolerance

        % Filter out sites outside of desired depth range
        if ~all(site_data.sitedepth == 0)
            max_depth = criteria.depth_min + criteria.depth_offset;
            depth_criteria = (site_data.sitedepth > -max_depth) & (site_data.sitedepth < -criteria.depth_min);
            depth_priority = site_data{depth_criteria, "recom_connectivity"};
        else
            % No depth data, so consider all sites
            depth_priority = site_data{:, "recom_connectivity"};
        end

        if isa(depth_priority, 'cell')
            % Catch edge case where IDs are interpreted as text/cells
            depth_priority = 1:length(depth_priority);
            depth_priority = depth_priority';
        end

        max_cover = site_data.k / 100.0; % Max coral cover at each site. Divided by 100 to convert to proportion

        % pre-allocate prefseedsites, prefshadesites and rankings
        rankings = [depth_priority, zeros(length(depth_priority), 1), zeros(length(depth_priority), 1)];
        prefseedsites = zeros(1, nsiteint);
        prefshadesites = zeros(1, nsiteint);

        sslog = struct('seed', true, 'shade', true);
        dMCDA_vars = struct('site_ids', depth_priority, 'nsiteint', nsiteint, 'prioritysites', sim_params.prioritysites, ...
            'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, 'heatstressprob', 0, ...
            'sumcover', 0, 'maxcover', max_cover, 'area', site_data.area, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
            'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, 'wtpredecshade', wtpredecshade);
    else
        % set random seed based on selection of intervention parameters
        % for repeatability
        rng(int64(sum(interv{:, :})+sum(criteria{:, :})))
    end

    %% Set up result structure
    nspecies = height(coral_params);

    % containers for seeding, shading and cooling
    nprefseed = zeros(tf, 1);
    nprefshade = zeros(tf, 1);
    % nprefcool = zeros(params.tf, ninter);

    %% Define constant table location for seed values
    % Seed1 = Tabular Acropora Enhanced (taxa 1, size class 2)
    % Seed2 = Corymbose Acropora Enhanced (taxa 3, size class 2)
    tabular_enhanced = coral_params.taxa_id == 1;
    corymbose_enhanced = coral_params.taxa_id == 3;
    s1_idx = find(tabular_enhanced & (coral_params.class_id == 2));
    s2_idx = find(corymbose_enhanced & (coral_params.class_id == 2));

    %% Update ecological parameters based on intervention option

    % Set up assisted adaptation values
    assistadapt = zeros(nspecies, 1);

    % assign level of assisted coral adaptation
    assistadapt(tabular_enhanced) = interv.Aadpt;
    assistadapt(corymbose_enhanced) = interv.Aadpt;

    % level of added natural coral adaptation
    natad = coral_params.natad + interv.Natad;

    % taxa-specific differences in natural bleaching resistance
    bleach_resist = coral_params.bleach_resist;

    %% Extract other parameters
    LPdhwcoeff = sim_params.LPdhwcoeff; % shape parameters relating dhw affecting cover to larval production
    DHWmaxtot = sim_params.DHWmaxtot; % max assumed DHW for all scenarios.  Will be obsolete when we move to new, shared inputs for DHW projections
    LPDprm2 = sim_params.LPDprm2; % parameter offsetting LPD curve

    %% project wave mortality
    mwaves = ndSparse(zeros(tf, nspecies, nsites));
    wavemort90 = coral_params.wavemort90; % 90th percentile wave mortality
    for sp = 1:nspecies
        mwaves(:, sp, :) = wavemort90(sp) .* wave_scen;
    end

    mwaves(mwaves < 0) = 0;
    mwaves(mwaves > 1) = 1;

    % Pre-calculate proportional survivors from wave damage
    Sw_t = 1.0 - mwaves;

    %% Setting constant vars to avoid incurring access overhead
    % specify constant odeset option
    non_neg_opt = odeset('RelTol',ode_opts.reltol, 'AbsTol',ode_opts.abstol);


    % return 3 steps as we're only interested in the last one anyway
    % saves memory
    tspan = [0, 0.5, 1];

    e_r = coral_params.growth_rate; % coral growth rates
    e_mb = coral_params.mb_rate; %background coral mortality

    e_P = sim_params.max_coral_cover; % max total coral cover

    % competition factor between Small Massives and Acropora
    e_comp = sim_params.comp;

    % Gompertz shape parameters for bleaching
    neg_e_p1 = -sim_params.gompertz_p1;
    neg_e_p2 = -sim_params.gompertz_p2;

    %% States at time = 1
    % Set base cover for all species, and initial population sizes
    % matrix in which to store the output
    Yout = zeros(tf, nspecies, nsites);

    % Set initial population sizes at tstep = 1
    Yout(1, :, :) = init_cov;

    % These logs need to be collected as part of the run
    Yshade = ndSparse(zeros(tf, nsites));
    Yfog = ndSparse(zeros(tf, nsites));
    Yseed = ndSparse(zeros(tf, 2, nsites)); % only log seedable corals to save memory

    if any(strlength(collect_logs) > 0)
        % Optional logs
        if any(ismember("site_rankings", collect_logs))
            site_rankings = ndSparse(zeros(tf, nsites, 2)); % log seeding/shading ranks
        end
        % total_cover = zeros(tf, nsites);
    end

    max_settler_density = 2.5; % used by Bozec et al 2021 for Acropora
    density_ratio_of_settlers_to_larvae = 1 / 2000; %Bozec et al. 2021
    basal_area_per_settler = pi * ((0.5 / 100)^2); % in m2 assuming 1 cm diameter

    potential_settler_cover = max_settler_density * basal_area_per_settler ...
        * density_ratio_of_settlers_to_larvae;

    to_seed_corals = (seed1 > 0) || (seed2 > 0);

    %% Running the model as pulse-impulsive
    % Loop for time steps
    for tstep = 2:tf
        % Larval productivity is reduced as a function of last year's heat
        % stress. In other words, surviving coral have reduced fecundity.
        p_step = tstep - 1; % previous timestep
        past_DHW_stress = dhw_scen(p_step, :); % last year's heat stress

        % relative scope for coral larval production per site
        LPs = ADRIA_larvalprod(tstep, assistadapt, natad, past_DHW_stress, ...
            LPdhwcoeff, DHWmaxtot, LPDprm2); % larval productivity ...
        % for each species, site and year as a function of past heat exposure
        %LP_graph(tstep,:,:) = LPs

        Y_pstep = squeeze(Yout(p_step, :, :)); %dimensions: species and sites

        % calculates scope for coral fedundity for each size class and at
        % each site. Now using coral fecundity per m2 in 'coralSpec()'
        fecundity_scope = fecundityScope(Y_pstep, coral_params, site_data);

        rec_abs = potential_settler_cover * ((fecundity_scope .* LPs) * TP_data);

        % adjusting recruitment at each site by dividing by the area
        rec = rec_abs ./ site_data.area';

        %% Setup MCDA before bleaching season

        % heat stress used as criterion in site selection
        dhw_step = dhw_scen(tstep, :); % subset of DHW for given timestep

        in_shade_years = (shade_start_year <= tstep) && (tstep <= (shade_start_year + shade_years - 1));
        in_seed_years = ((seed_start_year <= tstep) && (tstep <= (seed_start_year + seed_years - 1)));

        %% Select preferred intervention sites based on criteria (heuristics)
        if is_guided
            % Update values for dMCDA

            % Factor 2
            % probability of coral damage from waves used as criterion in
            % site selection

            % NOTE: Wave Damage is turned off for Feb deliv. These are all zeros!
            dMCDA_vars.damprob = squeeze(mwaves(tstep, :, :))'; % wave_scen(tstep, :)';
            dMCDA_vars.heatstressprob = dhw_step'; % heat stress

            %Factor 4: total coral cover state used as criterion in site selection;
            dMCDA_vars.sumcover = squeeze(sum(Y_pstep, 1))'; % Dims: nsites * 1
            % dMCDA_vars.prioritysites = prioritysites;
            % DCMAvars.centr = centr

            sslog.seed = yrslogseed(tstep);
            sslog.shade = yrslogshade(tstep);
            [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites, rankings] = ADRIA_DMCDA(dMCDA_vars, strategy, sslog, prefseedsites, prefshadesites, rankings); % site selection function for intervention deployment
            nprefseed(tstep, 1) = nprefseedsites; % number of preferred seeding sites
            nprefshade(tstep, 1) = nprefshadesites; % number of preferred shading sites

            if any(strlength(collect_logs) > 0) && any(ismember("site_rankings", collect_logs))
                % skip first col as it only holds site ids
                site_rankings(tstep, rankings(:, 1), :) = rankings(:, 2:end);
            end
        else
            if yrslogseed(tstep)
                % Unguided deployment, seed/shade corals anywhere
                prefseedsites = randi(nsites, [nsiteint, 1])';
            end

            if yrslogshade(tstep)
                prefshadesites = randi(nsites, [nsiteint, 1])';
            end
        end
        
        has_shade_sites = ~all(prefshadesites == 0);
        has_seed_sites = ~all(prefseedsites == 0);

        % Warming and disturbance event going into the pulse function
        if (srm > 0) && in_shade_years && has_shade_sites
            Yshade(tstep, prefshadesites) = srm;

            % Apply reduction in DHW due to shading
            adjusted_dhw = max(0.0, dhw_step - Yshade(tstep, :));
        else
            adjusted_dhw = dhw_step;
        end

        if (fogging > 0.0) && in_shade_years && (has_seed_sites || has_shade_sites)
            if has_seed_sites
                % Always fog where sites are selected if possible
                adjusted_dhw(:, prefseedsites) = adjusted_dhw(:, prefseedsites) .* (1.0 - fogging);
                Yfog(tstep, prefseedsites) = fogging;
            elseif has_shade_sites
                % Otherwise, if no sites are selected, fog selected shade sites
                adjusted_dhw(:, prefshadesites) = adjusted_dhw(:, prefshadesites) .* (1.0 - fogging);
                Yfog(tstep, prefshadesites) = fogging;
            end
        end

        % Calculate bleaching mortality
        % Apply bleaching mortality
        Sbl = 1.0 - ADRIA_bleachingMortality(tstep, neg_e_p1, ...
                    neg_e_p2, assistadapt, natad, ...
                    bleach_resist, adjusted_dhw);

        % proportional loss + proportional recruitment
        prop_loss = Sbl .* squeeze(Sw_t(p_step, :, :));

        Yin1 = Y_pstep .* prop_loss;

        if to_seed_corals && in_seed_years && has_seed_sites
            % Seed corals
            % extract colony areas for sites selected and convert to m^2
            col_area_seed1 = coral_params.colony_area_cm2(s1_idx) / (10^4);
            col_area_seed2 = coral_params.colony_area_cm2(s2_idx) / (10^4);

            site_area_seed = site_data.area(prefseedsites) .* (site_data.k(prefseedsites) / 100); % extract site area for sites selected and scale by available space for populations (k)

            scaled_seed1 = (((seed1 / nsiteint) * col_area_seed1) ./ site_area_seed)';
            scaled_seed2 = (((seed2 / nsiteint) * col_area_seed2) ./ site_area_seed)';

            % Seed each site with the value indicated with seed1/seed2
            Yin1(s1_idx, prefseedsites) = Yin1(s1_idx, prefseedsites) + scaled_seed1; % seed Enhanced Tabular Acropora
            Yin1(s2_idx, prefseedsites) = Yin1(s2_idx, prefseedsites) + scaled_seed2; % seed Enhanced Corymbose Acropora

            % Log seed values/sites
            Yseed(tstep, 1, prefseedsites) = scaled_seed1; % log site as seeded with Enhanced Tabular Acropora
            Yseed(tstep, 2, prefseedsites) = scaled_seed2; % log site as seeded with Enhanced Corymbose Acropora
        end

        % Run ODE for all species and sites

        [~, Y] = odesolve(@(t, X) growthODE4_KA(X, e_r, e_P, e_mb, rec, e_comp), tspan, Yin1, non_neg_opt);
        

        % Using the last step from ODE above,
        % If any sites are above their maximum possible value,
        % proportionally adjust each entry so that their sum is <= P
        Y = reshape(Y(end, :), nspecies, nsites);
        if any(sum(Y, 1) > e_P)
            idx = find(sum(Y, 1) > e_P);
            Ys = Y(:, idx);
            Y(:, idx) = (Ys ./ sum(Ys)) * e_P;
        end

        Yout(tstep, :, :) = Y;

    end % tstep

    % Assign to output variable
    results = struct('Y', Yout);
    if any(strlength(collect_logs) > 0)
        if any(ismember("seed", collect_logs))
            results.seed_log = full(Yseed);
        end

        if any(ismember("shade", collect_logs))
            results.shade_log = full(Yshade);
        end

        if any(ismember("fog", collect_logs))
            results.fog_log = full(Yfog);
        end

        if any(ismember("site_rankings", collect_logs))
            results.site_rankings = full(site_rankings);
        end
    end
end