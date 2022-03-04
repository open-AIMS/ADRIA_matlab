%% Extracts coral cover for 2026-2030 for ReefMod runs in Cairns (190 reefs)

%ReefMod file structure:

% COTS_densities: [20×3806×93×8 single]
%            COTS_mantatow: [20×3806×93 single]
%                      GCM: 'MIROC5'
%                     META: [1×1 struct]
%                  OPTIONS: [1×1 struct]
%                      RCP: '45'
%              RESTORATION: [1×1 struct]
%     coral_cover_per_taxa: [20×3806×93×6 single]
%      coral_larval_supply: [20×3806×93×6 single]
%           format_extract: 'short'
%            inputfilename: 'R0_FORECAST_GBR_MIROC5_45'
%            nb_coral_adol: [5-D uint16]
%           nb_coral_adult: [5-D uint16]
%             nb_coral_juv: [20×3806×93×6 double]
%              nongrazable: [20×3806 single]
%      record_culled_reefs: [20×3806×92 uint8]
%                    reefs: [3806×7 table]
%                   rubble: [20×3806×93 uint8]
%                    years: [1×92 double]
                   
F = load('sR0_FORECAST_GBR_MIROC5_45.mat');
coral_cover_by_group = F.coral_cover_per_taxa; %reps, reefs, years, groups
mean_coral_cover_by_group = squeeze(mean(coral_cover_by_group,1)); %squeeze out reps
mean_total_coral_cover = squeeze(sum(mean_coral_cover_by_group,3)); %squeeze out groups

R = load('LIST_CAIRNS_REEFS.mat');
lat = R.reefs190.LAT;
lon = R.reefs190.LON;
reefID = R.reefs190.Reef_ID; %reef ids for the full GBR dataset
reef_area = R.reefs190.GeomCH_2D_Area_km2; %coral habitat

%note this is my arbitrary pick of first five year - feel free to edit
cover_Cairns_all_years = mean_total_coral_cover(reefID,:);
mean_cover_Cairns_first_years = mean(cover_Cairns_all_years(:,1:5),2);
Y = mean_cover_Cairns_first_years;
cover = Y/100;

save ReefModInitialCoverCairnsRCP45 cover reef_area lat lon;
figure;
geoscatter(lat,lon,30,cover,'filled')
colorbar;
caxis([0, inf]);