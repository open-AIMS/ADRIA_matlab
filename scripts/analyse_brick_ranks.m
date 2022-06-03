%% load data for RCP 45
data = load('./Outputs/RCP45_redux.mat')


%% find average coral cover for each time step for seeding with 4 dhw
indx = (data.inputs.Seed1==500000)&(data.inputs.Seed2==500000)& ...
    (data.inputs.fogging==0);

av_CC_t = mean(mean(data.coralTaxaCover_x_p_total_cover.mean(:,:,indx),3),1);
av_SV_t = mean(mean(data.shelterVolume.mean(:,:,indx),3),1);
av_Ju_t = mean(mean(data.coralTaxaCover_x_p_juveniles.mean(:,:,indx),3),1);
av_RCI_t = mean(mean(data.RCI.mean(:,:,indx),3),1);

[~, sortIndex] = sort(av_CC_t, 'descend');  
maxIndex = sortIndex(1:10);

seed_sites = squeeze(data.seed_log(:,1,:,indx));
counts = zeros(1,561);
for k = 1:561
    counts(k) = sum(sum(seed_sites(:,k,:)>0));
end

sites_thesh = 1000;
figure(2)
subplot(2,2,1)
hold on 
plot(1:561,counts)
plot(find(counts>sites_thesh),counts(find(counts>sites_thesh)),'r*')
plot(maxIndex,counts(maxIndex),'b*')
xlabel('Sites','Fontsize',20,'Interpreter','latex')
ylabel('Times selected','Fontsize',20,'Interpreter','latex')
subplot(2,2,2)
hold on
plot(1:561,av_CC_t)
plot(find(counts>sites_thesh),av_CC_t(find(counts>sites_thesh)),'r*')
plot(maxIndex,av_CC_t(maxIndex),'b*')
xlabel('Sites','Fontsize',20,'Interpreter','latex')
ylabel('Coral cover (average)','Fontsize',20,'Interpreter','latex')
subplot(2,2,3)
hold on
plot(1:561,av_SV_t)
plot(find(counts>sites_thesh),av_SV_t(find(counts>sites_thesh)),'r*')
plot(maxIndex,av_SV_t(maxIndex),'b*')
xlabel('Sites','Fontsize',20,'Interpreter','latex')
ylabel('Shelter Volume (average)','Fontsize',20,'Interpreter','latex')
subplot(2,2,4)
hold on
plot(1:561,av_Ju_t)
plot(find(counts>sites_thesh),av_Ju_t(find(counts>sites_thesh)),'r*')
plot(maxIndex,av_Ju_t(maxIndex),'b*')
xlabel('Sites','Fontsize',20,'Interpreter','latex')
ylabel('Juveniles (average)','Fontsize',20,'Interpreter','latex')


%% Test correlations with data used as heuristics
n_reps = 20;
% Load site specific data
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/2015/');
ai.loadCoralCovers("./Inputs/Brick/site_data/coralCoverBrickTruncated.mat");
ai.loadDHWData('./Inputs/Brick/DHWs/dhwRCP45.mat', n_reps);

% want to create an nsites by nheuristics matrix to calculate correlation
% plot from

init_CC = mean(ai.init_coral_cover,1);
dhws = squeeze(mean(ai.dhw_scens,3));
dhws = dhws(25,:)/max(dhws(25,:));
prop_cover = ((ai.site_data.k'/100)-init_CC)./(ai.site_data.k'/100);
centr = (ai.site_ranks.C1'.*init_CC.*ai.site_data.area');
centr = centr/max(centr);
CC_t = mean(data.coralTaxaCover_x_p_total_cover.mean(:,:,indx),3);
CC_t = CC_t(25,:);
SV_t = mean(data.shelterVolume.mean(:,:,indx),3);
SV_t = SV_t(25,:);
Ju_t = mean(data.coralTaxaCover_x_p_juveniles.mean(:,:,indx),3);
Ju_t = Ju_t(25,:);
A = [init_CC',dhws',prop_cover',centr',CC_t',SV_t',Ju_t'];
[R,P] = corrcoef(A)
