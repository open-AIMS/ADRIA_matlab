%% Extract bleaching mortality from ReefMod in the Cairns region

F = load('LAYER_MORTALITY_BLEACHING_MIROC5_45.MAT');
bl = F.BLEACH_MORT;

%Note: focusing on bleaching in Acropora
bl_Acr = bl(:,:,:,1:3);
bl_Acr = squeeze(mean(bl_Acr,4));

R = load('LIST_CAIRNS_REEFS.mat');
lat = R.reefs190.LAT;
lon = R.reefs190.LON;
reefID = R.reefs190.Reef_ID;

bleach_mort = bl_Acr(:,reefID,:);
bleach_mort60 = permute(bleach_mort,[3,2,1]); %dimensions years, reefs, sims
mbleach_mort = squeeze(mean(bleach_mort60,3));

save ReefModBleachMortCairnsRCP45 bleach_mort lat lon reefID

% figure;
% Year = 10;
% geoscatter(lat,lon,30,mbleach_mort(Year,:),'filled')
% colorbar;
% caxis([0, 1]);
