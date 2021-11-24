function Y = runADRIAScenario(interv, criteria, params, ecol_params, ...
                              TP_data, site_ranks, strongpred, ...
                              wave_scen, dhw_scen, alg_ind)
% Run a single intervention scenario with given criteria and parameters
% If each input was originally a table, this is equivalent to a running
% a single row from each (i.e., a unique combination)
%
% Inputs:
%    interv      : table, row of intervention table
%    criteria    : table, row of criteria weights table
%    params      : table, row of environment parameter permutations
%    ecol_params : table, row of ecological parameter permutations
%    TP_data     : matrix, transitional probability matrix
%    site_ranks  : matrix, of site centrality
%    strongpred  : matrix, of strongest predecessor for each site
%    wave_scen   : matrix[timesteps, nsites], spatio-temporal wave damage scenario
%    dhw_scen    : matrix[timesteps, nsites], degree heating weeek scenario
%    alg_ind     : int, ranking algorithm choice 
%                    (Order: 1, TOPSIS: 2, Vikor: 3)
%
% Example:
%    See `single_scenario_example.m` in the `examples` directory.

    %% Weights for connectivity , waves (ww), high cover (whc) and low
    wtwaves = criteria(:, 1); % weight of wave damage in MCDA
    wtheat = criteria(:, 2); % weight of heat damage in MCDA
    wtconshade = criteria(:, 3); % weight of connectivity for shading in MCDA
    wtconseed = criteria(:, 4); % weight of connectivity for seeding in MCDA
    wthicover = criteria(:, 5); % weight of high coral cover in MCDA (high cover gives preference for seeding corals but high for SRM)
    wtlocover = criteria(:, 6); % weight of low coral cover in MCDA (low cover gives preference for seeding corals but high for SRM)
    wtpredecseed = criteria(:, 7); % weight for the importance of seeding sites that are predecessors of priority reefs
    wtpredecshade = criteria(:, 8); % weight for the importance of shading sites that are predecessors of priority reefs
    risktol = criteria(:, 9); % risk tolerance

    %% Set up connectivity
    nsites = width(TP_data);

    %% Set up structure for dMCDA
    nsiteint = params.nsiteint;
    dMCDA_vars = struct('nsites', nsites, 'nsiteint', nsiteint, 'prioritysites', [], ...
        'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, 'heatstressprob', 0, ...
        'sumcover', 0, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
        'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, 'wtpredecshade', wtpredecshade);

    %% Set up result structure
    tf = params.tf; % timeframe: total number of time steps
    nspecies = params.nspecies;

    % container for coral cover and total coral cover
    coral_cover = zeros(tf, nspecies, nsites);

    % containers for seeding, shading and cooling
    nprefseed = zeros(tf, 1);
    nprefshade = zeros(tf, 1);
    % nprefcool = zeros(params.tf, ninter);

    prefseedsites = []; % set the list of preferred seeding sites to empty
    prefshadesites = []; % set the list of preferred shading sites to empty
    prioritysites = []; % set the list of priority sites to empty
    % coralsdeployed = zeros(params.tf,ninter); % = nsiteint*seedcorals*nnz(nprefsite);

    Yin1 = zeros(nspecies, nsites);
    Yin2 = zeros(nspecies, nsites);
    Yseed = zeros(nspecies, nsites);
    Yshade = zeros(1, nsites);
    total_cover = zeros(tf, nsites);

    %% Extract intervention options
    strategy = interv(:, 1); % Intervention strategy: 0 is random, 1 is guided
    pgs = interv(:, 2); % group of priority sites
    seed1 = interv(:, 3); %species seeded - here the sensitive Acropora
    seed2 = interv(:, 4); %species seeded - here the hardier other coral
    srm = interv(:, 5); %DHW equivalents reduced by fogging or some other shading mechanism
    seedyears = interv(:, 8); %years to shade are in column 8
    shadeyears = interv(:, 9); %years to shade are in column 9

    %% Update ecological parameters based on intervention option
    assistadapt = ecol_params.assistadapt;
    assistadapt(2) = interv(:, 6); % level of assisted coral adaptation is column 6 in the intervention table
    natad = ecol_params.natad + interv(:, 7); % level of added natural coral adaptation is column 7 in the intervention table

    if pgs == 1
        prioritysites = params.psgA; %see ADRIAparms for list of sites in group
    elseif pgs == 2
        prioritysites = params.psgB; %see ADRIAparms for list of sites in group
    elseif pgs == 3
        prioritysites = params.psgC; %see ADRIAparms for list of sites in group
    end

    %% Extract other parameters
    LPdhwcoeff = params.LPdhwcoeff;
    DHWmaxtot = params.DHWmaxtot;
    LPDprm2 = params.LPDprm2;
    wavemort90 = params.wavemort90; % 90th percentile wave mortality

    %% project wave mortality
    mwaves = zeros(tf, nspecies, nsites);
    for species = 1:nspecies
        %including wave vulnerability of different corals here
        mwaves(:, species, :) = wavemort90(species) * wave_scen;
    end

    mwaves(mwaves < 0) = 0;
    mwaves(mwaves > 1) = 1;
    
    % Pre-calculate proportional survivors from wave damage
    Sw_t = 1 - mwaves;

    %% temporary allocation to avoid incurring access overhead
    % specify constant odeset option
    non_neg_opt = odeset('NonNegative', 1:4);
    tspan = [0, 1];

    e_r = ecol_params.r;
    e_P = ecol_params.P;  % max total coral cover
    e_mb = ecol_params.mb;
    e_p = ecol_params.p;  % Gompertz shape parameters

    neg_e_p1 = -e_p(1);  % setting constant values for use in loop
    neg_e_p2 = -e_p(2);
    
    dhw_ss = max(dhw_scen - srm, 0.0);  % avoid negative values
    
    %% States at time = 1
    % Set base cover for all species
    Y0 = zeros(nspecies, nsites); %coral start cover before each intervention
    for sp = 1:nspecies
        Y0(sp, :) = params.(strcat('basecov', num2str(sp)));
    end

    % matrix in which to store the output: first branching corals, then
    % foliose corals, then macroalgae
    Yout = zeros(tf, nspecies, nsites);
    Yout(1, :, :) = Y0; % Set initial population sizes at tstep = 1

    %% Running the model as pulse-impulsive
    % Loop for time steps
    for tstep = 2:tf
        p_step = tstep - 1; % previous timestep

        past_DHW_stress = dhw_scen(p_step, :); % call last year's DHWs (heat stress)
        [LP1, LP2, LP3, LP4] = ADRIA_larvalprod(tstep, assistadapt, natad, past_DHW_stress, ...
            LPdhwcoeff, DHWmaxtot, LPDprm2); % larval productivity ...

        % for each species, site and year as a function of past heat exposure
        rec = (squeeze(Yout(p_step, :, :)) * TP_data) .* [LP1; LP2; LP3; LP4];

        %% Setup MCDA before bleaching season

        % Factor 1: digraph centrality based on connectivity
        % sums over species, second index becomes sites
        total_cover(tstep, :) = sum(coral_cover(p_step, :, :), 2);

        % Factor 2:
        % probability of coral damage from waves used as criterion in
        % site selection
        dam = wave_scen(tstep, :)';

        % Factor 3:
        % heat stress used as criterion in site selection
        dhw_step = dhw_ss(tstep, :); % subset of DHW for given timestep
        heatstress = dhw_step';

        % Factor 4: Coral state
        total_cover_t = total_cover(tstep, :)'; %total coral cover used as criterion in site selection

        %% Select preferred intervention sites based on criteria (heuristics)
        if strategy == 1 % guided

            % Update values for dMCDA
            tmp_dMCDA_vars = dMCDA_vars;
            tmp_dMCDA_vars.damprob = dam;
            tmp_dMCDA_vars.heatstressprob = heatstress;
            tmp_dMCDA_vars.sumcover = total_cover_t;
            tmp_dMCDA_vars.prioritysites = prioritysites;
            % DCMAvars.centr = centr

            [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(tmp_dMCDA_vars, alg_ind); % site selection function for intervention deployment
            nprefseed(tstep, 1) = nprefseedsites; % number of preferred seeding sites
            nprefshade(tstep, 1) = nprefshadesites; % number of preferred shading sites
        elseif strategy == 0 % unguided deployment
            prefseedsites = randi(nsites, [nsiteint, 1])'; % if unguided, then seed corals anywhere
            prefshadesites = randi(nsites, [nsiteint, 1])'; % if unguided, then shade corals anywhere
        end
        
        % Determine survivors from bleaching events across all sites
        % Slower than explicit for loop :(
        % Sbl_t = arrayfun(@(x) 1 - ADRIA_bleachingMortality(tstep, neg_e_p1, neg_e_p2, assistadapt, natad, x), dhw_ss, 'UniformOutput', false);
        % Sbl_t = vertcat(Sbl_t{:});

        %% Run site loop and apply interventions before bleaching season
        for site = 1:nsites
            % Warming and disturbance event going into the pulse function
            if ismember(site, prefshadesites) == 1 && tstep <= shadeyears % if the site in the loop equals a preferred shading site
                Yshade(site) = srm; % log the site as shaded
                % BL(tstep,:,site,I,sims) = Yout(tstep-1,:,site)'.*(1-Sbl);
            elseif ismember(site, prefshadesites) == 0 || tstep > shadeyears %if the site in the loop is not a preferred shading site
                Yshade(site) = 0; % log the site as not shaded
                % BL(tstep,:,site,I,sims) = Yout(tstep-1,:,site)'.*(1-Sbl);
            end

            % survivors from bleaching event
            Sbl = 1 - ADRIA_bleachingMortality(tstep, neg_e_p1, ...
                                               neg_e_p2, assistadapt, ...
                                               natad, dhw_step(site));

            % those survival rates are used to adjust overall coral
            % survival
            Yin1(:, site) = Yout(p_step, :, site) .* Sbl .* Sw_t(p_step, :, site);

            % if the site in the loop equals a preferred seeding site
            if ismember(site, prefseedsites) == 1 && tstep <= seedyears
                Yin1(2, site) = Yin1(2, site) + seed1; % seed enhanced corals of group 2
                Yin1(4, site) = Yin1(4, site) + seed2; % seed enhanced corals of group 4
                Yseed(2, site) = seed1; % log site as seeded with gr2
                Yseed(4, site) = seed2; % log site as seeded with gr4
            else
                Yseed(2, site) = 0;
                Yseed(4, site) = 0;
            end

            %% Recruitment and seeding

            % add new recruits: need to use min/max function to ensure
            % cover doesn't exceed maximum total coral cover (ecol_params.P)
            Yin2(:, site) = Yin1(:, site) + rec(:, site);
            Yin = Yin2(:, site);

            [~, Y] = ode45(@(t, X) ADRIA4groupsODE(X, e_r, e_P, e_mb), tspan, Yin, non_neg_opt);

            % ODE to solve assemblage composition after a year based on
            % vital rates. Update of output with new population sizes from
            % the end of the ODE run
            Yout(tstep, :, site) = Y(end, :); % update population sizes
            Yout(Yout > e_P) = e_P; % limit covers to carrying capacity (obsolete)

            % output we save for analyses. Includes: tf,nspecies,nsites,ninter,sims
            % raw results for current simulation
            coral_cover(:, :, :) = Yout(:, :, :);

            % seedsim(tstep, :, site, I, sim) = Yseed(:, site); % combine seeding logs
            % shadesim(tstep, :, site, I, sim) = Yshade(site); % combined shading logs

        end % sites
    end % tstep

    %% assign results
    [TC, C, E, S] = reefConditionMetrics(coral_cover);

    % seedlog and shadelog are omitted for now
    Y = struct('TC', TC, ...
        'C', C, ...
        'E', E, ...
        'S', S);
    end