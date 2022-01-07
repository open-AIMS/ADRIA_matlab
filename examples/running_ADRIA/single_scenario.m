% Example script running a single scenario.

rng(101) % set seed for reproducibility

% Collect details of parameters that can be varied
inter_opts = interventionDetails();
criteria_opts = criteriaDetails();

% Parameters that are treated as constants
coral_params = coralParams();
sim_constants = simConstants();


%% Ask for which MCDA algorithm to use
dims = [1, 50];
dlgtitle = 'MCDA Options';
definput = {'1'};
prompt = {'MCDA Algorithm (1 - 4)'};
mcda_alg = inputdlg(prompt, dlgtitle, dims, definput);
alg_ind = str2num(mcda_alg{1});

%% Ask for interventions
prompt = cell(height(inter_opts), 1);
for n = 1:height(inter_opts)
    bnds = inter_opts.raw_bounds(n, :);  % range of values
    bs = num2str(bnds(1));
    be = num2str(bnds(2));
    prompt(n) = {strcat(inter_opts.name(n), " (", bs, " - ", be, ")")};
end

dims = [1, 50];
dlgtitle = 'Intervention Options';
definput = string(inter_opts.raw_defaults);
user_interv_opts = inputdlg(prompt, dlgtitle, dims, definput);

%% Ask for criteria weights
prompt = cell(height(criteria_opts), 1);
for n = 1:height(criteria_opts)
    bnds = criteria_opts.raw_bounds(n, :);
    bs = num2str(bnds(1));
    be = num2str(bnds(2));
    prompt(n) = {strcat(criteria_opts.name(n), " (", bs, " - ", be, ")")};
end

dlgtitle = 'Criteria Options';
definput = string(criteria_opts.raw_defaults);
user_criteria_opts = inputdlg(prompt, dlgtitle, dims, definput);

%% Ask for simulation details (skipping psg, beta, and p)
sim_names = fieldnames(sim_constants);
prompt = cell(height(sim_names), 1);
definput = zeros(height(sim_names), 1);
for n = 1:length(sim_names)
    field_name = sim_names(n);
    if contains(field_name, 'psg') || ...
            contains(field_name, 'beta') || ...
            contains(field_name, 'gompertz')
        continue
    end

    prompt(n) = field_name;
    definput(n) = sim_constants.(field_name{1});
end

prompt = prompt(~cellfun('isempty',prompt));
definput = string(definput(~definput==0));

dlgtitle = 'Simulation Options';
user_sim_opts = inputdlg(prompt, dlgtitle, dims, definput);

% Assign new values (again, skipping psg, beta, and p)
new_sim_opts = struct();
i = 1;
for n = 1:length(sim_names)
    field_name = sim_names(n);
    
    is_psg = contains(field_name, 'psg');
    is_beta = contains(field_name, 'beta');
    is_p = contains(field_name, 'gompertz');
    if is_psg || is_beta || is_p
        new_sim_opts.(field_name{1}) = sim_constants.(field_name{1});
        continue
    end

    new_sim_opts.(field_name{1}) = str2num(user_sim_opts{i});
    i = i + 1;
end



%% Prep user-defined simulation into tables
% Convert string inputs to numbers
user_interv_opts = cellfun(@str2num, user_interv_opts);
user_criteria_opts = cellfun(@str2num, user_criteria_opts);

new_interv_opts = array2table(user_interv_opts', 'VariableNames', inter_opts.name);
new_criteria_opts = array2table(user_criteria_opts', 'VariableNames', criteria_opts.name);


%% Load site data
[TP_data, site_ranks, strongpred] = siteConnectivity('MooreTPmean.xlsx', new_sim_opts.con_cutoff);

%% setup for the geographical setting including environmental input layers
% Load wave/DHW scenario data
% Generated with generateWaveDHWs.m
% TODO: Replace these with wave/DHW projection scenarios instead
fn = strcat("Inputs/example_wave_DHWs_RCP", num2str(new_sim_opts.RCP), ".nc");
wave_scens = ncread(fn, "wave");
dhw_scens = ncread(fn, "DHW");

% Select random subset of RCP conditions WITHOUT replacement
n_rep_scens = length(wave_scens);
rcp_scens = datasample(1:n_rep_scens, 1, 'Replace', false);
w_scens = wave_scens(:, :, rcp_scens);
d_scens = dhw_scens(:, :, rcp_scens);

%% Run ADRIA
% Run a single simulation
Y = coralScenario(new_interv_opts, new_criteria_opts, coral_params, new_sim_opts, ...
              TP_data, site_ranks, strongpred, ...
              w_scens, d_scens, alg_ind);

Y2 = zeros(25,6,26);
for sp = 1:6
    Y2(:,sp,:) = sum(Y.all(:,6*sp-5:sp*6,:),2); 
end


figure; 
LO = tiledlayout(2,3, 'TileSpacing','Compact');

% Tile 1
nexttile
plot(squeeze(Y2(:,1,:)));
title('Enhanced Tab Acr')

% Tile 2
nexttile
plot(squeeze(Y2(:,2,:)));
title('Unenhanced Tab Acr')

% Tile 3
nexttile
plot(squeeze(Y2(:,3,:)))
title('Enhanced Cor Acr')

% Tile 4
nexttile
plot(squeeze(Y2(:,4,:)))
title('Unenhanced Cor Acr')

% Tile 5
nexttile
plot(squeeze(Y2(:,5,:)))
title('Small massives')

% Tile 6
nexttile
plot(squeeze(Y2(:,6,:)))
title('Large massives')

xlabel(LO,'Years')
ylabel(LO,'Cover (prop)')
          