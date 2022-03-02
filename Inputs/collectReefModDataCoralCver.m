% load coral cover data
TC_26 = load('./Inputs/sR0_FORECAST_GBR_MIROC5_26.mat','coral_cover_per_taxa','years');
TC_45 = load('./Inputs/sR0_FORECAST_GBR_MIROC5_45.mat','coral_cover_per_taxa');
TC_60 = load('./Inputs/sR0_FORECAST_GBR_MIROC5_60.mat','coral_cover_per_taxa');

% load site ids
site_ids_rm = load('./Inputs/Cairns/Site_data/LIST_CAIRNS_REEFS').reefs190.Reef_ID;

% find indexes for years corresponding to 2025 to 2035
ind =  find(ismember(TC_26.years,[2025.0:1:2035.0]));

% select correct years and sites and average over species and climate
% replicates
TC_26_f = squeeze(mean(mean(TC_26.coral_cover_per_taxa(:,site_ids_rm,ind,:),1),4));
TC_45_f = squeeze(mean(mean(TC_45.coral_cover_per_taxa(:,site_ids_rm,ind,:),1),4));
TC_60_f = squeeze(mean(mean(TC_60.coral_cover_per_taxa(:,site_ids_rm,ind,:),1),4));

save('./Inputs/Cairns/Site_data/InitCoralCover26.mat','TC_26_f');
save('./Inputs/Cairns/Site_data/InitCoralCover45.mat','TC_45_f');
save('./Inputs/Cairns/Site_data/InitCoralCover60.mat','TC_60_f');
