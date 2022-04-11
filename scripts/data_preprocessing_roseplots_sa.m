%% Loading data and sites
out_45 = load('./Outputs/RCP45_redux.mat');

%bottom_p20 = load('./Inputs/above_p50.csv')
%bottom_p20= load('./Inputs/top_p20.csv')
%bottom_p20 = load('./Inputs/bottom_p20.csv');
% top_p20 = load('./Inputs/top_p20.csv');
% above_p20 = load('./Inputs/above_p50.csv');

%% Finding indices for different parameter scenarios
% guided
g1 = find(out_45.inputs.Guided == 1);
g0 = find(out_45.inputs.Guided == 0);
% seeding
seed500000 = find(out_45.inputs.Seed1 == 500000);
seed0 = find(out_45.inputs.Seed1 == 0);
% Assisted Aadpt
aadt0 = find(out_45.inputs.Aadpt == 0);
aadt4 = find(out_45.inputs.Aadpt == 4);
aadt8 = find(out_45.inputs.Aadpt == 8);
% fog
fog0 = find(out_45.inputs.fogging == 0);
fog02 = find(out_45.inputs.fogging == 0.2);
% natad
natad0 = find(out_45.inputs.Natad == 0);
natad005 = find(out_45.inputs.Natad == 0.05);
% Shadeyrs
shadeyrs20 = find(out_45.inputs.Shadeyrs == 20);
shadeyrs74 = find(out_45.inputs.Natad == 74);
% seedyr_start
seedyr_start2 = find(out_45.inputs.Seedyr_start == 2);
seedyr_start6 = find(out_45.inputs.Seedyr_start == 6);
seedyr_start11 = find(out_45.inputs.Seedyr_start == 11);
% shadeyr_start
shadeyr_start2 = find(out_45.inputs.Shadeyr_start == 2);
shadeyr_start6 = find(out_45.inputs.Shadeyr_start == 6);
shadeyr_start11 = find(out_45.inputs.Shadeyr_start == 11);
% Seedfreq
seedfreq0 = find(out_45.inputs.Seedfreq == 0);
seedfreq3 = find(out_45.inputs.Seedfreq == 3);
% Shadefreq
shadefreq1 = find(out_45.inputs.Shadefreq == 1);
shadefreq5 = find(out_45.inputs.Shadefreq == 5);

%% find overlaps bottom p20
% guided
guided0_bp20 = sum(ismember(bottom_p20,g1));
guided1_bp20 =  sum(ismember(bottom_p20,g0));
%seed 
seed500000_bp20 = sum(ismember(bottom_p20,seed500000));
seed0_bp20 =  sum(ismember(bottom_p20,seed0));
% Assisted Aadpt
aadt0_bp20 = sum(ismember(bottom_p20,aadt0));
aadt4_bp20 = sum(ismember(bottom_p20,aadt4));
aadt8_bp20 = sum(ismember(bottom_p20,aadt8));
% fog
fog0_bp20 = sum(ismember(bottom_p20,fog0));
fog02_bp20 = sum(ismember(bottom_p20,fog02));
% natad
natad0_bp20 = sum(ismember(bottom_p20,natad0));
natad005_bp20 = sum(ismember(bottom_p20,natad005));
% Shadeyrs
shadeyrs20_bp20 = sum(ismember(bottom_p20,shadeyrs20));
shadeyrs74_bp20 = sum(ismember(bottom_p20,shadeyrs74));
% seedyr_start
seedyr_start2_bp20 = sum(ismember(bottom_p20,seedyr_start2));
seedyr_start6_bp20 = sum(ismember(bottom_p20,seedyr_start6));
seedyr_start11_bp20 = sum(ismember(bottom_p20,seedyr_start11));
% shadeyr_start
shadeyr_start2_bp20 = sum(ismember(bottom_p20,shadeyr_start2));
shadeyr_start6_bp20 = sum(ismember(bottom_p20,shadeyr_start6));
shadeyr_start11_bp20 = sum(ismember(bottom_p20,shadeyr_start11));
% Seedfreq
seedfreq0_bp20 = sum(ismember(bottom_p20,seedfreq0));
seedfreq3_bp20 = sum(ismember(bottom_p20,seedfreq3));
% Shadefreq
shadefreq1_bp20 = sum(ismember(bottom_p20,shadefreq1));
shadefreq5_bp20 = sum(ismember(bottom_p20,shadefreq5));

layer1_bp20 = [guided0_bp20,seed0_bp20,aadt0_bp20,fog0_bp20,natad0_bp20,shadeyrs20_bp20,seedyr_start2_bp20,shadeyr_start2_bp20,seedfreq0_bp20,shadefreq1_bp20]';
layer2_bp20 = [guided1_bp20,seed500000_bp20,aadt4_bp20,fog02_bp20,natad005_bp20,shadeyrs74_bp20,seedyr_start6_bp20,shadeyr_start6_bp20,seedfreq3_bp20,shadefreq5_bp20]';
layer3_bp20 = [0,0,aadt8_bp20,0,0,0,seedyr_start11_bp20,shadeyr_start11_bp20,0,0]';
vars = ["Guided","Seed","Aadpt","Fog","Natad","Shadeyrs","Seedyr_start","Shadeyr_start","Seedfreq","Shadefreq"]';
bp20table = table(vars,layer1_bp20,layer2_bp20,layer3_bp20)
writetable(bp20table,'bp20.csv')
