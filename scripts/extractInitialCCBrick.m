%% Loading brick site data and gbr reef data
countf = load('./Inputs/sR0_FORECAST_GBR_MIROC5_45.mat');
site_data = readtable('./Inputs/Brick/site_data/Brick_oversized_2019_636_reftable.csv');
gbr_siteids = load('LIST_GBR_REEFS.mat').reefs;
%% Data processing
% extract gbr and brick lats and longs
gbr_latlon = [gbr_siteids.LAT,gbr_siteids.LON];
brick_latlon = [site_data.lat,site_data.long];
% find unique reef ids in brick data
unique_rfs = unique(site_data.Reef);
% storage for coral cover data
TC = zeros(20,length(site_data.lat),93,6);
for l = 1:length(unique_rfs)
    % find index of the reef in the GBR data corresponding to that in the
    % brick data
    indx = find(gbr_siteids.UNIQUE_ID==unique_rfs(l));
    if ~isempty(indx)
        % if it does exist in the GBR data, use the index to extract coral
        % cover from gbr data. Replicate this for the number of sites in
        % that reef.
        TC(:,site_data.Reef==unique_rfs(l),:,:) = repmat(countf.coral_cover_per_taxa(:,indx,:,:),1,sum(site_data.Reef==unique_rfs(l)),1,1);
    else
        % if it doesn't exist in the data, find the closest points using
        % lats and longs and Euclidean distances 
        orig_ind = find(site_data.Reef==unique_rfs(l));
        k = dsearchn(gbr_latlon,brick_latlon(orig_ind,:));
        TC(:,site_data.Reef==unique_rfs(l),:,:) = countf.coral_cover_per_taxa(:,k,:,:);
    end
end

filename = './Inputs/Brick/site_data/coralCoverBrickData.mat'
save(filename,"TC");
