function [prefseedsites, prefshadesites, nprefseedsites, nprefshadesites, rankings]  = ADRIA_DMCDA(DMCDA_vars, alg_ind,sslog,prefseedsites,prefshadesites,rankingsin)
%    Utility function that uses a dynamic MCDA to work out what sites to pick,
%    if any before going into the bleaching or cyclone season. It uses
%    disturbance probabilities for the season (distprobyr, a vector)) and
%     centrality of season (central, a vector) to produce a site ranking table
%
%     Inputs:
%         DMCDAvars : a structure of the form struct('nsites', [], 'nsiteint', [], ... 'strongpred', [], 'centr', [], 'damprob', [], 'heatstressprob', [], ... 'prioritysites', [], 'sumcover', [], 'risktol', [], 'wtconseed', [], ... 'wtconshade', [],'wtwaves', [], 'wtheat', [], 'wthicover', [], ... 'wtlocover', [], 'wtpredecseed', [], 'wtpredecshade', []); where []'s are dynamically updated in runADRIA.m
%
%         - site_ids : IDs of sites to consider
%         - nsiteint : number of sites to select for priority interventions
%         - strongpred : strongest predecessor sites (calculated in siteConnectivity())
%         - centr : site centrality (calculated in siteConnectivity())
%         - damprob : probability of coral wave damage for each site
%         - heatstressprob : probability of heat stress for each site
%         - prioritysites : list of sites in group (i.e. prsites: 1,2,3)
%         - sumcover : total coral cover
%         - risktol : risk tolerance (input by user from criteriaDetails)
%         - wtconseed : weight of connectivity for seeding
%         - wtconshade : weight of connectivity for shading
%         - wtwaves : weight of wave damage
%         - wtheat : weight of heat risk
%         - wthicover : weight of high coral cover
%         - wtlocover : weight of low coral cover
%         - wtpredecseed : weight for seeding predecessors of priority reefs
%         - wtpredecshade : weight for shading predecessors of priority reefs
%
%         alg_ind : an integer indicating the algorithm to be used for the multi-criteria anlysis
%                   (1: order-ranking, 2: TOPSIS, 3: VIKOR, 4: multi-obj ranking
%
%       Outputs :
%               prefseedsites : site IDs to seed at
%               prefshadesites : sites IDs to shade at
%               nprefseedsites : number of preferred seeding sites
%               nprefshadesites : number of preferred shading sites

    % Filter out sites that are not to be considered, based on site_id
    % NOTE: Assumes everything lines up! (which they should)
    site_ids = DMCDA_vars.site_ids;
    nsites = length(site_ids);
    nsiteint = DMCDA_vars.nsiteint;
    prioritysites = DMCDA_vars.prioritysites(ismember(DMCDA_vars.prioritysites,site_ids));
    strongpred = DMCDA_vars.strongpred(site_ids, :);
    centr = DMCDA_vars.centr(site_ids);
    damprob = DMCDA_vars.damprob(site_ids);
    heatstressprob = DMCDA_vars.heatstressprob(site_ids);
    sumcover = DMCDA_vars.sumcover(site_ids);
    maxcover = DMCDA_vars.maxcover(site_ids);
    area = DMCDA_vars.area(site_ids);
    risktol = DMCDA_vars.risktol;
    wtconseed = DMCDA_vars.wtconseed;
    wtconshade = DMCDA_vars.wtconshade;
    wtwaves = DMCDA_vars.wtwaves;
    wtheat = DMCDA_vars.wtheat;
    wthicover = DMCDA_vars.wthicover;
    wtlocover = DMCDA_vars.wtlocover;
    wtpredecseed = DMCDA_vars.wtpredecseed;
    wtpredecshade = DMCDA_vars.wtpredecshade;

    % site_id, seeding rank, shading rank
    rankings = [site_ids, zeros(nsites, 1), zeros(nsites, 1)];

    % Filter out sites

    %% Identify and assign key larval source sites for priority sites
    predec = zeros(nsites, 3);
    predec(:, 1:2) = strongpred;
    predprior = predec(ismember(predec(:,1),prioritysites'), 2);
    predprior(isnan(predprior)) = [];
    predec(predprior, 3) = 1;

    %% prefseedsites
    % Combine data into matrix
    A(:, 1) = site_ids; %site IDs

    % Account for cases where no coral cover
    c_cov_area = centr .* sumcover .* area
    if max(c_cov_area) ~= 0
        % node connectivity centrality, need to instead work out strongest
        % predecessors to priority sites
        A(:, 2) = c_cov_area / max(c_cov_area);
    else
        A(:, 2) = c_cov_area;
    end

    % Account for cases where no chance of damage or heat stress
    if max(damprob) ~= 0
        % damage probability from wave exposure
        A(:, 3) = damprob / max(damprob);
    else
        A(:, 3) = damprob;
    end

    if max(heatstressprob) ~= 0
        % risk from heat exposure
        A(:, 4) = heatstressprob / max(heatstressprob);
    else
        A(:, 4) = heatstressprob;
    end

    A(:, 5) = predec(:, 3); % priority predecessors

    A(:, 6) = (maxcover - sumcover) ./ maxcover; % proportion of cover compared to max possible cover

    % set any infs to zero
    A(maxcover==0, 6) = 0;

    % Filter out sites that have high risk of wave damage, specifically
    % exceeding the risk tolerance
    A(A(:, 3) > risktol, 3) = nan;
    rule = (A(:, 3) <= risktol) & (A(:, 4) > risktol);
    A(rule, 4) = nan;

    A(any(isnan(A), 2), :) = []; %if a row has a nan, delete it

    if isempty(A)
        prefseedsites = 0; %if all rows have nans and A is empty, abort mission
        nprefseedsites = 0;
        prefshadesites = 0;
        nprefshadesites = 0;
        return
    end

    %number of sites left after risk filtration
    if nsiteint > length(A(:, 1))
        nsiteint = length(A(:, 1));
    end

    %% Seeding - Filtered set
    % define seeding weights
    if sslog.seed
        wse = [1, wtconseed, wtwaves, wtheat, wtpredecseed, wtlocover];
        wse(2:end) = wse(2:end) ./ sqrt(sum(wse(2:end).^2));
        % define seeding decision matrix
        SE(:, 1) = A(:, 1); % sites column (remaining)
        SE(:, 2) = A(:, 2); % centrality
        SE(:, 3) = (1 - A(:, 3)); % complementary of damage risk
        SE(:, 4) = (1 - A(:, 4)); % complimetary of wave risk
        SE(:, 5) = A(:, 5); % priority predecessors
        SE(:, 6) = A(:, 6); % coral real estate relative to max capacity
        SE(A(:, 6) <= 0, :) = []; % remove sites at maximum carrying capacity
    end

    if sslog.shade
        %% Shading filtered set
        % define shading weights
        wsh = [1, wtconshade, wtwaves, wtheat, wtpredecshade, wthicover];
        wsh(2:end) = wsh(2:end) ./ sqrt(sum(wsh(2:end).^2));
        SH(:, 1) = A(:, 1); % sites column (remaining)
        SH(:, 2) = A(:, 2); % absolute centrality
        SH(:, 3) = (1 - A(:, 3)); % complimentary of wave damage risk
        SH(:, 4) = A(:, 4); % complimentary of heat damage risk
        SH(:, 5) = A(:, 5); % priority predecessors
        SH(:, 6) = (1 - A(:, 6)); % coral cover relative to max capacity
    end

    switch alg_ind
        case 1
            %% Order ranking
            % seeding rankings
            if sslog.seed
                if isempty(SE)
                    prefseedsites = 0; %if all rows have nans and A is empty, abort mission
                    nprefseedsites = 0;
                else
                    wse(all(SE == 0, 1)) = [];
                    SE(:, all(SE == 0, 1)) = []; %if a column is all zeros, delete

                    % normalisation
                    SE(:, 2:end) = SE(:, 2:end) ./ sqrt(sum(SE(:, 2:end).^2));
                    SE = SE .* repmat(wse, size(SE, 1), 1);

                    % simple ranking - add criteria weighted values for each sites
                    seed_order(:, 1) = SE(:, 1);
                    seed_order(:, 2) = sum(SE(:, 2:end), 2);
                    seed_order = sortrows(seed_order, 2, 'descend'); %sort from highest to lowest indicator

                    % Add ranking column
                    seed_order(:, 3) = 1:length(seed_order(:, 1));

                    last_idx = min(nsiteint, height(seed_order));

                    %highest indicator picks the seed site
                    prefseedsites = seed_order(1:last_idx, 1);
                    nprefseedsites = numel(prefseedsites);
                end
            elseif ~sslog.seed
                % reassign as input if not updated so matlab has output
                prefseedsites = prefseedsites;
                nprefseedsites = numel(prefseedsites);
            end

            if sslog.shade
                % shading rankings
                wsh(all(SH == 0, 1)) = [];
                SH(:, all(SH == 0, 1)) = []; %if a column is all zeros, delete
                % normalisation
                SH(:, 2:end) = SH(:, 2:end) ./ sqrt(sum(SH(:, 2:end).^2));
                SH = SH .* repmat(wsh, size(SH, 1), 1);

                SHwt(:, 1) = SH(:, 1);
                SHwt(:, 2) = sum(SH(:, 2:end), 2); %for now, simply add indicators

                shade_order = sortrows(SHwt, 2, 'descend'); %sort from highest to lowest indicator

                last_idx = min(nsiteint, height(shade_order));

                %highest indicators picks the cool sites
                prefshadesites = shade_order(1:last_idx, 1);
                nprefshadesites = numel(prefshadesites);
                % reassign as input if not updated so matlab has output
            elseif ~sslog.shade
                prefshadesites = prefshadesites;
                nprefshadesites = numel(prefshadesites);
            end
        case 2

            %% TOPSIS
            if sslog.seed
                % seeding rankings
                if isempty(SE)
                    prefseedsites = 0; %if all rows have nans and A is empty, abort mission
                    nprefseedsites = 0;
                else
                    wse(all(SE == 0, 1)) = [];
                    SE(:, all(SE == 0, 1)) = []; %if a column is all zeros, delete
                    % normalisation
                    SE(:, 2:end) = SE(:, 2:end) ./ sqrt(sum(SE(:, 2:end).^2));
                    SE = SE .* repmat(wse, size(SE, 1), 1);
                    % compute the set of positive ideal solutions for each criteria (max for
                    % good crieteria, min for bad criteria). Max used as all crieteria
                    % represent preferred attributes not costs or negative attributes

                    PIS = max(SE(:, 2:end));

                    % compute the set of negative ideal solutions for each criteria
                    % (min for good criteria, max for bad criteria).
                    % Min used as all criteria represent preferred attributes not
                    % costs or negative attributes

                    NIS = min(SE(:, 2:end));

                    % calculate separation distance from the ideal and non-ideal solns
                    S_p = sqrt(sum((SE(:, 2:end) - PIS).^2, 2));
                    S_n = sqrt(sum((SE(:, 2:end) - NIS).^2, 2));

                    % final ranking measure of relative closeness C
                    C = S_n ./ (S_p + S_n);
                    SEwt = [SE(:, 1), C];
                    seed_order = sortrows(SEwt, 2, 'descend');

                    last_idx = min(nsiteint, height(seed_order));

                    prefseedsites = seed_order(1:last_idx, 1);
                    nprefseedsites = numel(prefseedsites);

                end
                % reassign as input if not updated so matlab has output
            elseif ~sslog.seed
                prefseedsites = prefseedsites;
                nprefseedsites = numel(prefseedsites);
            end

            if sslog.shade
                % shading rankings
                wsh(all(SH == 0, 1)) = [];
                SH(:, all(SH == 0, 1)) = []; %if a column is all zeros, delete

                % normalisation

                SH(:, 2:end) = SH(:, 2:end) ./ sqrt(sum(SH(:, 2:end).^2));
                SH = SH .* repmat(wsh, size(SH, 1), 1);

                % compute the set of positive ideal solutions for each criteria (max for
                % good crieteria, min for bad criteria). Max used as all crieteria
                % represent preferred attributes not costs or negative attributes
                PIS = max(SH(:, 2:end));

                % compute the set of negative ideal solutions for each criteria (min for
                % good crieteria, max for bad criteria). Min used as all crieteria
                % represent preferred attributes not costs or negative attributes
                NIS = min(SH(:, 2:end));

                % calculate separation distance from the ideal and non-ideal solns
                S_p = sqrt(sum((SH(:, 2:end) - PIS).^2, 2));
                S_n = sqrt(sum((SH(:, 2:end) - NIS).^2, 2));

                % final ranking measue of relative closeness C
                C = S_n ./ (S_p + S_n);
                SHwt = [SH(:, 1), C];
                shade_order = sortrows(SHwt, 2, 'descend');

                %highest indicators picks the cool sites
                last_idx = min(nsiteint, height(shade_order));
                prefshadesites = shade_order(1:last_idx, 1);
                nprefshadesites = numel(prefshadesites);
            elseif ~sslog.shade
                % reassign as input if not updated so matlab has output
                prefshadesites = prefshadesites;
                nprefshadesites = numel(prefshadesites);
            end

        case 3
            %% VIKOR
            % level of compromise (utility vs. regret). v = 0.5 is consensus, v<0.5
            % is minimal regret, v>0.5 is max group utility (majority rules)
            v = 0.5;
            if sslog.seed
                % seeding rankings
                if isempty(SE)
                    prefseedsites = 0; %if all rows have nans and A is empty, abort mission
                    nprefseedsites = 0;
                else
                    wse(all(SE == 0, 1)) = [];
                    SE(:, all(SE == 0, 1)) = []; %if a column is all zeros, delete
                    % normalisation
                    SE(:, 2:end) = SE(:, 2:end) ./ sqrt(sum(SE(:, 2:end).^2));
                    SE = SE .* repmat(wse, size(SE, 1), 1);

                    F_s = max(SE(:, 2:end));

                    % Compute utility of the majority S (Manhatten Distance)
                    % Compute individual regret R (Chebyshev distance)
                    sr_arg = ((F_s - SE(:, 2:end)));
                    S = sum(sr_arg, 2);
                    S = [SE(:, 1), S];
                    R = max(sr_arg, [], 2);
                    R = [SE(:, 1), R];

                    % Compute the VIKOR compromise Q
                    S_s = max(S(:, 2));
                    S_h = min(S(:, 2));
                    R_s = max(R(:, 2));
                    R_h = min(R(:, 2));
                    Q = v * (S(:, 2) - S_h) / (S_s - S_h) + (1 - v) * (R(:, 2) - R_h) / (R_s - R_h);
                    Q = [SE(:, 1), Q];

                    % sort Q in ascending order rows
                    seed_order = sortrows(Q, 2, 'ascend');

                    last_idx = min(nsiteint, height(seed_order));

                    prefseedsites = seed_order(1:last_idx, 1);
                    nprefseedsites = numel(prefseedsites);
                end
                % reassign as input if not updated so matlab has output
            elseif ~sslog.seed
                prefseedsites = prefseedsites;
                nprefseedsites = numel(prefseedsites);
            end

            if sslog.shade
                wsh(all(SH == 0, 1)) = [];
                SH(:, all(SH == 0, 1)) = []; %if a column is all zeros, delete
                % shading rankings
                % normalisation
                SH(:, 2:end) = SH(:, 2:end) ./ sqrt(sum(SH(:, 2:end).^2));
                SH = SH .* repmat(wsh, size(SH, 1), 1);

                F_s = max(SH(:, 2:end));

                % Compute utility of the majority S (Manhatten Distance)
                % Compute individual regret R (Chebyshev distance)
                sr_arg = ((F_s - SH(:, 2:end)));
                S = sum(sr_arg, 2);
                S = [SH(:, 1), S];
                R = max(sr_arg, [], 2);
                R = [SH(:, 1), R];

                % Compute the VIKOR compromise Q
                S_s = max(S(:, 2));
                S_h = min(S(:, 2));
                R_s = max(R(:, 2));
                R_h = min(R(:, 2));
                Q = v * (S(:, 2) - S_h) / (S_s - S_h) + (1 - v) * (R(:, 2) - R_h) / (R_s - R_h);
                Q = [SH(:, 1), Q];

                % sort R, S and Q in ascending order rows
                shade_order = sortrows(Q, 2, 'ascend');

                last_idx = min(nsiteint, height(shade_order));
                prefshadesites = shade_order(1:last_idx, 1);
                nprefshadesites = numel(prefshadesites);
            elseif ~sslog.shade
                % reassign as input if not updated so matlab has output
                prefshadesites = prefshadesites;
                nprefshadesites = numel(prefshadesites);
            end
        case 4

            %% Multi-objective GA algorithm weighting
            % set up optimisation problem
            % no inequality constraints
            Aeq = [];
            beq = [];

            opts = optimoptions('gamultiobj', 'UseParallel', false, 'Display', 'off');
            if sslog.seed
                % seeding rankings
                if isempty(SE)
                    prefseedsites = 0; %if all rows have nans and A is empty, abort mission
                    nprefseedsites = 0;
                else
                    wse(all(SE == 0, 1)) = [];
                    SE(:, all(SE == 0, 1)) = []; %if a column is all zeros, delete

                    % integer weights must sum to number of preferred sites
                    A = ones(1, length(SE(:, 1)));
                    b = nsiteint;

                    % integer variables
                    intcon = 1:length(SE(:, 1));

                    % normalisation
                    SE(:, 2:end) = SE(:, 2:end) ./ sqrt(sum(SE(:, 2:end).^2));
                    SE = SE .* repmat(wse, size(SE, 1), 1);

                    % multi-objective function for seeding
                    fun1 = @(x) -1 * ADRIA_siteobj(x, SE(:, 2:end));

                    % solve multi-objective problem using genetic alg
                    lb = zeros(1, length(SE(:, 1))); % x (weightings) can be 0
                    ub = ones(1, length(SE(:, 1))); % to 1
                    x1 = gamultiobj(fun1, length(SE(:, 1)), Aeq, beq, A, b, lb, ub, [], intcon, opts);

                    % randomly select solution from pareto front
                    ind = randi([1, size(x1, 1)]);

                    % select optimal sites
                    prefseedsites = site_ids(logical(x1(ind, :)));
                    nprefseedsites = numel(prefseedsites);

                    seed_order = repmat(prefseedsites, 1, 2);
                end
            elseif ~sslog.seed
                % reassign as input if not updated so matlab has output
                prefseedsites = prefseedsites;
                nprefseedsites = numel(prefseedsites);
            end

            if sslog.shade
                % shading rankings
                wsh(all(SH == 0, 1)) = [];
                SH(:, all(SH == 0, 1)) = []; %if a column is all zeros, delete
                % integer weights must sum to number of preferred sites
                A = ones(1, length(SH(:, 1)));
                b = nsiteint;

                % integer variables
                intcon = 1:length(SH(:, 1));

                % normalisation

                SH(:, 2:end) = SH(:, 2:end) ./ sqrt(sum(SH(:, 2:end).^2));
                SH = SH .* repmat(wsh, size(SH, 1), 1);

                lb = zeros(1, length(SH(:, 1))); % x (weightings) can be 0
                ub = ones(1, length(SH(:, 1))); % to 1

                % multi-objective function for shading
                fun2 = @(x) -1 * ADRIA_siteobj(x, SH(:, 2:end));

                % solve multi-objective problem using genetic alg
                x2 = gamultiobj(fun2, length(SH(:, 1)), Aeq, beq, A, b, lb, ub, [], intcon, opts);

                % randomly select solution from pareto front
                ind = randi([1, size(x2, 1)]);

                % select optimal sites
                prefshadesites = site_ids(logical(x2(ind, :)));
                nprefshadesites = numel(prefshadesites);

                shade_order = repmat(prefshadesites, 1, 2);
            elseif ~sslog.shade
                % reassign as input if not updated so matlab has output
                prefshadesites = prefshadesites;
                nprefshadesites = numel(prefshadesites);
            end

    otherwise
            error("Unknown MCDA algorithm choice.")
    end

    % Add ranking column
    if exist('seed_order', 'var')
        seed_order(:, 3) = 1:length(seed_order(:, 1));

        % Match by site_id and assign rankings to log
        [~,ii] = ismember(seed_order(:,1), rankings(:,1), "rows");
        align = ii(ii ~= 0);

        rankings(align, 2) = seed_order(:, 3);
    end

    % Same as above, for shade
    if exist('shade_order','var')
        shade_order(:, 3) = 1:length(shade_order(:, 1));
        [~,ii] = ismember(shade_order(:,1), rankings(:,1), "rows");
        align = ii(ii ~= 0);
        rankings(align, 3) = shade_order(:, 3);
    end

    % Replace with input rankings if seeding or shading rankings have not been filled
    if (sum(rankings(:,2)) == 0) && (nprefseedsites~=0)
        rankings(:,2) = rankingsin(:,2);
        nprefseedsites = numel(prefseedsites);
    end

    if (sum(rankings(:,3)) == 0) && (nprefshadesites~=0)
        rankings(:,3) = rankingsin(:,3);
        nprefshadesites = numel(prefshadesites);
    end
end
