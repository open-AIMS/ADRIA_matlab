function [prefseedsites,prefshadesites,nprefseedsites,nprefshadesites] = ADRIA_DMCDA(DCMAvars)

% utility function that uses a dynamic MCDA to work out what sites to pick, 
%if any before going into the bleaching or cyclone season. It uses
%disturbance probabilities for the season (distprobyr, a vector)) and
%centrality of season (central, a vector) to produce a site ranking table

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
A(:,3) = damprob.dam/max(damprob.dam); %damage probability from wave exposure
A(:,4) = heatstressprob.heatstress/max(heatstressprob.heatstress); %risk from heat exposure
A(:,5) = sumcover.covtott/max(sumcover.covtott); %coral cover
A(:,6) = 1-sumcover.covtott/max(sumcover.covtott);
A(:,7) = predec(:,3);

% %Filter out sites that have high risk of wave damage, specifically exceeding the risk tolerance 
for i = 1:nsites
     if A(i,3)> risktol %
         A(i,3)=nan;
     elseif A(i,4)>risktol
         A(i,4)=nan;
     end
end
% 
A(any(isnan(A),2),:) = []; %if a row has a nan, delete it
if isempty(A)
    prefseedsites = 0;  %if all rows have nans and A is empty, abort mission
end
    
%number of sites left after risk filtration
%nsitesrem = length(A(:,1));
if nsiteint > length(A(:,1))
    nsiteint = length(A(:,1));
end

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
SHwt2 = sortrows(SHwt,2,'descend'); %sort from highest to lowest indicator
% end
%highest indicators picks the cool sites
prefshadesites = SHwt2(1:nsiteint,1);
nprefshadesites = numel(prefshadesites);
end

