function [TP_data, site_ranks, strongpred] =  siteConnectivity(file, con_cutoff)
% Create transitional probability matrix indicating connectivity between
% sites, level of centrality, and the strongest predecessor for each site.
%
% Inputs:
%   file       : str, path to data file to load
%   con_cutoff : float, percent thresholds of max for weak connections in 
%                  network (defined in ADRIAparms.m)
%
% Output:
%   TP_data    : table[float], containing the transition probability for 
%                  all sites
%   site_ranks : table[float], centrality for each site
%   strongpred : matrix[float], strongest predecessor for each site
%
% Example: 
%     siteConnectivity('MooreTPmean.xlsx', 0.1)
%% Load transitional probability matrix (connectivity between sites)
F1 = readtable(file, 'PreserveVariableNames', true);
F1(:,1:2) = [];  % remove the ID and address columns
F1(1:2,:) = [];  % remove the ID and address rows
TP1 = table2array(F1); % Transition probability matrix for all sites
maxTP1cut = max(TP1,[],'all')*con_cutoff;
TP1(TP1<maxTP1cut) = 0;  % filter out weak connections
TPbase =  TP1;
        
% Change connectivity as a function of wind and tides
TP_data(:,:,1) = TPbase;
% NOTE we need to instead make this a variable adjacency matrix that changes 
% continuously as a function of wind and time and their combination


%% Create the digraphs, and modify plot parameters
DGbase = digraph(TPbase);
%Edgeweights
EW_base = DGbase.Edges.Weight;

C1 = centrality(DGbase, 'indegree', 'Importance', EW_base);

%% Find strongest predecessors
nsites = length(C1);
strongpred = zeros(nsites, 2);
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

site_ranks = table(C1);
site_ranks(nsites+1:end,:) = [];

end