%% Prepares ReefMod output data for analyses in ADRIA, including translation to ReefConditionMetrics

%% Settings
criteria_thr = 0.99;  %threshold for how many criteria need to be met in order for a condition category to be satisfied. 
COTS_outbreak_threshold = 0.2; 
metrics = 2 % [1,2,3,4,5,6,7,8];  % see below for metrics implemented

%% Structure of the ReefConditionIndex when completed here ('comp' means complementary, i.e. 1-metric)
%               totcov: [448×85 single]
%        coralevenness: [448×85 single]
%           sheltervol: [448×85×6 double]
%    coraljuv_relative: [448×85 single]
%                  CCA: [448×85 single]
%         COTSrel_comp: [448×85 single]
%              MA_comp: [448×85 single]
%          rubble_comp: [448×85 single]
%                reefs: [448×7 table]

%% load reefmod data output file
reefmod_data = load('sR0_FORECAST_CAIRNS_MIROC5_45.mat'); %loads example data file produce by ReefMod
% Example structure for ReefMod
%                  COTS_mantatow: [10×448×85 single]
%          coral_cover_lost_COTS: [10×448×84×6 single]
%     coral_cover_lost_bleaching: [10×448×84×6 single]
%      coral_cover_lost_cyclones: [10×448×84×6 single]
%           coral_cover_per_taxa: [10×448×85×6 single]
%                  inputfilename: 'R0_FORECAST_CAIRNS_MIROC5_45'
%             macroEncrustFleshy: [10×448×85 single]
%                      macroTurf: [10×448×85 single]
%             macroUprightFleshy: [10×448×85 single]
%                  nb_coral_adol: [5-D uint16]
%                 nb_coral_adult: [5-D uint16]
%                   nb_coral_juv: [5-D uint16]
%                    nongrazable: [10×448 single]
%                          reefs: [448×7 table]
%                         rubble: [10×448×85 single]
%                          years: [1×85 double]

%% We need to extract and convert as many of these mertics as we can such that they can inform the Reef Condition Metric (RCI)
% The metrics we are particulartly interested here as direct outputs are flagged by a YES.
% Derived metrics, or metrics that require further elicitation and data, are flagged with NO or NOT YET.
% 1.	Relative coral cover            YES - as sum of relative covers for each group)
% 2.	Evenness of  coral groups       YES - based on the evenness of the six groups)  
% 3.	Coral species richness          NOT YET -  requires further analysis of expert data)
% 4.	Abundance of coral recruits     YES, as numbers of coral juveniles
% 5.	Relative cover of CCAs -        YES as 1 - total coral cover, non-grazable and macroalgae
% 6.	Abundance of fish <10 cm        MAYBE, approximate via RM_colony_sheltervol.m
% 7.	Richness of small fish  -       NOT YET, requires further analysis of expert data
% 8.	Abundance of fish >10cm         MAYBE, approximate via RM_colony_sheltervol.m
% 9.	Richness of large fish          NOT YET, requires further analysis of expert data)
% 10.	Abundance of juvenile fish      NO, requires monitoring data
% 11.	CoTS rel to outbreak            YES, based on COTS_mantatow 
% 12.	Relative cover of macroalgae    YES, directly as the sum of three groups of macroalgae
% 13.	Relative cover of coral rubble  YES directly using "rubble"

%% Average over simulations
field_names = {'COTS_mantatow', 'coral_cover_per_taxa', 'macroEncrustFleshy', 'macroTurf', ... 
    'macroUprightFleshy', 'nb_coral_adol', 'nb_coral_adult','nb_coral_juv', 'nongrazable', 'rubble'};
reefmod_data2 = struct(); % set up new scalar structure
for k = 1:numel(field_names) % step through fields
    F = field_names{k}; %assign field names to new structure
    reefmod_data2.(F) = squeeze(mean(reefmod_data.(F),1)); %average over simulations and reduce to two dimensions
end

%% Calculate coral evenness
rci.totcov = sum(reefmod_data2.coral_cover_per_taxa,3)/100; %first calculate total coral cover
rci.covers = reefmod_data2.coral_cover_per_taxa/100; %then package relative covers into the rci structure
rci.coralevenness = coral_evenness_fun(rci);  %call function that calculates the evenness of coral groups
rci.coralevenness = single(rci.coralevenness); % change to single type

%% Coral juveniles
rci.coraljuv = sum(reefmod_data2.nb_coral_juv,[3:4]);  %calculate sum of coral juveniles across size classes and coral groups 
maxcoraljuv = max(rci.coraljuv,[],'All'); %find max juvenile density 
rci.coraljuv_relative = single(rci.coraljuv/(maxcoraljuv));  %convert absolute juvenile numbers to relative measures

%% Estimate shelter volume based on coral group, colony size and cover 
allcorals(:,:,:,1:4) = reefmod_data2.nb_coral_juv;
allcorals(:,:,:,5:17) = reefmod_data2.nb_coral_adol;
allcorals(:,:,:,18:26) = reefmod_data2.nb_coral_adult;
shvol = colony_sheltervolume_from_reefmod;  %call function that converts coral groups and sizes to colony shelter volume
for sp = 1:6
    for sizebin = 1:26  %26 coral size classes in ReefMod
        shvolrel(:,:,sp,sizebin) = allcorals(:,:,sp,sizebin).*shvol(sp,sizebin);
    end
end
sumshv = squeeze(sum(shvolrel,[4,5]));
shvmax = max(sumshv,[],'All');
rci.sheltervol = sumshv./shvmax;  %shelter volume relative to max
%% Amalgamate the three types of macroalgae into one variable and convert to proportion
reefmod_data2.MA(:,:,1) = reefmod_data2.macroEncrustFleshy; 
reefmod_data2.MA(:,:,2) = reefmod_data2.macroTurf; 
reefmod_data2.MA(:,:,3) = reefmod_data2.macroUprightFleshy; 
reefmod_data2.MA = squeeze(sum(reefmod_data2.MA, 3)); %sum across algal types and reduce to three dimensions

%% Crustose coralline algae (CCAs)
%YM notes
%CCA is different than nongrazable. Nongrazable is a mix of sand/sponges, ie substrates that cannot be colonized by corals or algae.
%CCA can be obtained as 100 - all corals - all algae - nongrazable. Don't include rubble here because it's not treated as a substrate.
rci.CCA = 1 - rci.totcov - reefmod_data2.nongrazable'/100 - reefmod_data2.MA;
rci.CCA(rci.CCA<0) = 0;
%% COTS abundance above critical threshold for outbreak density and relative to max observed
reefmod_data2.COTSrel = reefmod_data2.COTS_mantatow./COTS_outbreak_threshold; %max(RMdata.COTS_mantatow,[],'All');
reefmod_data2.COTSrel(reefmod_data2.COTSrel<0) = 0;
reefmod_data2.COTSrel(reefmod_data2.COTSrel>1) = 1;

%% Convert COTS, macroalgae and rubble to their complementary values 
rci.COTSrel_comp = 1 - reefmod_data2.COTSrel;  %complementary of COTS
rci.MA_comp = (100 - reefmod_data2.MA)/100; %complementary of macroalgae
rci.rubble_comp = (100 - reefmod_data2.rubble)/100; %complementary of rubble

%% Add reefs to the structure, delete redundant fields, and reorganise
rci.reefs = reefmod_data.reefs;
rci = rmfield(rci,'coraljuv'); %original field deleted as it's replaced with relative density of four size classes
rci = rmfield(rci,'covers'); %original field deleted as it's replaced with derived metrics
fieldorder = {'totcov','coralevenness','sheltervol','coraljuv_relative','CCA','COTSrel_comp', 'MA_comp','rubble_comp','reefs'};
rci = orderfields(rci,fieldorder);

%% Compare ReefMod data against reef condition criteria provided by expert elicitation process (questionnaire)
F = readtable('ReefConditionCriteria'); %in ADRIA input files, note that evenness is omitted
rci_crit = table2array(F(:,2:end));
rci_crit(:,1:3) = rci_crit(:,1:3);
reefcondition = zeros(448,85);
%Start loop for crieria vs metric comparisons
    for reef = 1:448
        for t = 1:85
            M = [rci.totcov(reef,t), ... 
                rci.coralevenness(reef,t), ...
                rci.sheltervol(reef,t), ... 
                 rci.coraljuv_relative(reef,t), ...
                 rci.CCA(reef,t), ...
                 rci.COTSrel_comp(reef,t), ...
                 rci.MA_comp(reef,t), ...
                 rci.rubble_comp(reef,t)];
            A = sum(M(metrics)> rci_crit(1,metrics),'omitnan')/numel(metrics);
            B = sum(M(metrics)> rci_crit(2,metrics),'omitnan')/numel(metrics);
            C = sum(M(metrics)> rci_crit(3,metrics),'omitnan')/numel(metrics);
            D = sum(M(metrics)> rci_crit(4,metrics),'omitnan')/numel(metrics);
            E = sum(M(metrics)> rci_crit(5,metrics),'omitnan')/numel(metrics);
           
                if A > criteria_thr
                reefcondition(reef,t) = 0.9; %representative of very good
                 elseif B > criteria_thr && A < criteria_thr
                reefcondition(reef,t) = 0.7; %representative of good
                elseif C > criteria_thr && A < criteria_thr && B < criteria_thr
                 reefcondition(reef,t) = 0.5; %representative of fair
                 elseif D > criteria_thr && C < criteria_thr  && A < criteria_thr && B < criteria_thr
                reefcondition(reef,t) = 0.3; %representative of poor
                else 
                reefcondition(reef,t) = 0.1; %
            end
        end
    end
%% Plot results 
places = table2array(reefmod_data.reefs(:,3:5)); %extract lats and lons from ReefMod file
lons = places(:,2);
lats = places(:,1);
reefarea = places(:,3);
figure;
    tiledlayout(1,4,'TileSpacing','compact')
for p = 1:4
     ax(p) = nexttile;
colormap(flipud(turbo))
bubblechart(lons,lats,reefarea/1000, median(reefcondition(:,p*20-19:p*20),2));
bubblesize([3 30])
caxis([0.1,0.9]);
end
colorbar('EastOutside')

     
