function reef_condition_metrics = runADRIA(interv, crit_weights, alg_ind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% ADRIA: Adaptive Dynamic Reef Intervention Algorithm %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input:
%    interv        : struct, of intervention options
%                    (see `intervention_specification`)
%    crit_weights  : struct, criteria options
%                    (see `criteria_weights`)
%    alg_ind : int, MCDA algorithm flag
%                  - 1, Order ranking
%                  - 2, TOPSIS
%                  - 3, VIKOR
%
% Output:
%    reef_condition_metrics : struct,
%                                 - TC
%                                 - C
%                                 - E
%                                 - S
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

%% Generate table of interventions and assumptions

% The following table sets out the intervention design.
% It controls whether to seed with hardy corals of species 1 or 2 and by how much (here
% with zero or 2percent added cover), whether to shade or not and by how
% much (DHW equivalents), whether to use an informed (zero, 0) or and informed (1) strategy,
% and the risk tolerance of the decision maker.

[IT, ~] = interventionTable(interv); %calls function that builds intervention table, ...
ninter = size(IT, 1);
% which controls what interventions to run and and what levels, etc

%% Retrieve RCP scenario
% RCP 45, 60, 6085, and 85
% 6085 refers to RCP 7 RCP

RCP = interv.RCP;

%% LOAD parameter file

[params, parms0] = ADRIAparms(interv); %environmental and ecological parameter values etc

%% RUN SETUP functions

% Simulate future connectivity patterns in response to environmental variation
[TPdata, SiteRanks, strongpred, nsites] = ADRIA_TP_Moore(params.con_cutoff); % con_cutoff filters out low connectivities

% setup for the geographical setting including environmental input layers
[wavedisttime, dhwdisttime] = setupADRIAsims(interv, params, nsites);

%% Mortality projection from waves

mwaves = zeros(params.tf, params.nspecies, nsites, interv.sims);
for species = 1:4
    %including wave vulnerability of different corals here
    mwaves(:, species, :, :) = params.wavemort90(species) * wavedisttime;
end

mwaves(mwaves < 0) = 0;
mwaves(mwaves > 1) = 1;

%% Initialise and start simulations

% Allocate memory to coral cover matrix
covsim = zeros(params.tf, params.nspecies, nsites, ninter, interv.sims); %main metric: coral cover
% BL = zeros(params.tf,params.nspecies,nsites,ninter,interv.sims); %coral bleaching
% seedlog = zeros(params.tf,params.nsiteint,ninter,sims); %initialise coral seeding log
% shadelog = zeros(params.tf,params.nsiteint,ninter,sims); %initialise coral shading log
seedsim = zeros(params.tf, params.nspecies, nsites, ninter, interv.sims);
shadesim = zeros(params.tf, params.nspecies, nsites, ninter, interv.sims);

%% Run simulations

% parfor doesn't like when it contains loops bound by constants and variables
% passed fromcother scripts, so we need to redefine them here.
% There's better ways to fix this but this is a temporary quick fix.
params = params;
wavedisttime = wavedisttime;
nsites = nsites;
TPdata = TPdata;
SiteRanks = SiteRanks;
tf = params.tf;
dhwdisttime = dhwdisttime;
strongpred = strongpred;

%% Weights for connectivity , waves (ww), high cover (whc) and low
wtwaves = crit_weights(:, 1); % weight of wave damage in MCDA
wtheat = crit_weights(:, 2); % weight of heat damage in MCDA
wtconshade = crit_weights(:, 3); % weight of connectivity for shading in MCDA
wtconseed = crit_weights(:, 4); % weight of connectivity for seeding in MCDA
wthicover = crit_weights(:, 5); % weight of high coral cover in MCDA (high cover gives preference for seeding corals but high for SRM)
wtlocover = crit_weights(:, 6); % weight of low coral cover in MCDA (low cover gives preference for seeding corals but high for SRM)
wtpredecseed = crit_weights(:, 7); % weight for the importance of seeding sites that are predecessors of priority reefs
wtpredecshade = crit_weights(:, 8); % weight for the importance of shading sites that are predecessors of priority reefs
risktol = crit_weights(:, 9); % risk tolerance

%% Set up structure for dMCDA
dMCDA_vars = struct('nsites', nsites, 'nsiteint', params.nsiteint, 'prioritysites', [], ...
    'strongpred', strongpred, 'centr', SiteRanks.C1, 'damprob', 0, 'heatstressprob', 0, ...
    'sumcover', 0, 'risktol', risktol, 'wtconseed', wtconseed, 'wtconshade', wtconshade, ...
    'wtwaves', wtwaves, 'wtheat', wtheat, 'wthicover', wthicover, 'wtlocover', wtlocover, 'wtpredecseed', wtpredecseed, 'wtpredecshade', wtpredecshade);

% loop though number of simulations for each intervention including the counterfactual
for sim = 1:interv.sims

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PREPARE for and start INTERVENTIONS
    % CORAL SEEDING and SUBSTRATE AVAILABILITY.
    % Which site is to be seeded with corals is a function of coral cover -
    % nominally sites with low coral cover and/or low substrate availability
    % are given preference. SHADING. Sites with high coral cover and highly
    % connected sites are given preference.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % container for coral cover and total coral cover
    Cov = zeros(params.tf, params.nspecies, nsites, ninter);
    % dCovTot = zeros(nsites, ninter);

    % containers for seeding, shading and cooling
    nprefseed = zeros(params.tf, ninter);
    nprefshade = zeros(params.tf, ninter);
    % nprefcool = zeros(params.tf, ninter);
    
    prefseedsites = []; %set the list of preferred seeding sites to empty
    prefshadesites = []; %set the list of preferred shading sites to empty
    prioritysites = []; %set the list of priority sites to empty
    % coralsdeployed = zeros(params.tf,ninter); % = params.nsiteint*seedcorals*nnz(nprefsite);


    %% Interventions and assumptions

    % loop through each permutation of interventions selected
    for I = 1:ninter

        parms = parms0;
        strategy = IT(I, 1); %0 is random, 1 is guided
        pgs = IT(I, 2); % group of priority sites
        seed1 = IT(I, 3); %species seeded - here the sensitive Acropora
        seed2 = IT(I, 4); %species seeded - here the hardier other coral
        srm = IT(I, 5); %DHW equivalents reduced by fogging or some other shading mechanism
        parms.assistadapt(2) = IT(I, 6); % level of assisted coral adaptation is column 6 in the intervention table
        parms.natad = parms.natad + IT(I, 7); %level of added natural coral adaptation is column 7 in the intervention table
        seedyears = IT(I, 8); %years to shade are in column 8
        shadeyears = IT(I, 9); %years to shade are in column 9

        if pgs == 1
            prioritysites = params.psgA; %see ADRIAparms for list of sites in group
        elseif pgs == 2
            prioritysites = params.psgB; %see ADRIAparms for list of sites in group
        elseif pgs == 3
            prioritysites = params.psgC; %see ADRIAparms for list of sites in group
        end

        %% Initialise before each projection

        Yin1 = zeros(params.nspecies, nsites);
        Yin2 = zeros(params.nspecies, nsites);
        Yseed = zeros(params.nspecies, nsites);
        Yshade = zeros(1, nsites);
        CovTot = zeros(params.tf, nsites);
        Y0 = zeros(params.nspecies, nsites); %coral start cover before each intervention
        Y0(1, :) = params.basecov1; %sensitive unenhanced corals set to their basecover
        Y0(2, :) = params.basecov2; %sensitive enhanced corals set to their basecover
        Y0(3, :) = params.basecov3; %naturally hardy corals set to their basecover
        Y0(4, :) = params.basecov4; %enhanced naturally hardy corals set to their basecover

        %% Running the model as pulse-impulsive

        Yout = zeros(params.tf, params.nspecies, nsites); % matrix in which to store the output: first branching corals, then foliose corals, then macroalgae
        Yout(1, :, :) = Y0; % Set initial population sizes at tstep = 1
        %Yout(tstep,:,:) = Y0; %pos 2 is species, pos3 is sites
        rec = zeros(params.nspecies, nsites); %recruitment

        %% Loop for time steps
        for tstep = 2:tf %tf is time final
            %TP = squeeze(TPdata(:,:,Env(tstep,sim)));
            past_DHW_stress = dhwdisttime(tstep-1, :, sim); %call last year's DHWs (heat stress)
            [LP1, LP2, LP3, LP4] = ADRIA_larvalprod(tstep, parms.assistadapt, parms.natad, past_DHW_stress, ...
                params.LPdhwcoeff, params.DHWmaxtot, params.LPDprm2); %larval productivity ...

            % for each species, site and year as a function of past heat exposure
            if tstep == 2
                Yout(tstep, :, :) = Y0; %pos 2 is species, pos3 is sites
                recSensUE = (Y0(1, :) * TPdata) .* LP1; %larvprod of species 1;
                recSensE = (Y0(2, :) * TPdata) .* LP2; %larvprod of species 2;
                recHardUE = (Y0(3, :) * TPdata) .* LP3; %larvprod of species 3;
                recHardE = (Y0(4, :) * TPdata) .* LP4; %larvprod of species 4;
                rec(1, :) = recSensUE; %potential recruitment of species 1
                rec(2, :) = recSensE; %potential recruitment of species 2
                rec(3, :) = recHardUE; %potential recruitment of species 31
                rec(4, :) = recHardE; %potential recruitment of species 4
            else
                recSensUE = (squeeze(Yout(tstep-1, 1, :))' * TPdata) .* LP1; %larvprod of species 1;
                recSensE = (squeeze(Yout(tstep-1, 2, :))' * TPdata) .* LP2; %larvprod of species 2;
                recHardUE = (squeeze(Yout(tstep-1, 3, :))' * TPdata) .* LP3; %larvprod of species 3;
                recHardE = (squeeze(Yout(tstep-1, 4, :))' * TPdata) .* LP4; %larvprod of species 4;
                rec(1, :) = recSensUE; %potential recruitment of species 1
                rec(2, :) = recSensE; %potential recruitment of species 2
                rec(3, :) = recHardUE; %potential recruitment of species 3
                rec(4, :) = recHardE; %potential recruitment of species 4
            end

            %% Setup MCDA before bleaching season
            % Factor 1: digraph centrality based on connectivity
            CovTot(tstep, :) = sum(Cov(tstep-1, :, :, I), 2); %sums over species, second index becomes sites

            % Factor 2:
            dam = wavedisttime(tstep, :, sim)'; %probability of coral damage from waves used as criterion in site selection

            % Factor 3:
            heatstress = dhwdisttime(tstep, :, sim)'; %heat stress used as criterion in site selection

            % Factor 4: Coral state
            covtott = CovTot(tstep, :)'; %total coral cover used as criterion in site selection
            
            %% Update values for dMCDA
            % DCMAvars.centr = centr
            tmp_dMCDA_vars = dMCDA_vars;
            tmp_dMCDA_vars.damprob = dam;
            tmp_dMCDA_vars.heatstressprob = heatstress;
            tmp_dMCDA_vars.sumcover = covtott;
            tmp_dMCDA_vars.prioritysites = prioritysites;

            %% Select preferred intervention sites based on criteria (heuristics)
            if strategy == 1 % guided
                [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites] = ADRIA_DMCDA(tmp_dMCDA_vars, alg_ind); % site selection function for intervention deployment
                nprefseed(tstep, I) = nprefseedsites; % number of preferred seeding sites
                nprefshade(tstep, I) = nprefshadesites; % number of preferred shading sites
            elseif strategy == 0 % unguided deployment
                prefseedsites = randi(nsites, [params.nsiteint, 1])'; % if unguided, then seed corals anywhere
                prefshadesites = randi(nsites, [params.nsiteint, 1])'; % if unguided, then shade corals anywhere
            end

            %% Run site loop and apply interventions before bleaching season
            for site = 1:nsites
                % Warming and disturbance event going into the pulse function
                if ismember(site, prefshadesites) == 1 && tstep <= shadeyears % if the site in the loop equals a preferred shading site
                    dhw = dhwdisttime(tstep, site, sim) - srm; % then lower DHW according to SRM level
                    dhw(dhw < 0) = 0; % but don't lower to negative
                    Sbl = 1 - ADRIA_bleachingmortalityfun(tstep, parms, dhw)'; %survivors from bleaching event
                    Sw = 1 - mwaves(tstep, :, site, sim)'; % survivors from wave damage
                    Yin1(:, site) = Yout(tstep-1, :, site)' .* Sbl .* Sw; % those survival rates are used to adjust overall coral survival
                    Yshade(site) = srm; % log the site as shaded
                    % BL(tstep,:,site,I,sims) = Yout(tstep-1,:,site)'.*(1-Sbl);
                elseif ismember(site, prefshadesites) == 0 || tstep > shadeyears %if the site in the loop is not a preferred shading site
                    dhw = dhwdisttime(tstep, site, sim);
                    Sbl = 1 - ADRIA_bleachingmortalityfun(tstep, parms, dhw)';
                    Sw = 1 - mwaves(tstep, :, site, sim)';
                    Yin1(:, site) = Yout(tstep-1, :, site)' .* Sbl .* Sw;
                    Yshade(site) = 0; % log the site as not shaded
                    % BL(tstep,:,site,I,sims) = Yout(tstep-1,:,site)'.*(1-Sbl);
                end

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

                Yin2(:, site) = Yin1(:, site) + rec(:, site); % add new recruits: need to use min/max function to ensure cover doesn't exceed parms.P
                Yin = Yin2(:, site);

                [~, Y] = ode45(@(t, X) ADRIA4groupsODE(t, X, parms), [0, 1], Yin, odeset('NonNegative', 1:4));
                % ODE to solve assemblage composition after a year based on vital rates. Update of output with new population sizes from the end of the ODE run
                Yout(tstep, :, site) = Y(end, :); % update population sizes
                Yout(Yout > parms.P) = parms.P; % limit covers to carrying capacity (obsolete)

                Cov(:, :, :, I) = Yout(:, :, :);
                covsim(:, :, :, I, sim) = Yout(:, :, :); % output we save for analyses. Includes: tf,nspecies,nsites,ninter,sims
                seedsim(tstep, :, site, I, sim) = Yseed(:, site); % combine seeding logs
                shadesim(tstep, :, site, I, sim) = Yshade(site); % combined shading logs

            end % sites
        end % tstep
    end % Interventions
end % sims

%% Convert to key coral metrics

% calls function that converts raw coral covers to ...
% total cover (TC), covers of the three goups (C), evenness (E), and structural complexity (S).
% Note that S needs work: needs to be expressed as a function of coral group
% and size-frequency distribution.
[TC, C, E, S] = ReefConditionMetrics(covsim);

% seedlog and shadelog are omitted for now
reef_condition_metrics = struct('TC', TC, ...
                                'C', C, ...
                                'E', E, ...
                                'S', S);


end
