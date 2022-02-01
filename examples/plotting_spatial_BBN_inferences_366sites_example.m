%% Load Data

sites = 1:366;
% intervention and metric variables to include
Names = {'Year','Site','Seed1','Seed2','TotalCover','Evenness','ShelterVolume'};
filename = 'BBN_data_366_sites.csv';
bbn_data = readmatrix(filename);
%% Make BBN
% declare parent cells
% create parant cell container for DAG structure
ParentCell = cell(1,7);

% input variables assumed to have no dependent nodes (so corresponding
% parent cell entry is blank
for k = 1:4
    ParentCell{k} = [];
end
% output variables assumed to be dependent on all input variables
for l = 5:7
    ParentCell{l} = 1:4;
end

R =  bn_rankcorr(ParentCell, bbn_data, 1, 1, Names);

%% plotting probability of sites with coral cover >0.7, RCP 60, by yr 10, 
% probability indicated with colours
% nodes we know
inf_cells = 1:4;

increArray = 1:366;

knownVars = [26,3,26,1,3,0.0009,0.0009];

% storage for probabilities
Fp = zeros(1,length(increArray));
hist_ind = 1;
nodePos = 2;
knownVars = [25,2000,2000];

% position of coral cover within the unknown variables can be calculated as
% (length(Names)-length(knownVars)-3)

F1 = multiBBNInf(bbn_data, R, knownVars,inf_cells,increArray,nodePos);

val = 0.8;
% loop over 26 sites
for l = 1:length(increArray)
    f = F1{l};
    Fp(l) = calcBBNProb(f{hist_ind},val,1);
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

