% Resulting table consists of N rows and D columns, where N is the
% number of scenarios (here, a single simulation with default values), and 
% D is the number of parameters.

ai = ADRIA();
param_table = ai.raw_defaults;
Nreps = 30;
nyrs = 25;
% See the "Parameter Interface" section in the documentation for
% details on how these two differ.
% sample_value_table = ai.sample_defaults;

%% 3. Modify table as desired...
param_table.Guided = 4;
param_table.Seed1 = 500;
param_table.Seed2 = 500;
param_table.Aadpt = 0;
param_table.Seeddelay = 5;
param_table.Shadedelay = 5;
param_table.SRM = 0;
ai.constants.RCP = 60;

[~, ~, coral_params] = ai.splitParameterTable(param_table);
%% Run ADRIA

% Specify connectivity data
ai.loadConnectivity('MooreTPmean.xlsx');

% Run 5 yr delay
Y1 = ai.run(param_table, sampled_values=false, nreps=Nreps);

% Run 3 yr delay
param_table.Seeddelay = 3;
param_table.Shadedelay = 3;
Y2 = ai.run(param_table, sampled_values=false, nreps=Nreps);

% Run with no delay
param_table.Seeddelay = 0;
param_table.Shadedelay = 0;
Y3 = ai.run(param_table, sampled_values=false, nreps=Nreps);

% Run counterfactual
param_table.Seed1 = 0;
param_table.Seed2 = 0;
param_table.Aadpt = 0;
param_table.SRM = 0;
param_table.Seeddelay = 0;
param_table.Shadedelay = 0;
Y4 = ai.run(param_table, sampled_values=false, nreps=Nreps);

cov1 = zeros(nyrs,26,Nreps);
cov2 = zeros(nyrs,26,Nreps);
cov3 = zeros(nyrs,26,Nreps);
cov4 = zeros(nyrs,26,Nreps);

coventab1 = zeros(nyrs,26,Nreps);
coventab2 = zeros(nyrs,26,Nreps);
coventab3 = zeros(nyrs,26,Nreps);
coventab4 = zeros(nyrs,26,Nreps);

covuntab1 = zeros(nyrs,26,Nreps);
covuntab2 = zeros(nyrs,26,Nreps);
covuntab3 = zeros(nyrs,26,Nreps);
covuntab4 = zeros(nyrs,26,Nreps);

even1 = zeros(nyrs,26,Nreps);
even2 = zeros(nyrs,26,Nreps);
even3 = zeros(nyrs,26,Nreps);
even4 = zeros(nyrs,26,Nreps);

for l = 1:Nreps
    % 5 yr delay
    cov1_temp = collectMetrics(squeeze(Y1(:,:,:,:,l)),coral_params,{@coralTaxaCover,@coralSpeciesCover,@coralEvenness});
    % total taxa cover
    cov1(:,:,l) = cov1_temp.coralTaxaCover.total_cover;
    % enhanced Tab Acr
    coventab1(:,:,l) = cov1_temp.coralSpeciesCover(:,1,:);
    % enhanced Cor Acr
    covuntab1(:,:,l) = cov1_temp.coralSpeciesCover(:,2,:);
    % species total
    even1(:,:,l) = cov1_temp.coralEvenness;
    
    % 3 yr delay
    cov2_temp = collectMetrics(squeeze(Y2(:,:,:,:,l)),coral_params,{@coralTaxaCover,@coralSpeciesCover,@coralEvenness});
    % total taxa cover
    cov2(:,:,l) = cov2_temp.coralTaxaCover.total_cover;
    % enhanced Tab Acr
    coventab2(:,:,l) = cov2_temp.coralSpeciesCover(:,1,:);
    % enhanced Cor Acr
    covuntab2(:,:,l)  = cov2_temp.coralSpeciesCover(:,2,:);
    % species total
    even2(:,:,l) = cov2_temp.coralEvenness;

    % no delay
    cov3_temp = collectMetrics(squeeze(Y3(:,:,:,:,l)),coral_params,{@coralTaxaCover,@coralSpeciesCover,@coralEvenness});
    % total taxa cover
    cov3(:,:,l) = cov3_temp.coralTaxaCover.total_cover;
    % enhanced Tab Acr
    coventab3(:,:,l) = cov3_temp.coralSpeciesCover(:,1,:);
    % enhanced Cor Acr
    covuntab3(:,:,l)  = cov3_temp.coralSpeciesCover(:,2,:);
    % species total
    even3(:,:,l) = cov3_temp.coralEvenness;

    % counterfactual
    cov4_temp = collectMetrics(squeeze(Y4(:,:,:,:,l)),coral_params,{@coralTaxaCover,@coralSpeciesCover,@coralEvenness});
    % total taxa cover
    cov4(:,:,l) = cov4_temp.coralTaxaCover.total_cover;
    % enhanced Tab Acr
    coventab4(:,:,l) = cov4_temp.coralSpeciesCover(:,1,:);
    % enhanced Cor Acr
    covuntab4(:,:,l)  = cov4_temp.coralSpeciesCover(:,2,:);
    % species total
    even4(:,:,l) = cov4_temp.coralEvenness;
end

%%
% cov1 - 5 yr delay before seeding and shading
% cov2 - 3 yr delay in seeding and shading
% cov3 - no delay in seeding and shading
yrs = 1:nyrs;

figure(1)
subplot(2,2,1)
hold on
plot_distribution_prctile(yrs, (squeeze(mean(cov1,2))-squeeze(mean(cov4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [255/255, 51/255, 51/255], 'alpha', 0.2, 'LineWidth', 0.01); %red
plot_distribution_prctile(yrs, (squeeze(mean(cov2,2))-squeeze(mean(cov4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [153/255, 255/255, 51/255], 'alpha', 0.2, 'LineWidth', 0.01); %green 
plot_distribution_prctile(yrs, (squeeze(mean(cov3,2))-squeeze(mean(cov4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [51/255, 153/255, 255/255], 'alpha', 0.2, 'LineWidth', 0.01); %blue

xlabel('Years','Fontsize',20)
ylabel('Coral cover','Fontsize',20)
title(sprintf('Total Cover, RCP %1.1f',ai.constants.RCP/10),'Fontsize',20)
hold off

subplot(2,2,2)
%figure(2)
hold on
plot_distribution_prctile(yrs, (squeeze(mean(coventab1,2))-squeeze(mean(coventab4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [255/255, 51/255, 51/255], 'alpha', 0.2, 'LineWidth', 0.01);
plot_distribution_prctile(yrs, (squeeze(mean(coventab2,2))-squeeze(mean(coventab4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [153/255, 255/255, 51/255], 'alpha', 0.2, 'LineWidth', 0.01);
plot_distribution_prctile(yrs, (squeeze(mean(coventab3,2))-squeeze(mean(coventab4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [51/255, 153/255, 255/255], 'alpha', 0.2, 'LineWidth', 0.01);

xlabel('Years','Fontsize',20)
ylabel('Coral cover','Fontsize',20)
title(sprintf('Enhanced Tab. Acr., RCP %1.1f',ai.constants.RCP/10),'Fontsize',20)
hold off

subplot(2,2,3)
%figure(3)
hold on
plot_distribution_prctile(yrs, (squeeze(mean(covuntab1,2))-squeeze(mean(covuntab4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [255/255, 51/255, 51/255], 'alpha', 0.2, 'LineWidth', 0.01);
plot_distribution_prctile(yrs, (squeeze(mean(covuntab2,2))-squeeze(mean(covuntab4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [153/255, 255/255, 51/255], 'alpha', 0.2, 'LineWidth', 0.01);
plot_distribution_prctile(yrs, (squeeze(mean(covuntab3,2))-squeeze(mean(covuntab4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [51/255, 153/255, 255/255], 'alpha', 0.2, 'LineWidth', 0.01);

xlabel('Years','Fontsize',20)
ylabel('Coral cover','Fontsize',20)
title(sprintf('Unenhanced Tab. Acr., RCP %1.1f',ai.constants.RCP/10),'Fontsize',20)
hold off

subplot(2,2,4)
%figure(4)
hold on
plot_distribution_prctile(yrs, (squeeze(mean(even1,2))-squeeze(mean(even4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [255/255, 51/255, 51/255], 'alpha', 0.2,'LineWidth', 0.01);
plot_distribution_prctile(yrs,(squeeze(mean(even2,2))-squeeze(mean(even4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [153/255, 255/255, 51/255], 'alpha', 0.2, 'LineWidth', 0.01);
plot_distribution_prctile(yrs,  (squeeze(mean(even3,2))-squeeze(mean(even4,2)))', 'Prctile', [25, 50, 75], ...
    'color', [51/255, 153/255, 255/255], 'alpha', 0.2, 'LineWidth', 0.01);

xlabel('Years','Fontsize',20)
ylabel('Evenness','Fontsize',20)
title(sprintf('Evenness, RCP %1.1f',ai.constants.RCP/10),'Fontsize',20)
hold off