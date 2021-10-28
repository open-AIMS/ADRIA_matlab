function Y = runADRIAScenario(interv, criteria, params, ecol_params, ...
                              TP_data, site_ranks, strongpred, nsites, ...  
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
%    wave_scen   : matrix[timesteps, nsites], spatio-temporal wave damage scenario
%    dhw_scen    : matrix[timesteps, nsites], degree heating weeek scenario
%    alg_ind     : int, algorithm choice (1, 2, 3)
%
% Example: [UNFINISHED]
% >> interventions = interventionSpecification(sims=10);
% >> criteria_weights = criteriaWeights();
% >> [params, ecol_params] = ADRIAparms(interv); %environmental and ecological parameter values etc
%
% >> % ... generate parameter perturbations ...
%
% >> [IT, ~] = interventionTable(interv); %calls function that builds intervention table, ...
% >> ninter = size(IT, 1);
% >> Y = zeros(ninter, 4);  % result set
% >> for i = 1:niter
% >>     Y(i, :) = runADRIAScenario(IT(i, :), criteria_weights(i, :), params(i, :), ecol_params(i, :))
% >> end


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
    % [TP_data, site_ranks, strongpred, nsites] = ADRIA_TP_Moore(params.con_cutoff); % con_cutoff filters out low connectivities

    %% Set up structure for dMCDA
    dMCDA_vars = struct('nsites', nsites, 'nsiteint', params.nsiteint, 'prioritysites', [], ...
        'strongpred', strongpred, 'centr', site_ranks.C1, 'damprob', 0, 'heatstressprob', 0, ...
        'sumcover', 0, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
        'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, 'wtpredecshade', wtpredecshade);
    
    %% Set up result structure
    tf = params.tf;  % timeframe: total number of time steps
    
    % container for coral cover and total coral cover
    coral_cover = zeros(tf, params.nspecies, nsites);
    
    % containers for seeding, shading and cooling
    nprefseed = zeros(params.tf, 1);
    nprefshade = zeros(params.tf, 1);
    % nprefcool = zeros(params.tf, ninter);
    
    prefseedsites = [];  % set the list of preferred seeding sites to empty
    prefshadesites = []; % set the list of preferred shading sites to empty
    prioritysites = [];  % set the list of priority sites to empty
    % coralsdeployed = zeros(params.tf,ninter); % = params.nsiteint*seedcorals*nnz(nprefsite);

    Yin1 = zeros(params.nspecies, nsites);
    Yin2 = zeros(params.nspecies, nsites);
    Yseed = zeros(params.nspecies, nsites);
    Yshade = zeros(1, nsites);
    total_cover = zeros(params.tf, nsites);
    Y0 = zeros(params.nspecies, nsites); %coral start cover before each intervention
    Y0(1, :) = params.basecov1; %sensitive unenhanced corals set to their basecover
    Y0(2, :) = params.basecov2; %sensitive enhanced corals set to their basecover
    Y0(3, :) = params.basecov3; %naturally hardy corals set to their basecover
    Y0(4, :) = params.basecov4; %enhanced naturally hardy corals set to their basecover
    
    % matrix in which to store the output: first branching corals, then 
    % foliose corals, then macroalgae
    Yout = zeros(params.tf, params.nspecies, nsites);
    Yout(1, :, :) = Y0; % Set initial population sizes at tstep = 1
    % Yout(tstep,:,:) = Y0; %pos 2 is species, pos3 is sites
    rec = zeros(params.nspecies, nsites); %recruitment
    
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
    mwaves = zeros(tf, params.nspecies, nsites);
    for species = 1:4
        %including wave vulnerability of different corals here
        mwaves(:, species, :) = wavemort90(species) * wave_scen;
    end

    mwaves(mwaves < 0) = 0;
    mwaves(mwaves > 1) = 1;
    
    %% pre-running initial step
    %TP = squeeze(TP_data(:,:,Env(tstep,sim)));
    tstep = 2;
    past_DHW_stress = dhw_scen(tstep-1, :); %call last year's DHWs (heat stress)
    [LP1, LP2, LP3, LP4] = ADRIA_larvalprod(tstep, assistadapt, natad, past_DHW_stress, ...
        LPdhwcoeff, DHWmaxtot, LPDprm2); %larval productivity ...

    Yout(tstep, :, :) = Y0; %pos 2 is species, pos3 is sites

    % for each species, site and year as a function of past heat exposure
    recSensUE = (Y0(1, :) * TP_data) .* LP1; %larvprod of species 1;
    recSensE = (Y0(2, :) * TP_data) .* LP2; %larvprod of species 2;
    recHardUE = (Y0(3, :) * TP_data) .* LP3; %larvprod of species 3;
    recHardE = (Y0(4, :) * TP_data) .* LP4; %larvprod of species 4;
    rec(1, :) = recSensUE; %potential recruitment of species 1
    rec(2, :) = recSensE; %potential recruitment of species 2
    rec(3, :) = recHardUE; %potential recruitment of species 31
    rec(4, :) = recHardE; %potential recruitment of species 4

    %% Running the model as pulse-impulsive
    % Loop for time steps
    for tstep = 3:tf
        %TP = squeeze(TP_data(:,:,Env(tstep,sim)));
        past_DHW_stress = dhw_scen(tstep-1, :); %call last year's DHWs (heat stress)
        [LP1, LP2, LP3, LP4] = ADRIA_larvalprod(tstep, assistadapt, natad, past_DHW_stress, ...
            LPdhwcoeff, DHWmaxtot, LPDprm2); %larval productivity ...

        % for each species, site and year as a function of past heat exposure
        recSensUE = (squeeze(Yout(tstep-1, 1, :))' * TP_data) .* LP1; %larvprod of species 1;
        recSensE = (squeeze(Yout(tstep-1, 2, :))' * TP_data) .* LP2; %larvprod of species 2;
        recHardUE = (squeeze(Yout(tstep-1, 3, :))' * TP_data) .* LP3; %larvprod of species 3;
        recHardE = (squeeze(Yout(tstep-1, 4, :))' * TP_data) .* LP4; %larvprod of species 4;
        rec(1, :) = recSensUE; %potential recruitment of species 1
        rec(2, :) = recSensE; %potential recruitment of species 2
        rec(3, :) = recHardUE; %potential recruitment of species 3
        rec(4, :) = recHardE; %potential recruitment of species 4

        %% Setup MCDA before bleaching season
        % Factor 1: digraph centrality based on connectivity
        total_cover(tstep, :) = sum(coral_cover(tstep-1, :, :), 2); %sums over species, second index becomes sites

        % Factor 2:
        dam = wave_scen(tstep, :)'; %probability of coral damage from waves used as criterion in site selection

        % Factor 3:
        heatstress = dhw_scen(tstep, :)'; %heat stress used as criterion in site selection

        % Factor 4: Coral state
        total_cover_t = total_cover(tstep, :)'; %total coral cover used as criterion in site selection

        %% Update values for dMCDA
        % DCMAvars.centr = centr
        tmp_dMCDA_vars = dMCDA_vars;
        tmp_dMCDA_vars.damprob = dam;
        tmp_dMCDA_vars.heatstressprob = heatstress;
        tmp_dMCDA_vars.sumcover = total_cover_t;
        tmp_dMCDA_vars.prioritysites = prioritysites;

        %% Select preferred intervention sites based on criteria (heuristics)
        if strategy == 1 % guided
            [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(tmp_dMCDA_vars, alg_ind); % site selection function for intervention deployment
            nprefseed(tstep, 1) = nprefseedsites; % number of preferred seeding sites
            nprefshade(tstep, 1) = nprefshadesites; % number of preferred shading sites
        elseif strategy == 0 % unguided deployment
            prefseedsites = randi(nsites, [params.nsiteint, 1])'; % if unguided, then seed corals anywhere
            prefshadesites = randi(nsites, [params.nsiteint, 1])'; % if unguided, then shade corals anywhere
        end

        %% Run site loop and apply interventions before bleaching season
        for site = 1:nsites
            % Warming and disturbance event going into the pulse function
            if ismember(site, prefshadesites) == 1 && tstep <= shadeyears % if the site in the loop equals a preferred shading site
                dhw = dhw_scen(tstep, site) - srm; % then lower DHW according to SRM level
                dhw(dhw < 0) = 0; % but don't lower to negative
                Yshade(site) = srm; % log the site as shaded
                % BL(tstep,:,site,I,sims) = Yout(tstep-1,:,site)'.*(1-Sbl);
            elseif ismember(site, prefshadesites) == 0 || tstep > shadeyears %if the site in the loop is not a preferred shading site
                dhw = dhw_scen(tstep, site);
                Yshade(site) = 0; % log the site as not shaded
                % BL(tstep,:,site,I,sims) = Yout(tstep-1,:,site)'.*(1-Sbl);
            end

            % survivors from bleaching event
            Sbl = 1 - ADRIA_bleachingMortality(tstep, ecol_params, dhw)';

            % survivors from wave damage
            Sw = 1 - mwaves(tstep, :, site)';

            % those survival rates are used to adjust overall coral 
            % survival
            Yin1(:, site) = Yout(tstep-1, :, site)' .* Sbl .* Sw;

            if ismember(site, prefseedsites) == 1 && tstep <= seedyears %if the site in the loop equals a preferred seeding site
                Yin1(2, site) = Yin1(2, site) + seed1; % seed enhanced corals of group 2
                Yin1(4, site) = Yin1(4, site) + seed2; % seed enhanced corals of group 4
                Yseed(2, site) = seed1; % log site as seeded with gr2
                Yseed(4, site) = seed2; % log site as seeded with gr4
            else
                Yseed(2, site) = 0;
                Yseed(4, site) = 0;
            end

            %% Recruitment and seeding

            Yin2(:, site) = Yin1(:, site) + rec(:, site); % add new recruits: need to use min/max function to ensure cover doesn't exceed ecol_params.P
            Yin = Yin2(:, site);

            [~, Y] = ode45(@(t, X) ADRIA4groupsODE(t, X, ecol_params), [0, 1], Yin, odeset('NonNegative', 1:4));
            % ODE to solve assemblage composition after a year based on vital rates. Update of output with new population sizes from the end of the ODE run
            Yout(tstep, :, site) = Y(end, :); % update population sizes
            Yout(Yout > ecol_params.P) = ecol_params.P; % limit covers to carrying capacity (obsolete)

            % output we save for analyses. Includes: tf,nspecies,nsites,ninter,sims
            % raw results for current simulation
            coral_cover(:, :, :) = Yout(:, :, :);

            % seedsim(tstep, :, site, I, sim) = Yseed(:, site); % combine seeding logs
            % shadesim(tstep, :, site, I, sim) = Yshade(site); % combined shading logs

        end % sites
    end % tstep
    
    %% assign results
    [TC, C, E, S] = ReefConditionMetrics(coral_cover);

    % seedlog and shadelog are omitted for now
    Y = struct('TC', TC, ...
               'C', C, ...
               'E', E, ...
               'S', S);
end