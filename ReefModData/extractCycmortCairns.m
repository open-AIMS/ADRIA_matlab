%extract bleaching mortality from reefmod in Cairns

F = load('LAYER_MORTALITY_CYCLONES.MAT');
m = F.CYCL_MORT;
m_Acr = m(:,:,:,1:3);  %Note: focus on Acropora
m_Acr = squeeze(mean(m_Acr,4));

R = load('LIST_CAIRNS_REEFS.mat');
lat = R.reefs190.LAT;
lon = R.reefs190.LON;
reefID = R.reefs190.Reef_ID;

cyc_mort = m_Acr(:,reefID,:);
cyc_mort = permute(cyc_mort,[3,2,1]); %dimensions years, reefs, sims
mcyc_mort = squeeze(mean(cyc_mort,3));

save ReefModCycMortCairns cyc_mort lat lon reefID

% figure;
% Year = 20
% geoscatter(lat,lon,30,mcyc_mort(Year,:),'filled')
% colorbar;
% caxis([0, inf]);

