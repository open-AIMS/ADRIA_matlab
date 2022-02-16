load('./Inputs/inputs_forecast/LIST_CAIRNS_REEFS.mat')
reefID = reefs190.OrderInMatrix;

% load('sR0_FORECAST_GBR_MIROC5_85.mat')
% X = coral_cover_per_taxa( : , reefID , : , : );
% 
% load('LAYER_RISK_COTS_MIROC5_26.mat')
% X = COTS_outbreaks( : , reefID , : );
load('./Inputs/inputs_forecast/GBR_CONNECT_7years.mat')
rm_connect = GBR_CONNECT(2).ACROPORA( reefID , reefID );

load('./Inputs/inputs_forecast/GBR_maxDHW_MIROC5_rcp45_2021_2099.mat')
max_DHW_RCP45 = max_annual_DHW(reefID,:);