function results = coralScenario(interv, criteria, coral_params, sim_params, ...
    TP_data, site_ranks, strongpred, init_cov, ...
    wave_scen, dhw_scen, site_data, collect_logs)
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
%
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

    % Some sites are within the same grid cell for connectivity
    % Here, we find those sites and map the connectivity data
    % (e.g., repeat the relevant row/columns)
    [~, ~, g_idx] = unique(site_data.recom_connectivity, 'rows', 'first');
    TP_data = TP_data(g_idx, g_idx);  

    %% Set up structure for dMCDA
    nsiteint = sim_params.nsiteint;
    
    tf = sim_params.tf; % timeframe: total number of time steps
    
    % Set up result structure where necessary
    % coralsdeployed = zeros(params.tf,ninter); % = nsiteint*seedcorals*nnz(nprefsite);
    
    % years to start seeding/shading
    seed_start_year = interv.Seedyr_start;
    shade_start_year = interv.Shadeyr_start;
    % find yrs at which to reassess seeding site selection and indicate
    % these in yrslogseed
    yrslogseed = false(1, tf);
    yrschangeseed = shade_start_year:interv.Seedfreq:tf;
    yrslogseed(yrschangeseed) = true;

    % if seed_times is zero, assess once in year 2
    % (set and forget site selection)
    if interv.Seedfreq == 0
        yrslogseed(2) = true;
    end

    % find yrs at which to reassess seeding site selection and indicate
    % these in yrslogseed
    yrslogshade = false(1, tf);
    yrschangeshade = shade_start_year:interv.Shadefreq:tf;
    yrslogshade(yrschangeshade) = true;

    % if shade_times is zero, assess once in year 2
    % (set and forget site selection)
    if interv.Shadefreq == 0
        yrslogshade(2) = true;
    end
    
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
        max_depth = criteria.depth_min + criteria.depth_offset;
        depth_criteria = (site_data.sitedepth > -max_depth) & (site_data.sitedepth < -criteria.depth_min);
        depth_priority = site_data{depth_criteria, "recom_connectivity"};

        max_cover = site_data.k/100.0; % Max coral cover at each site. Divided by 100 to convert to proportion  

        % pre-allocate prefseedsites, prefshadesites and rankings
        rankings = [depth_priority,zeros(length(depth_priority),1),zeros(length(depth_priority),1)];
        prefseedsites = zeros(1,nsiteint);
        prefshadesites = zeros(1,nsiteint);

        sslog = struct('seed',true, 'shade',true);
        dMCDA_vars = struct('site_ids', depth_priority, 'nsiteint', nsiteint, 'prioritysites', [], ...
            'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, 'heatstressprob', 0, ...
            'sumcover', 0, 'maxcover', max_cover, 'area', site_data.area, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
            'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, 'wtpredecshade', wtpredecshade);
    else
        % set random seed based on selection of intervention parameters
        % for repeatability
        rng(int64(sum(interv{:, :}) + sum(criteria{:, :})))
    end
    
    %% A few hard-coded things here we need to convert to input variables
    %sizes of corals seeded
    diam_seeded_corals = 2; %cm
    colony_area_seeded_corals = (pi*(diam_seeded_corals/2)^2)/10^4; %m2
    
    %size of the coral arena used when we define Seed1 and Seed2 (inputs) 
    A_arena = 100;  %10m by 10m
    
    %calculate what seeding rates correspond to in proportion of area added 
    seed1 = interv.Seed1*colony_area_seeded_corals/A_arena; %tabular Acropora size class 2, converted to rel cover
    seed2 = interv.Seed2*colony_area_seeded_corals/A_arena; %corymbose Acropora size class 2, converted to rel cover
    %seed2 = interv.Seed2*(pi*((2-1)/2)^2)/10^4/10^2; %corymbose Acropora size class 2, converted to rel cover
    
    srm = interv.SRM; %DHW equivalents reduced by fogging or some other shading mechanism
    seedyears = interv.Seedyrs; %years to shade are in column 8
    shadeyears = interv.Shadeyrs; %years to shade are in column 9

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
    mwaves = zeros(tf, nspecies, nsites);
    
    % Disable wave mortality for now: Agreed on action for Feb deliverable
    % See email: Mon 24/01/2022 15:17 - RE: IPMF and ADRIA workflow for BC
    % NOTE: site selection in MCDA based on damage probability also disabled
    
    % wavemort90 = coral_params.wavemort90; % 90th percentile wave mortality
    % for sp = 1:nspecies
    %     mwaves(:, sp, :) = wavemort90(sp) .* wave_scen;
    % end

    % mwaves(mwaves < 0) = 0;
    % mwaves(mwaves > 1) = 1;

    % Pre-calculate proportional survivors from wave damage
    Sw_t = 1 - mwaves;

    %% Setting constant vars to avoid incurring access overhead
    % specify constant odeset option
    non_neg_opt = odeset('NonNegative', 1:nspecies:nsites);

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
    Yseed = ndSparse(zeros(tf, nspecies, nsites));

    if any(strlength(collect_logs) > 0)
        % Optional logs
        if any(ismember("site_rankings", collect_logs))
            site_rankings = ndSparse(zeros(tf, nsites, 2));  % log seeding/shading ranks
        end
        % total_cover = zeros(tf, nsites);
    end

    max_settler_density = 2.5; % used by Bozec et al 2021 for Acropora
    density_ratio_of_settlers_to_larvae = 1/2000; %Bozec et al. 2021
    basal_area_per_settler = pi*((0.5/100)^2); % in m2 assuming 1 cm diameter

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
        
        potential_settler_cover = max_settler_density * basal_area_per_settler ...
                                * density_ratio_of_settlers_to_larvae;
        
        rec_abs = potential_settler_cover * (fecundity_scope * TP_data) .* LPs;

       % adjusting recruitment at each site by dividing by the area
        rec = rec_abs ./ site_data.area';
               
        %% Setup MCDA before bleaching season

        % heat stress used as criterion in site selection
        dhw_step = dhw_scen(tstep, :); % subset of DHW for given timestep

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
            dMCDA_vars.sumcover = squeeze(sum(Y_pstep, 1))';  % Dims: nsites * 1
            % dMCDA_vars.prioritysites = prioritysites;
            % DCMAvars.centr = centr
            sslog.seed = yrslogseed(tstep);
            sslog.shade = yrslogshade(tstep);
            [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites, rankings] = ADRIA_DMCDA(dMCDA_vars, strategy,sslog,prefseedsites,prefshadesites,rankings); % site selection function for intervention deployment
            nprefseed(tstep, 1) = nprefseedsites; % number of preferred seeding sites
            nprefshade(tstep, 1) = nprefshadesites; % number of preferred shading sites
            
            if any(strlength(collect_logs) > 0) && any(ismember("site_rankings", collect_logs))
                % skip first col as it only holds site ids
                site_rankings(tstep, rankings(:, 1), :) = rankings(:, 2:end);
            end
        else
            % Unguided deployment, seed/shade corals anywhere
            prefseedsites = randi(nsites, [nsiteint, 1])';
            prefshadesites = randi(nsites, [nsiteint, 1])';
        end

        % Warming and disturbance event going into the pulse function
        if (srm > 0) && (tstep <= (shade_start_year+shadeyears)) && ~all(prefshadesites == 0)
            Yshade(tstep, prefshadesites) = srm;
            
            % Apply reduction in DHW due to shading
            adjusted_dhw = max(0.0, dhw_step - Yshade(tstep, :));
        else
            adjusted_dhw = dhw_step;
        end

        % Calculate bleaching mortality
        Sbl = 1 - ADRIA_bleachingMortality(tstep, neg_e_p1, ...
            neg_e_p2, assistadapt, ...
            natad, bleach_resist, adjusted_dhw);

        % proportional loss + proportional recruitment
        prop_loss = Sbl .* squeeze(Sw_t(p_step, :, :));
        Yin1 = Y_pstep .* prop_loss;

        if (tstep <= (seed_start_year+seedyears)) && ~all(prefseedsites == 0)
            % Seed each site with the value indicated with seed1 and/or seed2
            Yin1(s1_idx, prefseedsites) = Yin1(s1_idx, prefseedsites) + seed1; % seed Enhanced Tabular Acropora
            Yin1(s2_idx, prefseedsites) = Yin1(s2_idx, prefseedsites) + seed2; % seed Enhanced Corymbose Acropora
            
            % Log seed values/sites
            Yseed(tstep, s1_idx, prefseedsites) = seed1; % log site as seeded with Enhanced Tabular Acropora
            Yseed(tstep, s2_idx, prefseedsites) = seed2; % log site as seeded with Enhanced Corymbose Acropora
        end

        % Run ODE for all species and sites
        [~, Y] = ode45(@(t, X) growthODE4_KA(X, e_r, e_P, e_mb, rec, e_comp), tspan, Yin1, non_neg_opt);
        
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
        
        if any(ismember("site_rankings", collect_logs))
            results.MCDA_rankings = full(site_rankings);
        end
    end
end