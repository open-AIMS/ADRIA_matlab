% Example script running a single scenario.

rng(101) % set seed for reproducibility

% Collect details of parameters that can be varied
inter_opts = interventionDetails();
criteria_opts = criteriaDetails();

% Parameters that are treated as constants
coral_params = coralDetails();
sim_constants = simConstants();

% list of name->value for coral parameters
names = coral_params.name;
default_values = coral_params.raw_defaults;
param_table = array2table(default_values', 'VariableNames', names);


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
    if contains(field_name, 'psg')
        continue
    end
    if contains(field_name, 'beta')
        continue
    end
    if field_name{1} == 'p'
        continue
    end
    prompt(n) = field_name;
    definput(n) = sim_constants.(field_name{1});
end

prompt = prompt(~cellfun('isempty',prompt));
definput = string(definput(~definput==0));

dlgtitle = 'Simulation Options';
user_sim_opts = inputdlg(prompt, dlgtitle, dims, definput);

% Assign new values
new_sim_opts = struct();
i = 1;
for n = 1:length(sim_names)
    field_name = sim_names(n);
    
    is_psg = contains(field_name, 'psg');
    is_beta = contains(field_name, 'beta');
    is_p = field_name{1} == "p";
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
global rec_log
rec_log = zeros(25, 36, 26);
coral_spec = coralSpec();
Y = coralScenario(new_interv_opts, new_criteria_opts, param_table, new_sim_opts, ...
              coral_spec, TP_data, site_ranks, strongpred, ...
              w_scens, d_scens, alg_ind);

Y2 = zeros(25,6,26);
for sp = 1:6
    Y2(:,sp,:) = sum(Y.C(:,6*sp-5:sp*6,:),2); 
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


figure
h = heatmap(squeeze(rec_log(1, 25:end, :)));
lim = caxis;
caxis([0.0, 0.005]);
ylabel("Species");
xlabel("Sites");
title("Time step 1");

fr = getframe(gcf);
im = frame2im(fr);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,'recruitment_log_massives.gif','gif', 'Loopcount',inf);

for i = 2:25
    title(strcat("Time step ", num2str(i)));
    h.ColorData = squeeze(rec_log(i, 25:end, :));

    % Capture the plot as an image 
    fr = getframe(gcf);
    im = frame2im(fr); 
    [imind,cm] = rgb2ind(im,256);
    
    % Write to the GIF File
    imwrite(imind,cm,'recruitment_log_massives.gif','gif','WriteMode','append');
end
