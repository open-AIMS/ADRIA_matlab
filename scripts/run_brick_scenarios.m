rng(101) % set seed for reproducibility

ai = ADRIA();

param_table = ai.raw_defaults;

% set specific parameter values
Guided = [0, 1];
Seed1 = [0, 500000];
Seed2 = [0, 500000];
fogging = [0.0, 0.2];
Aadpt = [0, 4, 8];
Natad = [0.0, 0.05];
Seedyrs = 5;
Shadeyrs = [20, 74];
Seedfreq = [0, 3];
Shadefreq = [1, 5];
Seedyr_start = [2, 6, 11, 16];
Shadeyr_start = [2, 6, 11, 16];


% Create combinations of above target values
target_inputs = table(Guided, Seed1, Seed2, fogging, Aadpt, Natad, ...
                      Seedyrs, Shadeyrs, Seedfreq, Shadefreq, ...
                      Seedyr_start, Shadeyr_start);
perm_table = createPermutationTable(target_inputs);

% Get column names
col_names = param_table.Properties.VariableNames;
cols_to_include = ["Guided", "Seed1", "Seed2", "fogging", "Aadpt", "Natad", ...
    "Seedyrs", "Shadeyrs", "Seedfreq", "Shadefreq", "Seedyr_start", ...
    "Shadeyr_start"];
ignore_cols = string(col_names(~ismember(col_names,cols_to_include)));
input_table = ai.setParameterValues(perm_table, ignore = ignore_cols', partial = false);

% Remove unnecessary counterfactual runs
cfs = input_table((input_table.Seed1 == 0) & (input_table.Seed2 == 0) & (input_table.fogging == 0.0), :);

% Specify specific CF scenario
cf_scenario = cfs(1, :);
cf_scenario.Guided = 0;
cf_scenario.Seed1 = 0;
cf_scenario.Seed2 = 0;
cf_scenario.fogging = 0.0;
cf_scenario.Aadpt = 0;
cf_scenario.Natad = 0.0;


% Remove Guided scenarios with no seed, and adapt 0 to 8
% input_table((input_table.Seed1 == 0) & (input_table.Seed2 == 0) & (input_table.Aadpt >= 0), :) = [];

% Remove fogging scenarios with nothing to fog
% input_table((input_table.Seed1 == 0) & (input_table.Seed2 == 0) & (input_table.fogging > 0), :) = [];

% Either seed or don't seed both, don't do halfsies.
input_table = input_table(((input_table.Seed1 == 0) & (input_table.Seed2 == 0)) | ...
                          ((input_table.Seed1 == 500000) & (input_table.Seed2 == 500000)), :);

interv_scenarios = input_table(((input_table.Seed1 > 0) | (input_table.Seed2 > 0)) | (input_table.fogging > 0.0), :);
input_table = [cf_scenario; interv_scenarios];

% protective_fog_scenarios = (input_table.Guided == 1) & ...
%                            (input_table.Seed1 == 500000) & ...
%                            (input_table.Seed2 == 500000) & ...
%                            (input_table.fogging == 0.2);
% input_table = input_table(protective_fog_scenarios, :);

% input_table = input_table(1:6, :);
% 
% tmp = input_table(2, :);
% tmp.Guided = 0;
% tmp.fogging = 0.0;
% tmp.Seed1 = 500000;
% tmp.Seed2 = 500000;
% tmp.Aadpt = 0;
% tmp.Natad = 0.0;
% tmp.Seedfreq = 1;
% tmp.Seedyr_start = 2;
% input_table(2, :) = tmp;
% 
% tmp = input_table(3, :);
% tmp.Guided = 0;
% tmp.fogging = 0.2;
% tmp.Seed1 = 500000;
% tmp.Seed2 = 500000;
% tmp.Aadpt = 4;
% tmp.Natad = 0.0;
% tmp.Shadefreq = 1;
% tmp.Seedfreq = 1;
% tmp.Seedyr_start = 2;
% tmp.Shadeyr_start = 2;
% tmp.Shadeyrs = 74;
% input_table(3, :) = tmp;
% 
% tmp = input_table(4, :);
% tmp.Guided = 0;
% tmp.fogging = 0.2;
% tmp.Seed1 = 500000;
% tmp.Seed2 = 500000;
% tmp.Aadpt = 4;
% tmp.Natad = 0.05;
% tmp.Shadefreq = 1;
% tmp.Seedfreq = 1;
% tmp.Seedyr_start = 2;
% tmp.Shadeyr_start = 2;
% tmp.Shadeyrs = 74;
% input_table(4, :) = tmp;
% 
% % Guided interv, select every year
% tmp = input_table(5, :);
% tmp.Guided = 1;
% tmp.fogging = 0.2;
% tmp.Seed1 = 500000;
% tmp.Seed2 = 500000;
% tmp.Aadpt = 4;
% tmp.Natad = 0.0;
% tmp.Shadeyr_start = 2;
% tmp.Shadeyrs = 74;
% tmp.Seedfreq = 1;
% input_table(5, :) = tmp;
% 
% tmp = input_table(6, :);
% tmp.Guided = 1;
% tmp.fogging = 0.2;
% tmp.Seed1 = 500000;
% tmp.Seed2 = 500000;
% tmp.Aadpt = 8;
% tmp.Natad = 0.05;
% tmp.Shadefreq = 1;
% tmp.Seedfreq = 1;
% tmp.Seedyr_start = 2;
% tmp.Shadeyr_start = 2;
% tmp.Shadeyrs = 74;
% input_table(6, :) = tmp;

disp("Generated table size: ");
disp(height(input_table))

% input_table = input_table(1:64, :);  % debug
% input_table = input_table(3, :);  % debug

N = height(input_table);
n_reps = 20;


% Get/create parallel worker pool
try
    p = parpool('local');
catch err
    if ~(err.identifier == "parallel:convenience:ConnectionOpen")
        throw(err)
    else
        p = gcp('nocreate'); % If pool already exists, do not create new one.
    end
end

num_workers = p.NumWorkers;

% Run all years
ai.constants.tf = 74;

% Load site specific data
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/2015/');
ai.loadCoralCovers("./Inputs/Brick/site_data/coralCoverBrickTruncated.mat");

desired_metrics = {@(x, p) coralTaxaCover(x, p).total_cover, ...
    @(x, p) coralTaxaCover(x, p).juveniles, ...
    @coralEvenness, ...
    @shelterVolume, ...
    };

target_RCPs = ["45"; "60"; "26"];
for rcp = target_RCPs'
    dhw_data = strcat("./Inputs/Brick/DHWs/dhwRCP", rcp, ".mat");
    ai.loadDHWData(dhw_data, n_reps);

    tgt_rcp = strcat("D:/ADRIA_results/Brick_Mar_deliv_RCP", rcp, "_redux/");
    mkdir(tgt_rcp{1});

    file_prefix = strcat(tgt_rcp, "RCP", rcp, "_redux");
    
    tic
    ai.runToDisk(input_table, sampled_values=false, nreps=n_reps, ...
        file_prefix=file_prefix, ...
        batch_size=ceil(N / num_workers), metrics=desired_metrics, ...
        summarize=true, collect_logs=["fog", "seed", "site_rankings"]);
    tmp = toc;
    disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N * n_reps)), " seconds per run; ", num2str(tmp/N), " seconds per scenario)"))
    
    % Get summary stats for all metrics
    tic
    Y = ai.gatherSummary(file_prefix, summarize=false);
    tmp = toc;
    disp(strcat("Took ", num2str(tmp), " seconds to collect all scenarios"))
    
    mean_RCI = ReefConditionIndex(Y.coralTaxaCover_x_p_total_cover.mean, Y.coralEvenness.mean, Y.shelterVolume.mean, Y.coralTaxaCover_x_p_juveniles.mean);
    median_RCI = ReefConditionIndex(Y.coralTaxaCover_x_p_total_cover.median, Y.coralEvenness.median, Y.shelterVolume.median, Y.coralTaxaCover_x_p_juveniles.median);
    min_RCI = ReefConditionIndex(Y.coralTaxaCover_x_p_total_cover.min, Y.coralEvenness.min, Y.shelterVolume.min, Y.coralTaxaCover_x_p_juveniles.min);
    max_RCI = ReefConditionIndex(Y.coralTaxaCover_x_p_total_cover.max, Y.coralEvenness.max, Y.shelterVolume.max, Y.coralTaxaCover_x_p_juveniles.max);
    std_RCI = ReefConditionIndex(Y.coralTaxaCover_x_p_total_cover.std, Y.coralEvenness.std, Y.shelterVolume.std, Y.coralTaxaCover_x_p_juveniles.std);

    RCI = struct("mean", mean_RCI, "median", median_RCI, "min", min_RCI, "max", max_RCI, "std", std_RCI);
    Y.RCI = RCI;
    
    tic
    Y.inputs = input_table;
    Y.sim_constants = ai.constants;
    save(strcat(file_prefix, ".mat"), "-struct", "Y", "-v7.3");
    tmp = toc;
    disp(strcat("Took ", num2str(tmp), " seconds to save scenarios"))
    
    break
end

% plot(mean(Y.RCI.mean(:, :, 1), 2), 'DisplayName', "CF", 'LineWidth',2)
% hold on
% plot(mean(Y.RCI.mean(:, :, 2), 2), 'DisplayName', "Unguided interventions, no enhancement", 'LineWidth',2)
% plot(mean(Y.RCI.mean(:, :, 3), 2), 'DisplayName', "Unguided interventions, no natad", 'LineWidth',2)
% plot(mean(Y.RCI.mean(:, :, 5), 2), 'DisplayName', "Guided interventions, no natad, selfreq=1", 'LineWidth',2)
% plot(mean(Y.RCI.mean(:, :, 4), 2), 'DisplayName', "Unguided interventions, 0.05 natad", 'LineWidth',2)
% plot(mean(Y.RCI.mean(:, :, 6), 2), 'DisplayName', "Guided interventions, 0.05 natad", 'LineWidth',2)
% legend

