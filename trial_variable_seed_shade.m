% Resulting table consists of N rows and D columns, where N is the
% number of scenarios (here, a single simulation with default values), and 
% D is the number of parameters.
param_table = ai.raw_defaults;

% See the "Parameter Interface" section in the documentation for
% details on how these two differ.
% sample_value_table = ai.sample_defaults;

%% 3. Modify table as desired...
param_table.alg_ind = 3;
param_table.Guided = 1;
param_table.Seed1 = 15000;
param_table.Seed2 = 50000;

%% Run ADRIA

% Specify connectivity data
ai.loadConnectivity('MooreTPmean.xlsx');

% Run a single simulation with 1 replicate
Y = ai.run(param_table, sampled_values=false, nreps=1);

%cov1 = collectMetrics(Y,coral_params,{@coralTaxaCover});
%cov2 = collectMetrics(Y,coral_params,{@coralTaxaCover});
cov3 = collectMetrics(Y,coral_params,{@coralTaxaCover});
%%
% cov1 - 5 yr delay before seeding and shading
% cov2 - no delay in seeding and shading

covs1 = cov1.coralTaxaCover;
covs2 = cov2.coralTaxaCover;
covs3 = cov3.coralTaxaCover;

figure
hold on
plot(1:25,mean(covs1.total_cover,2))
plot(1:25,mean(covs2.total_cover,2))
plot(1:25,mean(covs3.total_cover,2))
l=legend('5yr delay','No delay', '3yr delay')
set(l,'FontSize',20)
hold off

figure
hold on
plot(1:25,mean(covs1.total_cover,2))
plot(1:25,mean(covs2.total_cover,2))
plot(1:25,mean(covs3.total_cover,2))
l=legend('5yr delay','No delay', '3yr delay')
set(l,'FontSize',20)
hold off