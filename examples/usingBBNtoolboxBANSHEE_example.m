%% Example of constructing a BBN for ADRIA outputs using the BANSHEE toolbox and a small data set generated from ADRIA

% construct node names (order should match that in the data)
nodeNames = {'RCP'; 'Years'; 'Guided'; 'PrSites';'Seed1'; 'Seed2'; 'SRM'; 'AssAdt'; 'NatAdt'; 'CC';'CultES';'ProvES'};

% node idices for dependent variables
outputVars = [10,11,12];

% load data into a matrix
% should have size (no. of parameter permutations)*(no. of nodes)
% (note this is a very small data set so inference outcomes may not make
% sense)
Data = readmatrix('ADRIA_BBN_Data.csv');

% this data has no variance in the DMCDA algorithm variable so it is not
% included here
Data(:,2) = [];

% visualise both the correlation matrix and the BBN DAG
visVars = [1,1];

[R,ParentCell] = dataToBBNStructure(nodeNames,Data,outputVars,visVars);

%% Inference example
% the function inference is used to make inferences on
% the network

% for example - what is the mean coral cover, CES and PES for an RCP of 2.6,
% at year 30, with guided interventions, using all sites (Prsites =3 ) and
% only seed1 and seed2 =0.0005

% nodes we know
inf_cells = [1:9];
% their values
vals = [26,30,1,3,0.0005,0.0005,0,0,0];
% make inference
% 1000,'near' -> 1000 iterations of nearest neighbour
% 'mean' -> just give the means of the distributions as output
outcome1 = inference(inf_cells,vals,R,Data,'mean',1000,'near');

% print results
fprintf('The average coral cover is : %1.3f, the average CES is : %1.3f, the average PES is : %1.3f \n',outcome1(1),outcome1(2),outcome1(3));

%% make the same inference but now with incrementally increasing years 
% and plot as histograms

% want to plot hists
plotInd = 1;

% perform inference for RCP 2.6, Guided = 1, PrSites = 3, seed1 = 0.0005,
% Seed2 = 0.0005 and the other interventions = 0. CC, S and E are unknowns.
knownVars = [26,1,3,0.0005,0.0005,0,0,0];
% increment years from 10 to 50 in 10s
increArray = 10:10:50;
% the incremented var (years) is in node 2 and the output variable (coral
% cover) is the first output unknown variable)
nodePos = [2,1];

F0 = multiBBNInf(Data, R, knownVars,inf_cells,increArray,nodePos, plotInd);

legend('year 10','year 20','year 30','year 40','year 50');

%% perform an inference on the interventions
% what interventions acheive cc = 0.6,ces = 0.2 and pes = 0.2 by year 50 at
% rcp 6.0, with guided interventions and all sites
 F0 = inference([1:4 10:12],[60, 10, 1, 3, 0.8,0.2,0.2],R,Data,'mean',1000,'near');
fprintf('The average intervention levels predicted are Seed1 %1.3f, Seed2 %1.3f, SRM %1.2f, As.Adt. %2.2f, Nat.Adt. %1.3f \n',F0)
 
 %% calculate the probability of coral cover >0.8 
 % with no constraint on ES, at year 20, with rcp 6.0, with SRM = 5 and 
 % ass adpt = 6 and calculate full distribution first
  F0 = inference([1:9],[60,30,1,3,0,0,5,6,0],R,Data,'full',1000,'near');
  
  % find probability
  dist = F0{1};
  ind = 1;
  val = 0.8;
  prob = calcBBNProb(dist,val,ind);
  fprintf('The probability of coral cover >0.8 for this scenario is %1.4f \n',prob);