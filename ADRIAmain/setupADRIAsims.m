function [wavedisttime, dhwdisttime] = setupADRIAsims(Interv,params,nsites)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % This setup script does one or two things.
    % 1. Pulls in environmental data files (connectivity, DHWs and significant wave heights)
    % for different environmental conditions. % The script extracts this info
    % for the 26 example sites and generates forward projections based on RCP (for DHW only). 
    % 2. Or loads pre-extracted and saved environmental data. %All environmental simulations 
    % are run in a previsous setup script and saved as mat files to allow this 
    % main script (runADRIAsims) to simply draw in the stored simulations. 
    %
    % In each simulation ADRIA generates a new environmental future for both the counterfactual and for the intervention
    % portfolio. This helps us to understand the net cumulative benefits (or disbenefits) of each 
    % intervention strategy and choice of sites. This latter analysis is handled in analyseADRIA.

    
    cd ../Inputs
    %% Simulate future wave exposure patterns from Puotinen and Callaghan SWH data
    swhtbl = readtable('swhMoore_interp.xlsx', 'PreserveVariableNames',true); % import Marji's significant wave heights 
    
    % col: SiteID, SiteAddress, Lon, Lat, Hs70, Hs80, Hs90, Hs95, Hs96, Hs97, Hs98, Hs99, Hs100
    swh90 =  table2array(swhtbl(:,7)); % we use swhs within the 90 percentile  
    swh100 = table2array(swhtbl(:,13));  % swhs within the 100 percentile (always) 
    waveexp90 = swh90/(max(swh100)); % routine wave exposure rel to max 
    mriskwaves = swh90/(7*max(swh90));  % placeholder conversion to mortality risks based on Madin paper
    wavedisttime = 0.05*randn(params.tf,nsites,Interv.sims)+ waveexp90'; % projected spatial, 
    % temporal and sims distribution of wave exposures assuming 5% variation ? very much a placeholder until we get real data.
    
    wavedisttime(wavedisttime>1) = 1; % constrain below unity
    wavedisttime(wavedisttime<0) = 0; % constrain to positive values

    %% Simulate future heat stress data based on Robson RECOM runs
    % generate DHW time series
    % Data is structure with resdhwsites, dhw_surf and z
    F = load('MooreDHWs'); % load data that are previously generated
    z = F.z; % bathymetry
    mdhwdist0 = mean(F.resdhwsites(:,5:7),2)';
    sdhwdist0 =std(F.resdhwsites(:,5:7),0,2)';
    dhwdisttime = zeros(params.tf,nsites,Interv.sims);
    
    cd ../ADRIAfunctions
    
    for sim = 1:Interv.sims
        dhwdisttime(:,:,sim) = ADRIA_DHWprojectfun(params.tf,nsites,mdhwdist0,...
            sdhwdist0,params.dhwmax25,Interv.RCP,params.wb1,params.wb2);
    end
    dhwdisttime(dhwdisttime <=0) = 0;
    dhwdisttime(dhwdisttime > params.DHWmaxtot) = params.DHWmaxtot;
