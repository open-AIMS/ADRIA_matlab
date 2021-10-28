function [TPdata,SiteRanks,strongpred,nsites] =  ADRIA_TP_Moore(con_cutoff)
%
% Input: 
%   con_cutoff: percent thresholds of max for weak connections in network
%   (defined in ADRIAparms.m) (float)
%
% Output:
%   TPdata: Table containing the transition probability for all sites (float)
%   SiteRanks: Centrality for each site
%   strongpred: Strongest predecessor for each site
%   nsites: number of sites
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning("Use of `ADRIA_TP_Moore()` is deprecated. Use `ADRIA_TP(filename, con_cutoff)` instead. Example: ADRIA_TP('MooreTPmean.xlsx', 0.1)")

%% Load Moore sites location data
F0 = readtable('MooreSites.xlsx', 'PreserveVariableNames',true);
F0 = table2array(F0); %site IDs, site address, lons and lats for all sites
xx = F0(:,3); %lon
yy = F0(:,4); %lat

%% Load transitional probability matrix (connectivity between sites)
F1 = readtable('MooreTPmean.xlsx', 'PreserveVariableNames',true);
F1(:,1:2) = [];  %remove the ID and address columns
F1(1:2,:) = [];  %remove the ID and address rows
TP1 = table2array(F1); %Transition probability matrix for all sites
maxTP1cut = max(TP1,[],'all')*con_cutoff;
TP1(TP1<maxTP1cut) = 0;  %filter out weak connections
TPbase =  TP1;
        
% Change connectivity as a function of wind and tides
TPdata(:,:,1) = TPbase;
% NOTE we need to instead make this a variable adjacency matrix that changes 
% continuously as a function of wind and time and their combination


%% Create the digraphs, and modify plot parameters
DGbase = digraph(TPbase);
%Edgeweights
EWbase = DGbase.Edges.Weight;

C1 = centrality(DGbase,'indegree','Importance',DGbase.Edges.Weight);

%% Find strongest predecessors
nsites = length(C1);
strongpred = zeros(nsites,2);
strongpred(:,1) = 1:nsites;
%need to find a way here to deal with empty cells for eid
for s = 1:nsites
    [eid,~] = inedges(DGbase,s);
    if isempty(eid) == 1 
        strongpred(s,2) = nan;
    else
        X = table2array(DGbase.Edges(eid,:));
        X(:,2) =[];
        mxm = max(X(:,2));
        strongpred(s,2) = find(X(:,2)==mxm);
    end
end

%rwnames = {'Site1';'Site2';'Site3';'Site4';'Site5'};
%SiteRanks = table(C1,C2,C3);%,'RowNames',rwnames
SiteRanks = table(C1);%,'RowNames',rwnames
SiteRanks(nsites+1:end,:) = [];

end