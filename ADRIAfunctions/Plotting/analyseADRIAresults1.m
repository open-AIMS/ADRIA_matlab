function analyseADRIAresults1(metrics)

%% Convert coral outputs to scope for ES provision and display selected  distributions (violin plots) and trajectories for each intervention

% Presents summary results from runADRIAsims

CultES = metrics.CultES;
ProvES = metrics.ProvES;
dCultES = metrics.dCultES;
dProvES = metrics.dProvES;
tmp_int_size = size(CultES);
Nint = tmp_int_size(3);

% to ES proxies and deltaES proxies (relative to counterfactual)

%% request user input
prompt = {'Results years of interest:', ... % choose whole range or any part of range
    'Sites of interest:', ... % these are reefs sites i the study
    'Interventions of Interest:'}; % choose any intervention, 1 or many
dlgtitle = 'Input';
dims = [1, 50];
definput = {'1:25', '1:26', strcat('1:', num2str(Nint))}; %default input values
answer = inputdlg(prompt, dlgtitle, dims, definput);
% RCP = str2double(answer{1});
yoi = str2num(answer{1}); %years of interest
soi = str2num(answer{2}); %sites of interest
ioi = str2num(answer{3}); %interventions of interest
%row_cf = str2num(answer{4}); %points to the counterfactual - i.e. the do nothing scenario

CultES = CultES(yoi, soi, ioi, :); %cultural ecosystem services for years, sites and interventions of interest
ProvES = ProvES(yoi, soi, ioi, :); %provisioning ecosystem services for years, sites and interventions of interest
dCultES = dCultES(yoi, soi, ioi, :); %delta cultural ecosystem services for years, sites and interventions of interest
dProvES = dProvES(yoi, soi, ioi, :); %delta provisining ecosystem services for years, sites and interventions of interest

N = size(CultES, 3); % number of rows in the intervention table

%% Display distributions across interventions

%meancov = squeeze(mean(covsim_t_sp_sites(years,:,:,:,:),(1:3)));
% %mcovsim = squeeze(mean(covsim(years,:,psgA0,:,:),(1:3)));
% mTC = squeeze(mean(TC(yoi,soi,:,:),(1:2)));
% %mC = squeeze(mean(C(years,:,:,:,:),(1:2)));
% mE = squeeze(mean(E(yoi,soi,:,:),(1:2)));
% mS = squeeze(mean(S(yoi,soi,:,:),(1:2)));
%
% mdTC = squeeze(mean(dTC,(1:2)));
% %mC = squeeze(mean(C(years,:,:,:,:),(1:2)));
mCultES = squeeze(mean(CultES, (1:2)));
mProvES = squeeze(mean(ProvES, (1:2)));
mdCultES = squeeze(mean(dCultES, (1:2)));
mdProvES = squeeze(mean(dProvES, (1:2)));

mCultESsites = squeeze(mean(CultES, 2));
mProvESsites = squeeze(mean(ProvES, 2));

%% Need to work on this example to collapse sites and years without taking means

%%
% *Display distributions of CultES and ProvES*

figure;
distributionPlot(mCultES(1:N, :)', 'showMM', 6, 'Color', [0.6, 0.6, 0.6])
title('Scope for Cultural ES');
axis([0, N + 1, -inf, inf]);
set(gca, 'FontSize', 18);

figure;
distributionPlot(mProvES(1:N, :)', 'showMM', 6, 'Color', [0.6, 0.6, 0.6])
title('Scope for Provisioning ES');
axis([0, N + 1, -inf, inf]);
set(gca, 'FontSize', 18);

% figure;
% distributionPlot(mdCultES(1:N,:)', 'showMM',3,'Color',[0.6 0.6 0.6])
% title('Scope for Cultural ES');
% axis([0,N+1,-inf,inf]);
% set(gca,'FontSize',18);
%
% figure;
% distributionPlot(mdProvES(1:N,:)', 'showMM',3,'Color',[0.6 0.6 0.6])
% title('Scope for Cultural ES');
% axis([0,N+1,-inf,inf]);
% set(gca,'FontSize',18);

%%

figure('Position', [300, 30, 900, 600])
cols = 4;
rows = ceil(N/cols);
for int = 1:N
    subplot(rows, cols, int)
    plot_distribution_prctile(yoi, squeeze(mCultESsites(:, int, :))', 'Prctile', [25, 50, 75], ...
        'color', [0.2, 0.2, 0.4], 'alpha', 0.2, 'LineWidth', 0.01);
    axis([0, max(yoi), 0, 0.3]);
    %axis([0,max(yoi),0,max(mCultESsites,[],'All')]);
    title(int);
    set(gca, 'FontSize', 14);
end

%% Shadelog and seedlog (which sites were seeded and/or shaded)

% figure;
% subplot(2,2,1)
% ribbon(squeeze(mean(seedsim(:,:,:,3,:),[2,5])));view(-30,30);
% set(gca,'FontSize',12);
% %zlim([0.0 0.004])
% subplot(2,2,2)
% ribbon(squeeze(mean(seedsim(:,:,:,5,:),[2,5])));view(-30,30);
% set(gca,'FontSize',12);
% %zlim([0.0 0.004])
% subplot(2,2,3)
% ribbon(squeeze(mean(shadesim(:,:,:,2,:),[2,5])));view(-30,30);
% set(gca,'FontSize',12);
% zlim([0.0 5])
% subplot(2,2,4)
% ribbon(squeeze(mean(shadesim(:,:,:,6,:),[2,5])));view(-30,30);
% set(gca,'FontSize',12);
% zlim([0.0 5])

%%