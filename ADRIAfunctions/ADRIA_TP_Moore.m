function [TPdata,SiteRanks,strongpred] =  ADRIA_TP_Moore(showfigs,nsites,con_cutoff)

%% Load Moore sites
F0 = readtable('MooreSites.xlsx', 'PreserveVariableNames',true);
F0 = table2array(F0); %site IDs, lats and lons for all sites
xx = F0(:,3);
yy = F0(:,4);

%% Load transitional probability matrix
F1 = readtable('MooreTPmean.xlsx', 'PreserveVariableNames',true);
F1(:,1:2) = [];  %remove the ID and address columns
F1(1:2,:) = [];  %remove the ID and address rows
TP1 = table2array(F1); %Transition probability matrix for all sites
maxTP1 = max(TP1,[],'all');
maxTP1cut = maxTP1*con_cutoff;
TP1(TP1<maxTP1cut) = 0;  %filter out weak connections
TPbase =  TP1;
        
% Change connectivity as a function of wind and tides
TPdata(:,:,1) = TPbase;
% NOTE we need to instead make this a variable adjacency matrix that changes 
% continuously as a function of wind and timds and their combination


%% Create the digraphs, and modify plot parameters
DGbase = digraph(TPbase);
%Edgeweights
EWbase = DGbase.Edges.Weight;

C1 = centrality(DGbase,'indegree','Importance',DGbase.Edges.Weight);

%% Find strongest predecessors
nsites = 26;
strongpred = zeros(nsites,2);
strongpred(:,1) = 1:nsites;
%need to find a way here to deal with empty cells for eid
for s = 1:nsites
[eid,~] = inedges(DGbase,s);
if isempty(eid) == 1 
    strongpred(s,2) = nan;
else
X = DGbase.Edges(eid,:);
X2 = table2array(X);
X2(:,2) =[];
mxm = max(X2(:,2));
strongpred(s,2) = find(X2(:,2)==mxm);
end
end

%rwnames = {'Site1';'Site2';'Site3';'Site4';'Site5'};
%SiteRanks = table(C1,C2,C3);%,'RowNames',rwnames
SiteRanks = table(C1);%,'RowNames',rwnames
SiteRanks(nsites+1:end,:) = [];


if showfigs == 1
%% Display directed graph (DG)

xx = F0(:,3);
yy = F0(:,4);

figure('Position', [15 15 800 500]);
J1=plot(DGbase, 'XData', xx, 'YData', yy);
%J1 =plot(DGbase, 'layout','circle');
J1.EdgeCData = nonzeros(EWbase*30);    % define edge colors
J1.LineWidth = 2;
J1.ArrowSize = 15;
J1.NodeFontSize = 10;
J1.NodeColor = [1,0.3,0.3];
%J1.EdgeColor = EWbase;%'k';
set(gca,'FontSize', 14);
set(gca,'color','none'); %set box to transparent
%axis([-1,1,-1,1]);
colormap jet;
colorbar;
caxis([0,inf]);
set(gca,'xtick',[],'ytick',[]);
box off
axis off



%% Display histograms of in and out degrees

% % D1 = zeros(3,3);
% % D2 = zeros(3,3);
% % D3 = zeros(3,3);
% % D4 = zeros(3,3);
% 
% N = length(TPdata(1)); %number of nodes (sites)
% 
% %Gbase = digraph(TPdata(:,:,1)); %generate digraph of transition probability matrix
% D1(:,1) = outdegree(DGbase)/N; %source strengths
% D2(:,1) = indegree(DGbase)/N; %sink strengths
% D3(:,1) = (D1(:,1)+D2(:,1))/(2*N); %source and sink strengths
% D4(:,1) = diag(TPdata(:,:,1)); %propensity for self-seeding
% 
% %Gwind = digraph(TPdata(:,:,2)); %generate digraph of transition probability matrix
% D1(:,2) = outdegree(DGwind)/N; %source strengths
% D2(:,2) = indegree(DGwind)/N; %sink strengths
% D3(:,2) = (D1(:,2)+D2(:,2))/(2*N); %source and sink strengths
% D4(:,2) = diag(TPdata(:,:,2)); %propensity for self-seeding
% 
% %Gtide = digraph(TPdata(:,:,1)); %generate digraph of transition probability matrix
% D1(:,3) = outdegree(DGtide)/N; %source strengths
% D2(:,3) = indegree(DGtide)/N; %sink strengths
% D3(:,3) = (D1(:,3)+D2(:,3))/(2*N); %source and sink strengths
% D4(:,3) = diag(TPdata(:,:,3)); %propensity for self-seeding
% 

% %% Display histogram of source-sink strengths
% figure('position', [15 15 800 500]);
% for rw = 1:3
% subplot(3,4,(rw-1)*4+1)
% bar(D1(:,rw));
% set(gca,'FontSize', 14);
% title('Out-degrees')
% 
% subplot(3,4,(rw-1)*4+2)
% bar(D2(:,rw));
% set(gca,'FontSize', 14);
% title('In-degrees')
% 
% subplot(3,4,(rw-1)*4+3)
% bar(D3(:,rw));
% set(gca,'FontSize', 14);
% title('In- and out-degrees')
% 
% subplot(3,4,(rw-1)*4+4)
% bar(D4(:,rw));
% set(gca,'FontSize', 14);
% title('Self-seeding')
% end
end

end