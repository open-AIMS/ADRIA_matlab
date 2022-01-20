function Y = coralScenario(interv, criteria, coral_params, sim_params, ...
    TP_data, site_ranks, strongpred, ...
    wave_scen, dhw_scen)
% Run a single intervention scenario with given criteria and parameters
% If each input was originally a table, this is equivalent to a running
% a single row from each (i.e., a unique combination)
%
% Inputs:
%    interv      : table, row of intervention table
%    criteria    : table, row of criteria weights table
%    coral_params: table, row of coral parameters
%    sim_params  : struct, of simulation constants
%    TP_data     : matrix, transitional probability matrix
%    site_ranks  : matrix, of site centrality
%    strongpred  : matrix, of strongest predecessor for each site
%    wave_scen   : matrix[timesteps, nsites], spatio-temporal wave damage scenario
%    dhw_scen    : matrix[timesteps, nsites], degree heating weeek scenario
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
    nsites = width(TP_data);

    %% Set up structure for dMCDA
    nsiteint = sim_params.nsiteint;
    
    % Set up result structure where necessary
    prefseedsites = []; % set the list of preferred seeding sites to empty
    prefshadesites = []; % set the list of preferred shading sites to empty
    % coralsdeployed = zeros(params.tf,ninter); % = nsiteint*seedcorals*nnz(nprefsite);
    
    strategy = interv.Guided; % Intervention strategy: 0 is random, 1 is guided
    if strategy > 0
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

       dMCDA_vars = struct('nsites', nsites, 'nsiteint', nsiteint, 'prioritysites', [], ...
            'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, 'heatstressprob', 0, ...
            'sumcover', 0,'maxcover',sim_params.max_coral_cover, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
            'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, 'wtpredecshade', wtpredecshade);

    end
    
    seed1 = interv.Seed1*(pi*((2-1)/2)^2)/10^4/10^2; %tabular Acropora size class 2, converted to rel cover
    seed2 = interv.Seed2*(pi*((2-1)/2)^2)/10^4/10^2; %corymbose Acropora size class 2, converted to rel cover
    srm = interv.SRM; %DHW equivalents reduced by fogging or some other shading mechanism
    seedyears = interv.Seedyrs; %years to shade are in column 8
    shadeyears = interv.Shadeyrs; %years to shade are in column 9

    %% Set up result structure
    tf = sim_params.tf; % timeframe: total number of time steps
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

    wavemort90 = coral_params.wavemort90; % 90th percentile wave mortality

    %% project wave mortality
    mwaves = zeros(tf, nspecies, nsites);
    for sp = 1:nspecies
        mwaves(:, sp, :) = wavemort90(sp) .* wave_scen;
    end

    mwaves(mwaves < 0) = 0;
    mwaves(mwaves > 1) = 1;

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

    dhw_ss = max(dhw_scen-srm, 0.0); % avoid negative values

    %% States at time = 1
    % Set base cover for all species, and initial population sizes
    % matrix in which to store the output: first branching corals, then
    % foliose corals, then macroalgae
    Yout = zeros(tf, nspecies, nsites);

    % Set initial population sizes at tstep = 1
    Yout(1, :, :) = repmat(coral_params.basecov, 1, nsites);

    % Seed/shade log
    Yseed = zeros(tf, nspecies, nsites);
    Yshade = zeros(tf, nspecies, nsites);
    % total_cover = zeros(tf, nsites);

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
        % each site
        fecundity_scope = fecundityScope(Y_pstep, coral_params); 
        
        
        max_settler_density = 2.5; % used by Bozec et al 2021 for Acropora
        density_ratio_of_larvae_to_settlers = 3000; %Bozec et al. 2021
        basal_area_per_settler = pi*((1/100)^2); % in m2 assuming 2 cm diameter
        
        potential_settler_cover = max_settler_density * basal_area_per_settler ...
                                * density_ratio_of_larvae_to_settlers;
        
        rec = potential_settler_cover * (fecundity_scope * TP_data).* LPs;
        
                
              %% Setup MCDA before bleaching season

        % heat stress used as criterion in site selection
        dhw_step = dhw_ss(tstep, :); % subset of DHW for given timestep

        %% Select preferred intervention sites based on criteria (heuristics)
        if strategy > 0 % guided

            % Update values for dMCDA

            % Factor 2
            % probability of coral damage from waves used as criterion in
            % site selection
            dMCDA_vars.damprob = wave_scen(tstep, :)';
            dMCDA_vars.heatstressprob = dhw_step'; % heat stress

            %Factor 4: total coral cover state used as criterion in site selection;
            dMCDA_vars.sumcover = sum(Yout(p_step, :, :), 2);

            [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(dMCDA_vars, strategy); % site selection function for intervention deployment
            nprefseed(tstep, 1) = nprefseedsites; % number of preferred seeding sites
            nprefshade(tstep, 1) = nprefshadesites; % number of preferred shading sites
        elseif strategy == 0 % unguided deployment
            prefshadesites = randi(nsites, [nsiteint, 1])'; % if unguided, then seed corals anywhere
            prefshadesites = randi(nsites, [nsiteint, 1])'; % if unguided, then shade corals anywhere
        end

        % Warming and disturbance event going into the pulse function
        if (srm > 0) && (tstep <= shadeyears) && ~all(prefshadesites == 0)
            Yshade(tstep, :, prefshadesites) = srm;
        end

        % Calculate bleaching mortality
        Sbl = 1 - ADRIA_bleachingMortality(tstep, neg_e_p1, ...
            neg_e_p2, assistadapt, ...
            natad, bleach_resist, dhw_step);

        % proportional loss + proportional recruitment
        prop_loss = Sbl .* squeeze(Sw_t(p_step, :, :));
        Yin1 = Y_pstep .* prop_loss;

        if (tstep <= seedyears) && ~all(prefseedsites == 0)
            % Log seed values/sites
            Yin1(s1_idx, prefseedsites) = Yin1(s1_idx, prefseedsites) + seed1; % seed enhanced corals of group 2
            Yin1(s2_idx, prefseedsites) = Yin1(s2_idx, prefseedsites) + seed2; % seed enhanced corals of group 4
            Yseed(tstep, s1_idx, prefseedsites) = seed1; % log site as seeded with gr2
            Yseed(tstep, s2_idx, prefseedsites) = seed2; % log site as seeded with gr4
            
        end

        % Run ODE for all species and sites
        [~, Y] = ode45(@(t, X) growthODE4_KA(X, e_r, e_P, e_mb, rec, e_comp), tspan, Yin1, non_neg_opt);
        Y = Y(end, :);  % get last step in ODE
        
        % If any sites are above their maximum possible value,
        % proportionally adjust each entry so that their sum is < P
        Y = reshape(Y, nspecies, nsites);
        if any(sum(Y, 1) > e_P)
            idx = find(sum(Y, 1) > e_P);
            Ys = Y(:, idx);
            Y(:, idx) = (Ys ./ sum(Ys)) * e_P;
        end

        Yout(tstep, :, :) = Y;

    end % tstep
    save(sprintf('Alg%1.0f_sites.mat',alg_ind),'prefseedsites','prefshadesites')
    % Assign to output variable
    Y = Yout;
end