% Example script running a single scenario.

%rng(101) % set seed for reproducibility

% Create ADRIA Interface object
ai = ADRIA();

% Get default parameters
default_params = ai.raw_defaults;

% Collect details of parameters that can be varied
inter_opts = ai.interventions;
criteria_opts = ai.criterias;

% Get the coral parameters, which are not modified for this example
[~, ~, coral_params] = ai.splitParameterTable(default_params);

% Values that are constant across all simulations
sim_constants = ai.constants;


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
ai.loadConnectivity('MooreTPmean.xlsx')

%% Update ADRIA Interface with user specified constants
ai.constants = new_sim_opts;

%% Create input table
param_table = [new_interv_opts, new_criteria_opts, coral_params];

%% Run ADRIA
% Run a single simulation
Y = ai.run(param_table, sampled_values=false, nreps=1);


Y2 = zeros(25,6,26);

%extract outputs from coralCovers() function for plotting
for sp = 1:6
    Y2(:,sp,:) = sum(Y.all(:,6*sp-5:sp*6,:),2); 
end

%% Calculate coral evenness
E = coralEvennessADRIA(Y);

%% Extract juvenile corals (< 5 cm diameter)
BC = Y.all(:,1:6:end,:) + Y.all(:,2:6:end,:);
BC = squeeze(sum(BC,2));

%% Calculate coral shelter volume per ha
SV_per_ha = shelterVolumeADRIA(Y, coral_params);

%% Plot coral covers over time and sites
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
      
% 
% %% Plot coral evenness over time and sites
% figure; 
% plot(E);
% title('Coral Evenness')
% xlabel('Years')
% ylabel('Evenness (prop)')
% 
% %% Plot juvenile corals (<5 cm diam) over time and sites
% figure; 
% plot(BC);
% title('Baby Corals')
% xlabel('Years')
% ylabel('Cover (prop)')
%  
% %% Plot shelter volume over time and sites
% figure; 
% plot(SV_per_ha);
% title('Shelter volume per hectare')
% xlabel('Years')
% ylabel('SV (per ha)')
%  
%       
%% Plot reef condition metrics over time and sites
figure; 
LO2 = tiledlayout(2,2, 'TileSpacing','Compact');

% Tile 1
nexttile
plot(Y.TC);
title('Total Coral Cover')
ylabel('Cover, prop')

% Tile 2
nexttile
plot(E);
title('Coral Evenness')
ylabel('E, prop')

% Tile 3
nexttile
plot(BC)
title('Juvenile Corals (<5 cm diam)')
ylabel('Cover, prop')

% Tile 4
nexttile
plot(SV_per_ha)
title('Shelter Volume per ha')
ylabel('Volume, m3 / ha') 

xlabel(LO2,'Years')
%ylabel(LO,'Cover (prop)')



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
