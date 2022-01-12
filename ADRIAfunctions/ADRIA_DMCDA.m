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
    %Combine data into matrix
    A(:,1) = sites; %site IDs
    A(:,2) = centr/max(centr); %node connectivity centrality, need to instead work out strongest predecessors to priority sites  
    A(:,3) = damprob/max(damprob); %damage probability from wave exposure
    A(:,4) = heatstressprob/max(heatstressprob); %risk from heat exposure
    
    prop_cover = sumcover/max(sumcover);  %proportional coral cover
    A(:,5) = prop_cover; 
    A(:,6) = 1 - prop_cover;
    A(:,7) = predec(:,3);

% %     % Filter out sites that have high risk of wave damage, specifically 
% %     % exceeding the risk tolerance 
%     A(A(:, 3) > risktol, 3) = nan;
%     rule = (A(:, 3) <= risktol) & (A(:, 4) > risktol);
% 
%     A(rule, 4) = nan;
%     
%     A(any(isnan(A),2),:) = []; %if a row has a nan, delete it
%     if isempty(A)
%         prefseedsites = 0;  %if all rows have nans and A is empty, abort mission
%         nprefseedsites = 0;
%         prefshadesites = 0;
%         nprefshadesites = 0;
%         return
%     end
% 
%     %number of sites left after risk filtration
%     %nsitesrem = length(A(:,1));
%     if nsiteint > length(A(:,1))
%         nsiteint = length(A(:,1));
%     end

switch alg_ind 
    case 1
        %% Order ranking
        %% Seeding - Filtered set 
        SE(:,1) = A(:,1); %sites column (remaining)
        SE(:,2) = A(:,2)*wtconseed; %multiply centrality with connectivity weight
        SE(:,3) = (1-A(:,3))*wtwaves; %multiply complementary of damage risk with disturbance weight
        SE(:,4) = (1-A(:,4))*wtheat;
        SE(:,5) = A(:,6)*wtlocover; %multiply by coral cover with its weight for high cover
        SE(:,6) = A(:,7)*wtpredecseed; %multiply priority predecessor indicator by weight

        SEwt(:,1) = A(:,1);
        SEwt(:,2) = SE(:,2)+ SE(:,3) + SE(:,4) + SE(:,5); %for now, simply add indicators 
        SEwt2 = sortrows(SEwt,2,'descend'); %sort from highest to lowest indicator

        %highest indicator picks the seed site
        prefseedsites = SEwt2(1:nsiteint,1);
        nprefseedsites = numel(prefseedsites);


        %% Shading - filtered set
        SH(:,1) = A(:,1); %sites column (remaining)
        SH(:,2) = A(:,2)*wtconshade; %multiply centrality with connectivity weight
        SH(:,3) = (1-A(:,3))*wtwaves; %multiply complementary of damage risk with disturbance weight
        SH(:,4) = A(:,4)*wtheat; %multiply complementary of heat risk with heat weight
        SH(:,5) = A(:,5)*wthicover; %multiply by coral cover with its weight for high cover
        SH(:,6) = A(:,7)*wtpredecshade; %multiply priority predecessor indicator by weight

        SHwt(:,1) = A(:,1);
        SHwt(:,2) = SH(:,2)+ SH(:,3) + SH(:,4) + SH(:,5); %for now, simply add indicators 
        % if SHwt(:,2) == 0
        %     %SHwt(:,2) = rand(length(A(:,1)),1);
        %     SHwt2 = sortrows(SHwt,2,'descend'); %sort from highest to lowest indicator
        % else
        SHwt2 = sortrows(SHwt, 2, 'descend'); %sort from highest to lowest indicator
        % end

        %highest indicators picks the cool sites
        prefshadesites = SHwt2(1:nsiteint,1);
        nprefshadesites = numel(prefshadesites);
    case 2
        %% TOPSIS
        %% Seeding - Filtered set 
        
        wse = [1, wtconseed, wtwaves, wtheat, wtlocover, wtpredecseed];
        wse = wse./sum(wse);
        SE(:,1) = A(:,1); %sites column (remaining)
        SE(:,2) = A(:,2); %multiply centrality with connectivity weight
        SE(:,3) = (1-A(:,3)); %multiply complementary of damage risk with disturbance weight
        SE(:,4) = (1-A(:,4));
        SE(:,5) = A(:,6); %multiply by coral cover with its weight for high cover
        SE(:,6) = A(:,7); %multiply priority predecessor indicator by weight

       % normalisation
        SE(:,2:end) = SE(:,2:end)./sum(SE(:,2:end).^2);
        SE = SE.* repmat(wse,size(SE,1),1);
        % compute the set of positive ideal solutions for each criteria (max for
        % good crieteria, min for bad criteria). Max used as all crieteria
        % represent preferred attributes not costs or negative attributes

        PIS = nanmax(SE(:,2:end));

        % compute the set of negative ideal solutions for each criteria 
        % (min for good criteria, max for bad criteria). 
        % Min used as all criteria represent preferred attributes not 
        % costs or negative attributes

        NIS = nanmin(SE(:,2:end));

        % calculate separation distance from the ideal and non-ideal solns
        S_p = sqrt(sum((SE(:,2:end)-PIS).^2,2));
        S_n = sqrt(sum((SE(:,2:end)-NIS).^2,2));

        % final ranking measure of relative closeness C
        C = S_n./(S_p + S_n);
        SEwt = [A(:,1), C];
        order = sortrows(SEwt,2,'descend');

        prefseedsites = order(1:nsiteint,1);
        nprefseedsites = numel(prefseedsites); 

        wsh = [1, wtconshade, wtwaves, wtheat, wthicover, wtpredecshade];
        wsh = wsh./sum(wsh);
        SH(:,1) = A(:,1); %sites column (remaining)
        SH(:,2) = A(:,2); %multiply centrality with connectivity weight
        SH(:,3) = (1-A(:,3)); %multiply complementary of damage risk with disturbance weight
        SH(:,4) = A(:,4); %multiply complementary of heat risk with heat weight
        SH(:,5) = A(:,5); %multiply by coral cover with its weight for high cover
        SH(:,6) = A(:,7); %multiply priority predecessor indicator by weight

        % normalisation
        SH(:,2:end) = SH(:,2:end)./sum(SH(:,2:end).^2);
        SH = SH.* repmat(wsh,size(SH,1),1);
        % compute the set of positive ideal solutions for each criteria (max for
        % good crieteria, min for bad criteria). Max used as all crieteria
        % represent preferred attributes not costs or negative attributes

        PIS = nanmax(SH(:,2:end));

        % compute the set of negative ideal solutions for each criteria (min for
        % good crieteria, max for bad criteria). Min used as all crieteria
        % represent preferred attributes not costs or negative attributes

        NIS = nanmin(SH(:,2:end));

        % calculate separation distance from the ideal and non-ideal solns

        S_p = sqrt(sum((SH(:,2:end)-PIS).^2,2));
        S_n = sqrt(sum((SH(:,2:end)-NIS).^2,2));

        % final ranking measue of relative closeness C

        C = S_n./(S_p + S_n);
        SHwt = [A(:,1), C];
        order = sortrows(SHwt,2,'descend');
        %highest indicators picks the cool sites
        prefshadesites = order(1:nsiteint,1);
        nprefshadesites = numel(prefshadesites); 
    
    case 3
        %% VIKOR
        % level of compromise (utility vs. regret). v = 0.5 is consensus, v<0.5
        % is minimal regret, v>0.5 is max group utility (majority rules)
        v = 0.5;    
        %% Seeding - Filtered set 
        % make weighting vector and make it sum to 1
        wse = [1, wtconseed, wtwaves, wtheat, wtlocover, wtpredecseed];
        wse = wse./sum(wse);

        SE(:,1) = A(:,1); %sites column (remaining)
        SE(:,2) = A(:,2); %multiply centrality with connectivity weight
        SE(:,3) = (1-A(:,3)); %multiply complementary of damage risk with disturbance weight
        SE(:,4) = (1-A(:,4));
        SE(:,5) = A(:,6); %multiply by coral cover with its weight for high cover
        SE(:,6) = A(:,7); %multiply priority predecessor indicator by weight

        % normalisation
        SE(:,2:end) = SE(:,2:end)./sum(SE(:,2:end).^2);
        SE = SE.* repmat(wse,size(SE,1),1);

        F_s = max(SE(:,2:end));
        %F_h = min(SE(:,2:end));

        % Compute utility of the majority S (Manhatten Distance)
        % Compute individual regret R (Chebyshev distance)
        sr_arg =((F_s-SE(:,2:end)));
        S = sum(sr_arg,2);
        S = [A(:,1), S];
        R = max(sr_arg,[],2);
        R = [A(:,1),R];

        % Compute the VIKOR compromise Q
        S_s = max(S(:,2));
        S_h = min(S(:,2));
        R_s = max(R(:,2));
        R_h = min(R(:,2));
        Q = v*(S(:,2)-S_h)/(S_s-S_h) + (1-v)*(R(:,2)-R_h)/(R_s-R_h);
        Q = [A(:,1),Q];

        % sort Q in ascending order rows
        orderQ = sortrows(Q,2,'ascend');
        prefseedsites = orderQ(1:nsiteint,1);
        nprefseedsites = numel(prefseedsites); 

        %% Shading - Filtered set 
        wsh = [1, wtconshade, wtwaves, wtheat, wthicover, wtpredecshade];
        wsh = sum(wsh);

        SH(:,1) = A(:,1); %sites column (remaining)
        SH(:,2) = A(:,2); %multiply centrality with connectivity weight
        SH(:,3) = (1-A(:,3)); %multiply complementary of damage risk with disturbance weight
        SH(:,4) = A(:,4); %multiply complementary of heat risk with heat weight
        SH(:,5) = A(:,5); %multiply by coral cover with its weight for high cover
        SH(:,6) = A(:,7); %multiply priority predecessor indicator by weight

        % normalisation
        SH(:,2:end) = SH(:,2:end)./sum(SH(:,2:end).^2);
        SH = SH.* repmat(wsh,size(SH,1),1);

        F_s = max(SH(:,2:end));
        %F_h = min(SH(:,2:end));

        % Compute utility of the majority S (Manhatten Distance)
        % Compute individual regret R (Chebyshev distance)
        sr_arg =((F_s-SH(:,2:end)));
        S = nansum(sr_arg,2);
        S = [A(:,1), S];
        R = max(sr_arg,[],2);
        R = [A(:,1),R];

        % Compute the VIKOR compromise Q
        S_s = max(S(:,2));
        S_h = min(S(:,2));
        R_s = max(R(:,2));
        R_h = min(R(:,2));
        Q = v*(S-S_s)/(S_s-S_h) + (1-v)*(R-R_s)/(R_s-R_h);
        Q = [A(:,1),Q];

        % sort R, S and Q in ascending order rows
        orderQ = sortrows(Q,2,'ascend');
        prefshadesites = orderQ(1:nsiteint,1);
        nprefshadesites = numel(prefshadesites); 
    case 4
        %% Multi-objective GA algorithm weighting
        % Seeding - Filtered set 
        SE(:,1) = A(:,1); %sites column (remaining)
        SE(:,2) = A(:,2)*wtconseed; %multiply centrality with connectivity weight
        SE(:,3) = (1-A(:,3))*wtwaves; %multiply complementary of damage risk with disturbance weight
        SE(:,4) = (1-A(:,4))*wtheat;
        SE(:,5) = A(:,6)*wtlocover; %multiply by coral cover with its weight for high cover
        SE(:,6) = A(:,7)*wtpredecseed; %multiply priority predecessor indicator by weight
        
         % Shading - filtered set
        SH(:,1) = A(:,1); %sites column (remaining)
        SH(:,2) = A(:,2)*wtconshade; %multiply centrality with connectivity weight
        SH(:,3) = (1-A(:,3))*wtwaves; %multiply complementary of damage risk with disturbance weight
        SH(:,4) = A(:,4)*wtheat; %multiply complementary of heat risk with heat weight
        SH(:,5) = A(:,5)*wthicover; %multiply by coral cover with its weight for high cover
        SH(:,6) = A(:,7)*wtpredecshade; %multiply priority predecessor indicator by weight
        
        % set up optimisation problem
        % no inequality or equality constraints
        Aeq = [];
        beq = [];
        Aineq = [];
        bineq = [];
        lb = zeros(1,length(A(:,1))); % x (weightings) can be 0
        ub = ones(1,length(A(:,1))); % to 1
     
        % multi-objective function for seeding
        fun1 = @(x) -1* ADRIA_siteobj(x,SE(:,2:end));
        % solve multi-objective problem using genetic alg
        x1 = gamultiobj(fun1,length(A(:,1)),Aineq,bineq,Aeq,beq,lb,ub);
        x1 = x1(end,:);
        
        % multi-objective function for shading
        fun2 = @(x) -1* ADRIA_siteobj(x,SH(:,2:end));
        % solve multi-objective problem using genetic alg
        x2 = gamultiobj(fun2,length(A(:,1)),Aineq,bineq,Aeq,beq,lb,ub);
        x2 = x2(end,:);
        
        % order ga alg generated weightings from highest to lowest
        orderseed = sortrows([SE(:,1) x1'],2,'descend');
        ordershade = sortrows([SH(:,1) x2'],2,'descend');
        
        % use to select sites
        prefseedsites = orderseed(1:nsiteint,1);
        prefshadesites = ordershade(1:nsiteint,1);
        nprefshadesites = numel(prefshadesites);
        nprefseedsites = numel(prefseedsites);
end 

end


