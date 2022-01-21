function [prefseedsites,prefshadesites,nprefseedsites,nprefshadesites] = ADRIA_DMCDA(DCMAvars,alg_ind)

%    Utility function that uses a dynamic MCDA to work out what sites to pick, 
%    if any before going into the bleaching or cyclone season. It uses
%    disturbance probabilities for the season (distprobyr, a vector)) and
%     centrality of season (central, a vector) to produce a site ranking table
%
%     Inputs: 
%         DMCDAvars : a structure of the form struct('nsites', [], 'nsiteint', [], ... 'strongpred', [], 'centr', [], 'damprob', [], 'heatstressprob', [], ... 'prioritysites', [], 'sumcover', [], 'risktol', [], 'wtconseed', [], ... 'wtconshade', [],'wtwaves', [], 'wtheat', [], 'wthicover', [], ... 'wtlocover', [], 'wtpredecseed', [], 'wtpredecshade', []); where []'s are dynamically updated in runADRIA.m
% 
%         - nsites : total number of sites
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
%               nprefshadesites : number of preferredf shading sites

    nsites = DCMAvars.nsites;
    nsiteint = DCMAvars.nsiteint;
    prioritysites = DCMAvars.prioritysites;
    strongpred  = DCMAvars.strongpred;
    centr  = DCMAvars.centr;
    damprob  = DCMAvars.damprob;
    heatstressprob  = DCMAvars.heatstressprob;
    sumcover  = DCMAvars.sumcover;
    maxcover = DCMAvars.maxcover;
    risktol  = DCMAvars.risktol;
    wtconseed  = DCMAvars.wtconseed;
    wtconshade  = DCMAvars.wtconshade;
    wtwaves  = DCMAvars.wtwaves;
    wtheat  = DCMAvars.wtheat;
    wthicover  = DCMAvars.wthicover;
    wtlocover  = DCMAvars.wtlocover;
    wtpredecseed  = DCMAvars.wtpredecseed;
    wtpredecshade  = DCMAvars.wtpredecshade;

    %% Identify and assign key larval source sites for priority sites
    sites = 1:nsites;
    predec = zeros(nsites,3);
    predec(:,1:2) = strongpred;
    predprior = predec(prioritysites,2);
    predec(predprior,3) = 1;

    %% prefseedsites
    % Combine data into matrix
    A(:,1) = sites; %site IDs
    A(:,2) = centr/max(centr); %node connectivity centrality, need to instead work out strongest predecessors to priority sites  
    A(:,3) = damprob/max(damprob); %damage probability from wave exposure
    A(:,4) = heatstressprob/max(heatstressprob); %risk from heat exposure
    
    prop_cover = sumcover/max(sumcover);  %proportional coral cover
    A(:,5) = prop_cover; 
    A(:,6) = 1 - prop_cover;
    A(:,7) = predec(:,3); % priority predecessors
    A(:,8) = (maxcover - sumcover)/maxcover; % proportion of cover compared to max possible cover
    
    % Filter out sites that have high risk of wave damage, specifically 
    % exceeding the risk tolerance 
    A(A(:, 3) > risktol, 3) = nan;
    rule = (A(:, 3) <= risktol) & (A(:, 4) > risktol);   
    A(rule, 4) = nan;
    
    A(any(isnan(A),2),:) = []; %if a row has a nan, delete it
    
    if isempty(A)
        prefseedsites = 0;  %if all rows have nans and A is empty, abort mission
        nprefseedsites = 0;
        prefshadesites = 0;
        nprefshadesites = 0;
        return
    end
   
    %number of sites left after risk filtration
    if nsiteint > length(A(:,1))
        nsiteint = length(A(:,1));
    end
    %% Seeding - Filtered set 
    % define seeding weights
    wse = [1, wtconseed, wtwaves, wtheat, wtlocover, wtpredecseed, wtlocover];
    wse(2:end) = wse(2:end)./sum(wse(2:end));
    % define seeding decision matrix
    SE(:,1) = A(:,1); % sites column (remaining)
    SE(:,2) = A(:,2); % multiply centrality with connectivity weight
    SE(:,3) = (1-A(:,3)); % multiply complementary of damage risk with disturbance weight
    SE(:,4) = (1-A(:,4)); % complimetary of wave risk
    SE(:,5) = A(:,6);  %multiply by coral cover with its weight for high cover
    SE(:,6) = A(:,7); % multiply priority predecessor indicator by weight
    %SE(find(A(:,5)>=1),:) = [];
    SE(:,7) = A(:,8); % proportion of max cover which is not covered
    SE(find(A(:,8)<=0),:) = []; % remove sites at maximum carrying capacity
   
    
    %% Shading filtered set
    % define shading weights
    wsh = [1, wtconshade, wtwaves, wtheat, wthicover, wtpredecshade,wthicover];
    wsh(2:end) = wsh(2:end)./sum(wsh(2:end));
    SH(:,1) = A(:,1); % sites column (remaining)
    SH(:,2) = A(:,2); % multiply centrality with connectivity weight
    SH(:,3) = (1-A(:,3)); % multiply complementary of damage risk with disturbance weight
    SH(:,4) = A(:,4); % multiply complementary of heat risk with heat weight
    SH(:,5) = A(:,5); % multiply by coral cover with its weight for high cover
    SH(:,6) = A(:,7); % multiply priority predecessor indicator by weight
    SH(:,7) = (1-A(:,8)); % proportion of max carrying capacity which is covered
switch alg_ind 
    case 1
        %% Order ranking   
        
        % seeding rankings
        if isempty(SE)
            prefseedsites = 0;  %if all rows have nans and A is empty, abort mission
            nprefseedsites = 0;
        else
            wse(all(SE == 0,1)) = [];
            SE(:,all(SE == 0,1)) = []; %if a column is all zeros, delete

             % normalisation
            SE(:,2:end) = SE(:,2:end)./sum(SE(:,2:end).^2);
            SE = SE.* repmat(wse,size(SE,1),1);
            
            % simple ranking - add criteria weighted values for each sites
            SEwt(:,1) = SE(:,1);
            SEwt(:,2) = sum(SE(:,2:end),2);
            SEwt2 = sortrows(SEwt,2,'descend'); %sort from highest to lowest indicator

            %highest indicator picks the seed site
            prefseedsites = SEwt2(1:nsiteint,1);
            nprefseedsites = numel(prefseedsites);
        end
        
        % shading rankings
        wsh(all(SH == 0,1)) = [];
        SH(:,all(SH == 0,1)) = []; %if a column is all zeros, delete
        % normalisation
        SH(:,2:end) = SH(:,2:end)./sum(SH(:,2:end).^2);
        SH = SH.* repmat(wsh,size(SH,1),1);
        
        SHwt(:,1) = SH(:,1);
        SHwt(:,2) = sum(SH(:,2:end),2); %for now, simply add indicators 

        SHwt2 = sortrows(SHwt, 2, 'descend'); %sort from highest to lowest indicator

        %highest indicators picks the cool sites
        prefshadesites = SHwt2(1:nsiteint,1);
        nprefshadesites = numel(prefshadesites);
    case 2
        %% TOPSIS

        % seeding rankings
        if isempty(SE)
            prefseedsites = 0;  %if all rows have nans and A is empty, abort mission
            nprefseedsites = 0;
        else
            wse(all(SE==0,1)) = [];
            SE(:,all(SE==0,1)) = []; %if a column is all zeros, delete
           % normalisation
            SE(:,2:end) = SE(:,2:end)./sum(SE(:,2:end).^2);
            SE = SE.* repmat(wse,size(SE,1),1);
            % compute the set of positive ideal solutions for each criteria (max for
            % good crieteria, min for bad criteria). Max used as all crieteria
            % represent preferred attributes not costs or negative attributes

            PIS = max(SE(:,2:end));

            % compute the set of negative ideal solutions for each criteria 
            % (min for good criteria, max for bad criteria). 
            % Min used as all criteria represent preferred attributes not 
            % costs or negative attributes

            NIS = min(SE(:,2:end));

            % calculate separation distance from the ideal and non-ideal solns
            S_p = sqrt(sum((SE(:,2:end)-PIS).^2,2));
            S_n = sqrt(sum((SE(:,2:end)-NIS).^2,2));

            % final ranking measure of relative closeness C
            C = S_n./(S_p + S_n);
            SEwt = [SE(:,1), C];
            order = sortrows(SEwt,2,'descend');

            prefseedsites = order(1:nsiteint,1);
            nprefseedsites = numel(prefseedsites); 
        end
        
        % shading rankings
        wsh(all(SH==0,1)) = [];
        SH(:,all(SH==0,1)) = []; %if a column is all zeros, delete
        % normalisation
        SH(:,2:end) = SH(:,2:end)./sum(SH(:,2:end).^2);
        SH = SH.* repmat(wsh,size(SH,1),1);
        % compute the set of positive ideal solutions for each criteria (max for
        % good crieteria, min for bad criteria). Max used as all crieteria
        % represent preferred attributes not costs or negative attributes

        PIS = max(SH(:,2:end));

        % compute the set of negative ideal solutions for each criteria (min for
        % good crieteria, max for bad criteria). Min used as all crieteria
        % represent preferred attributes not costs or negative attributes

        NIS = min(SH(:,2:end));

        % calculate separation distance from the ideal and non-ideal solns

        S_p = sqrt(sum((SH(:,2:end)-PIS).^2,2));
        S_n = sqrt(sum((SH(:,2:end)-NIS).^2,2));

        % final ranking measue of relative closeness C

        C = S_n./(S_p + S_n);
        SHwt = [SH(:,1), C];
        order = sortrows(SHwt,2,'descend');
        %highest indicators picks the cool sites
        prefshadesites = order(1:nsiteint,1);
        nprefshadesites = numel(prefshadesites); 
    
    case 3
        %% VIKOR
        % level of compromise (utility vs. regret). v = 0.5 is consensus, v<0.5
        % is minimal regret, v>0.5 is max group utility (majority rules)
        v = 0.5;    

        % seeding rankings
        if isempty(SE)
            prefseedsites = 0;  %if all rows have nans and A is empty, abort mission
            nprefseedsites = 0;
        else
            wse(all(SE==0,1)) = [];
            SE(:,all(SE==0,1)) = []; %if a column is all zeros, delete
            % normalisation
            SE(:,2:end) = SE(:,2:end)./sum(SE(:,2:end).^2);
            SE = SE.* repmat(wse,size(SE,1),1);

            F_s = max(SE(:,2:end));

            % Compute utility of the majority S (Manhatten Distance)
            % Compute individual regret R (Chebyshev distance)
            sr_arg =((F_s-SE(:,2:end)));
            S = sum(sr_arg,2);
            S = [SE(:,1), S];
            R = max(sr_arg,[],2);
            R = [SE(:,1),R];

            % Compute the VIKOR compromise Q
            S_s = max(S(:,2));
            S_h = min(S(:,2));
            R_s = max(R(:,2));
            R_h = min(R(:,2));
            Q = v*(S(:,2)-S_h)/(S_s-S_h) + (1-v)*(R(:,2)-R_h)/(R_s-R_h);
            Q = [SE(:,1),Q];

            % sort Q in ascending order rows
            orderQ = sortrows(Q,2,'descend');
            prefseedsites = orderQ(1:nsiteint,1);
            nprefseedsites = numel(prefseedsites); 
        end
        wsh(all(SH == 0,1)) = [];
        SH(:,all(SH == 0,1)) = []; %if a column is all zeros, delete
        % shading rankings
        % normalisation
        SH(:,2:end) = SH(:,2:end)./sum(SH(:,2:end).^2);
        SH = SH.* repmat(wsh,size(SH,1),1);

        F_s = max(SH(:,2:end));

        % Compute utility of the majority S (Manhatten Distance)
        % Compute individual regret R (Chebyshev distance)
        sr_arg =((F_s-SH(:,2:end)));
        S = sum(sr_arg,2);
        S = [SH(:,1), S];
        R = max(sr_arg,[],2);
        R = [SH(:,1),R];

        % Compute the VIKOR compromise Q
        S_s = max(S(:,2));
        S_h = min(S(:,2));
        R_s = max(R(:,2));
        R_h = min(R(:,2));
        Q = v*(S(:,2)-S_h)/(S_s-S_h) + (1-v)*(R(:,2)-R_h)/(R_s-R_h);
        Q = [SH(:,1),Q];

        % sort R, S and Q in ascending order rows
        orderQ = sortrows(Q,2,'descend');
        prefshadesites = orderQ(1:nsiteint,1);
        nprefshadesites = numel(prefshadesites); 
    case 4
        %% Multi-objective GA algorithm weighting
        % set up optimisation problem
        % no inequality constraints
        Aeq = [];
        beq = [];
        
        sites = 1:nsites;

        opts = optimoptions('gamultiobj', 'UseParallel', false, 'Display', 'off');
        % seeding rankings
        if isempty(SE)
            prefseedsites = 0;  %if all rows have nans and A is empty, abort mission
            nprefseedsites = 0;
        else
            wse(all(SE == 0,1)) = [];
            SE(:,all(SE == 0,1)) = []; %if a column is all zeros, delete
             % integer weights must sum to number of preferred sites
            A = ones(1,length(SE(:,1)));
            b = nsiteint;

             % integer variables
            intcon = 1:length(SE(:,1));
            
            % normalisation
            SE(:,2:end) = SE(:,2:end)./sum(SE(:,2:end).^2);
            SE = SE.* repmat(wse,size(SE,1),1);

            % multi-objective function for seeding
            fun1 = @(x) -1* ADRIA_siteobj(x,SE(:,2:end));
            % solve multi-objective problem using genetic alg
            lb = zeros(1,length(SE(:,1))); % x (weightings) can be 0
            ub = ones(1,length(SE(:,1))); % to 1
            x1 = gamultiobj(fun1,length(SE(:,1)),Aeq,beq,A,b,lb,ub,[],intcon,opts);            
            
            % randomly select solution from pareto front
            ind = randi([1 size(x1,1)]);
            % select optimal sites
            prefseedsites = sites(logical(x1(ind,:)));            
            nprefseedsites = numel(prefseedsites);
        end
         % shading rankings
         wsh(all(SH == 0,1)) = [];
         SH(:,all(SH == 0,1)) = []; %if a column is all zeros, delete
         % integer weights must sum to number of preferred sites
         A = ones(1,length(SH(:,1)));
         b = nsiteint;
            
         % integer variables
         intcon = 1:length(SH(:,1));

        % normalisation
        SH(:,2:end) = SH(:,2:end)./sum(SH(:,2:end).^2);
        SH = SH.* repmat(wsh,size(SH,1),1);
        
        lb = zeros(1,length(SH(:,1))); % x (weightings) can be 0
        ub = ones(1,length(SH(:,1))); % to 1

        
        % multi-objective function for shading
        fun2 = @(x) -1* ADRIA_siteobj(x,SH(:,2:end));
        % solve multi-objective problem using genetic alg
        x2 = gamultiobj(fun2,length(SH(:,1)),Aeq,beq,A,b,lb,ub,[],intcon,opts);
        
        % randomly select solution from pareto front
        ind = randi([1 size(x2,1)]);

        % select optimal sites
        prefshadesites = sites(logical(x2(ind,:)));
        nprefshadesites = numel(prefshadesites);

end 
end


