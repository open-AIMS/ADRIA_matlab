%% Example of constructing a BBN for ADRIA outputs using the BANSHEE toolbox and a small data set generated from ADRIA

% construct node names (order should match that in the data
names = {'RCP'; 'Years'; 'Guided'; 'PrSites'; 'Seed1'; 'Seed2'; 'SRM'; 'AssAdt'; 'NatAdt'; 'CC'; 'CultES'; 'ProvES'};

% construct `parent_cell`, a cell structure of size 1*(no. of nodes)
% each cell contains the parents of the node corresponding the the cell no.
% (e.g. cell no. 2 contains the parents of the Years node)
parent_cell = cell(1, 12);
for i = 1:9
    parent_cell{i} = [];
end
parent_cell{10} = 1:9;
parent_cell{11} = 1:9;
parent_cell{12} = 1:9;

% load data into a matrix
% should have size (no. of parameter permutations)*(no. of nodes)
% (note this is a very small data set so inference outcomes may not make
% sense)
bbn_data = readmatrix('ADRIA_BBN_Data.csv');

% this data has an irrelevant column for the DMCDA algorithm variable (the
% same for every variable permutation in this case, so not included)
bbn_data(:, 2) = [];

% calculate the rank correlation matrix
% the 3rd argument tells the function to calculate the matrix from a raw
% dataset rather than probabilities, the 4th argument tells the function
% to plot the correlation matrix (0 if not)
R = bn_rankcorr(parent_cell, bbn_data, 1, 1, names);

figure(2);
% plot the bbn as a network with the rank correlation matrix values as
% weightings
bn_visualize(parent_cell, R, names, gca);

%% Inference example
% the function inference (self-explanatory) is used to make inferences on
% the network

% for example - what is the mean coral cover, CES and PES for an RCP of 2.6,
% at year 30, with guided interventions, using all sites (Prsites =3 ) and
% only seed1 and seed2 =0.0005

% nodes we know
inf_cells = [1:9];
% their values
vals = [26, 30, 1, 3, 0.0005, 0.0005, 0, 0, 0];
% make inference
% 1000,'near' -> 1000 iterations of nearest neighbour alg. to calculate
% distributions
% 'mean' -> just give the means of the distribution as output
outcome1 = inference(inf_cells, vals, R, bbn_data, 'mean', 1000, 'near');

% print results
sprintf('The average coral cover is : %1.3f, the average CES is : %1.3f, the average PES is : %1.3f', outcome1(1), outcome1(2), outcome1(3));

% make the same inference but now with incrementally increasing years and
% retrieve the full distribution
F = cell(1, 5);
figure(3);
hold on
for l = 1:5
    F{l} = inference(inf_cells, [26, l * 10, 1, 3, 0.0005, 0.0005, 0, 0, 0], R, bbn_data, 'full', 1000, 'near');
    hist_dat = F{l};
    % plot the coral cover distribution as a histogram
    h = histogram(hist_dat{1}, 'NumBins', 30, 'Normalization', 'probability');
end
legend('year 10', 'year 20', 'year 30', 'year 40', 'year 50');

% perform an inference on the interventions
% what interventions acheive cc = 0.6,ces = 0.2 and pes = 0.2 by year 50 at
% rcp 6.0, with guided interventions and all sites
F0 = inference([1:4, 10:12], [60, 10, 1, 3, 0.8, 0.2, 0.2], R, bbn_data, 'mean', 1000, 'near');
sprintf('The average intervention levels predicted are Seed1 %1.3f, Seed2 %1.3f, SRM %1.2f, As.Adt. %2.2f, Nat.Adt. %1.3f', F0)

% calculate the probability of coral cover >0.8 with no constraint on ES,
% at year 20, with rcp 6.0, with SRM = 5 and ass adpt = 6
% calculate full distribution first
F0 = inference([1:9], [60, 30, 1, 3, 0, 0, 5, 6, 0], R, bbn_data, 'full', 1000, 'near');

% find probability
dist = F0{1};
prob = sum(dist(dist > 0.8)) / sum(dist);
sprintf('The probability of coral cover >0.8 for this scenario is %1.4f', prob);