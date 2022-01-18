% Create ADRIA Interface object
ai = ADRIA();

% Get default parameters
multirun_params = ai.raw_defaults;

% Collect details of parameters that can be varied
inter_opts = ai.interventions;
criteria_opts = ai.criterias;

% Get the coral parameters, which are not modified for this example
[~, ~, coral_params] = ai.splitParameterTable(multirun_params);

% Values that are constant across all simulations
sim_constants = ai.constants;

% retrieve shell variables for interventions
guided = getenv('Guided');
prsites = getenv('PrSites');
seed1 = getenv('Seed1');
seed2 = getenv('Seed2');
srm = getenv('SRM');
aadpt = getenv('Aadpt');
natad = getenv('Natad');

% testing
% guided = 1;
% algind = 2;
% seed1 = 1000;
% seed2 = 1000;
% srm = 12;
% aadpt = 12;
% natad = 0.025;

% assign to ADRIA class parameter table
multirun_params(1,'Guided') = {algind};
multirun_params(1,'Seed1') = {seed1};
multirun_params(1,'Seed2') = {seed2};
multirun_params(1,'SRM') = {srm};
multirun_params(1,'Aadpt') = {aadpt};
multirun_params(1,'Natad') = {natad};

% get shell variable for RCP and number of intervention runs
count = getenv('Count');
rcp = getenv('RCP');

% testing
%  rcp = 45;
%  count = 1;

% assign RCP to ADRIA class variable and load connectivity data
ai.constants.RCP = rcp;
ai.loadConnectivity('MooreTPMean.xlsx', cutoff = 0.1);

% number of simulations for each intervention
Nreps = 50;

% run ADRIA
Y = ai.run(multirun_params,sampled_values = false,nreps = Nreps);
Y = squeeze(Y);

% create filenames for saving outputs and corresponding intervention
% variables
filename1 = sprintf('ADRIA_multirun_pars%0.0f.nc',count);
filename2 = sprintf('ADRIA_multirun_outputs%0.0f.nc',count);

% create intervention vector
parvec = [guided,algind,seed1,seed2,srm,aadpt,natad];

% create nc files and write data into nc files
nccreate(filename1,'output','Dimensions',{'time',sim_constants.tf,'corals',length(ai.coral_spec.taxa_id),'sites',length(sim_constants.psgC),'runs',Nreps})
nccreate(filename2,'intvec','Dimensions',{'x',1,'y',7})
ncwrite(filename1,'output',Y)
ncwrite(filename2,'intvec',parvec)
