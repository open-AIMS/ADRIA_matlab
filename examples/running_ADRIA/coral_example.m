% Example script illustrating running ADRIA scenarios
rng(101)

%% Generate monte carlo samples

% Number of scenarios
N = 8;
n_reps = 3;  % Number of replicate RCP scenarios

ai = ADRIA();

%% Parameter prep
% Collect details of available parameters
combined_opts = ai.parameterDetails();
sim_constants = ai.constants;

% Generate samples using simple monte carlo
% Create selection table based on lower/upper parameter bounds
sample_table = table;
for p = 1:height(combined_opts)
    a = combined_opts.lower_bound(p);
    b = combined_opts.upper_bound(p);
    
    selection = (b - a).*rand(N, 1) + a;
    
    sample_table.(combined_opts.name(p)) = selection;
end

% Set MCDA algorithm choice to `2` as we only want to use TOPSIS 
% for this example
sample_table.alg_ind(:) = 2;

%% Load site specific data
ai.loadConnectivity('MooreTPmean.xlsx');

%% Scenario runs

tic
Y = ai.run(sample_table, sampled_values=true, nreps=n_reps);
% ai.runToDisk(sample_table, sampled_values=true, nreps=n_reps, ...
%     file_prefix='./test', batch_size=4);
tmp = toc;

% If saving results to disk
% Y = collectDistributedResults('./test', N, n_reps);
disp(strcat("Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))



%% post-processing
% collate data across all scenario runs

% tf = params.tf;
% nspecies = 4;
% processed = struct('TC', zeros(tf, nsites, N, num_reps), ...
%                    'C', zeros(tf, nspecies, nsites, N, num_reps), ...
%                    'E', zeros(tf, nsites, N, num_reps), ...
%                    'S', zeros(tf, nsites, N, num_reps));
% for i = 1:N
%     for j = 1:num_reps
%         processed.TC(:, :, i, j) = Y.TC(i, j);
%         processed.C(:, :, :, i, j) = Y.C(i, j);
%         processed.E(:, :, i, j) = Y.E(i, j);
%         processed.S(:, :, i, j) = Y.S(i, j);
%     end
% end

%% analysis
% Prompt for importance balancing
MetricPrompt = {'Relative importance of coral evenness for cultural ES (proportion):', ...
        'Relative importance of structural complexity for cultural ES (proportion):', ...
        'Relative importance of coral evenness for provisioning ES (proportion):', ...
        'Relative importance of structural complexity for provisioning ES (proportion):', ...
        'Total coral cover at which scope to support Cultural ES is maximised:', ...
        'Total coral cover at which scope to support Provisioning ES is maximised:', ...
        'Row used as counterfactual:'};
dlgtitle = 'Coral metrics and scope for ecosystem-services provision';
dims = [1, 50];
definput = {'0.5', '0.5', '0.2', '0.8', '0.5', '0.5', '1'};
answer = inputdlg(MetricPrompt, dlgtitle, dims, definput, "off");
evcult = str2double(answer{1});
strcult = str2double(answer{2});
evprov = str2double(answer{3});
strprov = str2double(answer{4});
TCsatCult = str2double(answer{5});
TCsatProv = str2double(answer{6});
cf = str2double(answer{7}); %counterfactual

ES_vars = [evcult, strcult, evprov, strprov, TCsatCult, TCsatProv, cf];

ecosys_results = coralsToEcosysServices(Y, ES_vars);
analyseADRIAresults1(ecosys_results);
