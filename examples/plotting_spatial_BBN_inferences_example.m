%% Transform raw .mat data

% filetype of saved raw data
filetype = 'mat';
% rcps to include
rcps = [26,45,60];
% algorithms to include
algs = 1:3;
% sites to include
sites = 1:26;
% intervention variables to include
col_names = {'Guided','PrSites','Seed1','Seed2','SRM','Aadpt','Natad','Seedyrs','Shadeyrs'};
% output metrics to include
metrics = {'TC','S','E'};
% number of simulations
nsims = 50;
% first year, yr increment and last year to use
yr = [1,2,25];

% create data table
Data = BBNTableMCData(filetype,rcps,algs,col_names,nsims,yr,sites,metrics);

% check header
head(Data)

%% Make BBN
% declare nodes in BBN
Names = {'RCP'; 'Alg';'Years';'Sites';'Guided'; 'PrSites';'Seed1'; 'Seed2'; 'SRM'; 'AssAdt'; 'NatAdt'; 'Seedyrs';'Shadeyrs';...
    'CC';'S';'E'};

% construct ParentCell, a cell structure of size 1*(no. of nodes)
% (each cell contains the parents of the node corresponding the the cell
% no.) and R, the rank correlation matrix

Data = table2array(Data);
% indices of dependent variables (CC, CES and PES)
outputVars = 14:16;
% plot correlation matrix and BBN DAG
visVars = [1,1];

[R, ParentCell] = dataToBBNStructure(Names,Data,outputVars,visVars);

%% example - what is the mean coral cover, E and S on site 26 for an RCP of 4.5,
% at year 10, with guided interventions, using all sites (Prsites = 3 ) and
% only seed1 and seed2 = 0.0005,seedyrs 12 and shadeyrs 3

% note that when performing inferences in this larger network, not enough
% degrees of freedom (e.g. setting too many variables as known) can result
% in Nans. It seems at least 5 variables need to be unknown to allow
% calculation.

% nodes we know
inf_cells = 1:8;
% their values
vals = [26,3,10,26,1,3,0.0009,0.0009];
outcome1 = inference(inf_cells,vals,R,Data,'mean',1000,'near');

% their values, now with algorithm 1 for comparison
vals = [26,1,10,26,1,3,0.0009,0.0009];
outcome2 = inference(inf_cells,vals,R,Data,'mean',1000,'near');

%% make the same inference but now with incrementally increasing years and
% retrieve the full distribution

increArray = 1:4:25;
knownVars = [26,3,26,1,3,0.0009,0.0009];
% position of coral cover within the unknown variables can be calculated as
% (length(Names)-length(knownVars)-3)
hist_ind = (length(Names)-length(knownVars)-3);

nodePos = 3;
F1 = multiBBNInf(Data, R, knownVars,inf_cells,increArray,nodePos);
figure;
hold on
for l = 1:length(increArray)
    hist_dat = F1{l};
    % plot the coral cover distribution as a histogram
    h = histogram(hist_dat{hist_ind},'NumBins',30,'Normalization','probability');  
end
hold off
legend('year 1','year 5','year 9','year 13','year 17','year 21','year 25');

% compare with rcp 60
knownVars = [60,3,26,1,3,0.0009,0.0009];
F2 = multiBBNInf(Data, R, knownVars,inf_cells,increArray,nodePos);
figure;
hold on
for l = 1:length(increArray)
    hist_dat = F2{l};
    % plot the coral cover distribution as a histogram
    h = histogram(hist_dat{hist_ind},'NumBins',30,'Normalization','probability');  
end
hold off
legend('year 1','year 5','year 9','year 13','year 17','year 21','year 25');

%% plotting probability of sites with coral cover >0.7, RCP 60, by yr 10, 
% probability indicated with colours
% nodes we know
inf_cells = 1:8;

% don't plot histograms when generating multiple distributions
plotInd = 0;

% storage for probabilities
Fp = zeros(1,length(increArray));
hist_ind = (length(Names)-length(knownVars)-3);

increArray = 1:26;
knownVars = [60,3,10,1,3,0.0009,0.0009];

% position of coral cover within the unknown variables can be calculated as
% (length(Names)-length(knownVars)-3)
nodePos = 4;
F1 = multiBBNInf(Data, R, knownVars,inf_cells,increArray,nodePos);

val = 0.7;
% loop over 26 sites
for l = 1:length(increArray)
    f = F1{l};
    Fp(l) = calcBBNProb(f{hist_ind},val,1);
end

% RCP 45 for comparison
% storage for probabilities
Fp2 = zeros(1,length(increArray));
knownVars = [45,3,10,1,3,0.0009,0.0009];

F2 = multiBBNInf(Data, R, knownVars,inf_cells,increArray,nodePos);

% loop over 26 sites
for l = 1:length(increArray)
    f = F2{l};
    Fp2(l) = calcBBNProb(f{hist_ind},val,1);
end


%% Plot probabilities on lat lon map
fileloc = 'Inputs/';
            load([fileloc,'MooreSitesDomainInfo.mat'])

figure(4)            
[ax1,ax2] = plotBBNProbMap(F0,botz,lat,lon,Fp)
title(ax1,'RCP $6.0$','FontSize',20,'Interpreter','latex')
caxis([0,0.025])

figure(5)
[ax3,ax4] = plotBBNProbMap(F0,botz,lat,lon,Fp2)
title(ax3,'RCP $4.5$','FontSize',20,'Interpreter','latex')
caxis([0,0.05])

