%% Loading counterfactual and intervention data
out_45 = load('./Outputs/RCP45_redux.mat');
%% Load site data
ai = ADRIA();
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/', cutoff=0.01);

area = ai.site_data.area;
%% Indices for runs of interest
tgt_ind = find((out_45.inputs.Shadeyr_start==2)&...
                (out_45.inputs.Seedyr_start==2));

% make sure counterfactual is in runs
tgt_ind_cf = find((out_45.inputs.Shadefreq==1)& ...
                  (out_45.inputs.Seedfreq==0)& ...
                  (out_45.inputs.Shadeyrs==20)& ...
                  (out_45.inputs.Seedyrs==5)& ...
                  (out_45.inputs.Shadeyr_start==2)&...
                  (out_45.inputs.Seedyr_start==2)&...
                  (out_45.inputs.Seed1==0)& ...
                  (out_45.inputs.Seed2==0)& ...
                  (out_45.inputs.fogging==0)& ...
                  (out_45.inputs.Natad==0)& ...
                  (out_45.inputs.Aadpt==0)& ...
                  (out_45.inputs.Guided==0));

%% Make data table for BBNs and polar plots, using 15 best sites and 15 worst sites for seeding

%sites = 1:561;

tab_temp_full = table2array(out_45.inputs);
tab_temp = tab_temp_full(tgt_ind,:);
N = size(tab_temp,1);

nnodes = 9;
% create storage container
dat_tab_store = zeros(N,nnodes);

% create intervention data table with:
% ['Guided','Seed1','fogging','AssAdt','Natad','CoralCover','ShelterVol','Juveniles',RCI']

count = 0;
%for ss = 1:length(sites)
for ii = 1:size(tab_temp,1)
    count = count + 1;
    %dat_tab_store(count,1) = ss;
    dat_tab_store(count,1:5) = tab_temp(ii,[1:2,4,6:7]);
    dat_tab_store(count,nnodes-3) = mean(mean(out_45.coralTaxaCover_x_p_total_cover.mean(:,:,tgt_ind(ii))-out_45.coralTaxaCover_x_p_total_cover.mean(:,:,tgt_ind_cf),1).*area',2);
    dat_tab_store(count,nnodes-2) = mean(mean(out_45.shelterVolume.mean(:,:,tgt_ind(ii))-out_45.shelterVolume.mean(:,:,tgt_ind_cf),1).*area',2);
    dat_tab_store(count,nnodes-1) = mean(mean(out_45.coralTaxaCover_x_p_juveniles.mean(:,:,tgt_ind(ii))-out_45.coralTaxaCover_x_p_juveniles.mean(:,:,tgt_ind_cf),1).*area',2);
    dat_tab_store(count,nnodes) = mean(mean(out_45.RCI.mean(:,:,tgt_ind(ii))-out_45.RCI.mean(:,:,tgt_ind_cf),1).*area',2);
end
%end

%% Thresholding data into categories for pybbn

thresholds = struct();
thresholds.Guided = {"Yes","No"};
thresholds.Seed1 = {"Yes","No"};
thresholds.fogging = {"Yes","No"};
thresholds.Aadpt = {"No","Low","High"};
thresholds.Natad = {"Yes","No"};
thresholds.dCC = {"lt_500","gt_500"};
thresholds.dSV = {"lt_500","gt_500"};
thresholds.dJu = {"lt_30","gt_30"};
thresholds.dRCI = {"lt_500","gt_500"};

bbn_data = repmat("",(size(dat_tab_store)));

% thresholds for guided variable
bbn_data((dat_tab_store(:,1)==1),1) = thresholds.Guided{1};
bbn_data((dat_tab_store(:,1)==0),1) = thresholds.Guided{2};

% thresholds for seed1 variable
bbn_data(dat_tab_store(:,2)>0,2) = thresholds.Seed1{1};
bbn_data(dat_tab_store(:,2)==0,2) = thresholds.Seed1{2};

% thresholds for fogging variable
bbn_data(dat_tab_store(:,3)>0,3)=thresholds.fogging{1};
bbn_data(dat_tab_store(:,3)==0,3)=thresholds.fogging{2};

% thresholds for aadpt variable
bbn_data(dat_tab_store(:,4)==0,4)=thresholds.Aadpt{1};
bbn_data(dat_tab_store(:,4)==4,4)=thresholds.Aadpt{2};
bbn_data(dat_tab_store(:,4)==8,4)=thresholds.Aadpt{3};

% thresholds for natad variable
bbn_data(dat_tab_store(:,5)>0,5)=thresholds.Natad{1};
bbn_data(dat_tab_store(:,5)==0,5)=thresholds.Natad{2};

% thresholds for delta coral cover variable
bbn_data(dat_tab_store(:,6)<500,6)=thresholds.dCC{1};
bbn_data(dat_tab_store(:,6)>=500,6)=thresholds.dCC{2};

% thresholds for delta shelter volume variable
bbn_data(dat_tab_store(:,7)<500,7)=thresholds.dSV{1};
bbn_data(dat_tab_store(:,7)>=500,7)=thresholds.dSV{2};

% thresholds for delta juveniles variable
bbn_data(dat_tab_store(:,8)<30,8)=thresholds.dJu{1};
bbn_data(dat_tab_store(:,8)>=30,8)=thresholds.dJu{2};

% thresholds for delta juveniles variable
bbn_data(dat_tab_store(:,9)<500,9)=thresholds.dRCI{1};
bbn_data(dat_tab_store(:,9)>=500,9)=thresholds.dRCI{2};

bbn_data = array2table(bbn_data,'VariableNames', ...
    {'Guided' 'Seed1' 'fogging' 'Aadpt' 'Natad' 'dCC' 'dSV' 'dJu' 'dRCI'});

writetable(bbn_data,'pybbn_trial_data.csv')