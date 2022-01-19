function params = coralSpec()
% Create a template struct for coral parameter values for ADRIA.
% Includes "vital" bio/ecological parameters, to be filled with
% sampled or user-specified values.
%
% Notes:
% Values for the historical, temporal pattsiern of degree heating weeks
% between bleaching years come from [1].
%
% Outputs:
%   params : struct, parameters for each coral taxa, group and size class
%
% References
% 1. Lough, J.M., Anderson, K.D. and Hughes, T.P. (2018)
%        'Increasing thermal stress for tropical coral reefs: 1871–2017',
%        Scientific Reports, 8(1), p. 6079.
%        doi: 10.1038/s41598-018-24530-9.
%
% 2. Bozec, Y.-M., Rowell, D., Harrison, L., Gaskell, J., Hock, K., 
%      Callaghan, D., Gorton, R., Kovacs, E. M., Lyons, M., Mumby, P., 
%      & Roelfsema, C. (2021). 
%        Baseline mapping to support reef restoration and resilience-based 
%        management in the Whitsundays. 
%      https://doi.org/10.13140/RG.2.2.26976.20482

% Below parameters pertaining to species are new. We now add size classes
% to each coral species, but treat each coral size class as a 'species'.
% need a better word than 'species' to signal that we are using different
% sizes within groups and real taxonomic species.

params = table();

% Coral species are divided into taxa and size classes
taxa_names = [ ...
    "tabular_acropora_enhanced"; ...
    "tabular_acropora_unenhanced"; ...
    "corymbose_acropora_enhanced"; ...
    "corymbose_acropora_unenhanced"; ...
    "small_massives"; ...
    "large_massives" ...
    ];

size_cm = [2; 5; 10; 20; 40; 80];  % centimeters
size_class_means_from = [1; 3.5; 7.5; 15; 30; 60];
size_class_means_to = [size_class_means_from(2:end); 100.0];

% total number of "species" modelled in the current version.
nspecies = length(taxa_names) * length(size_cm);
nclasses = length(size_cm);

% params.taxa_id = reshape(repmat(1:nclasses, nclasses, 1), nspecies, []);
% 
% params.class_id = reshape(repmat(1:nclasses, 1, nclasses), nspecies, []);

% Create combinations of taxa names and size classes

tn = repmat(taxa_names, 1, nclasses)';
tn = tn(:);
params.name = humanReadableName(tn(:), true);

taxa_ids = reshape(repmat(1:nclasses, nclasses, 1), nspecies, []);
params.taxa_id = taxa_ids;

params.class_id = repmat(1:nclasses, 1, nclasses)';
params.size_cm = repmat(size_cm, nclasses, 1);

params.coral_id = join([tn(:), params.taxa_id, params.class_id], "_");

% rec = [0.00, 0.01, 0.00, 0.01, 0.01, 0.01];
% params.recruitment_factor = repmat(rec, 1, nclasses)';

%% Ecological parameters

% To be more consistent with parameters in ReefMod, IPMF and RRAP
% interventions, we express coral abundance as colony numbers in different
% size classes and growth rates as linear extention (in cm per year).

%%% Base covers
%First express as number of colonies per size class per 100m2 of reef
base_coral_numbers = ...
    [0, 0, 0, 0, 0, 0; ...              % Tabular Acropora Enhanced
     2000, 200, 100, 50, 30, 10; ... % Tabular Acropora Unenhanced
     0, 0, 0, 0, 0, 0; ...              % Corymbose Acropora Enhanced
     2000, 200, 100, 50, 30, 10; ... % Corymbose Acropora Unenhanced
     2000, 500, 200, 200, 100, 0; ... % small massives
     2000, 500, 20, 20, 20, 10];      % large massives

% To convert to covers we need to first calculate the area of colonies,
% multiply by how many corals in each bin, and divide by reef area

% The coral colony diameter bin edges (cm) are: 0, 2, 5, 10, 20, 40, 80
% To convert to cover we locate bin means and calculate bin mean areas
colony_diam_means_from = repmat(size_class_means_from', length(size_cm), 1);
colony_diam_means_to = repmat(size_class_means_to', length(size_cm), 1);

colony_area_m2_from = pi .* ((colony_diam_means_from ./ 2).^2) ./ (10^4);
colony_area_m2_to = pi .* ((colony_diam_means_to ./ 2).^2) ./ (10^4);

params.colony_area_cm2 = reshape(colony_area_m2_to', 36, 1)*(10^4);

a_arena = 100; % m2 of reef arena where corals grow, survive and reproduce

% convert to coral covers (proportions) and convert to vector
basecov = base_coral_numbers .* colony_area_m2_from ./ a_arena;

% as nspecies*1 vector
params.basecov = reshape(basecov', [], 1);

%% Coral growth rates as linear extensions (Bozec et al 2021 Table S2)
% we assume similar growth rates for enhanced and unenhanced corals
linear_extension = ...
   [1, 3, 3, 4.4, 4.4, 4.4; ... % Tabular Acropora Enhanced
    1, 3, 3, 4.4, 4.4, 4.4; ...  % Tabular Acropora Unenhanced
    1, 3, 3, 3, 3, 3; ...        % Corymbose Acropora Enhanced
    1, 3, 3, 3, 3, 3; ...        % Corymbose Acropora Unenhanced
    1, 1, 1, 1, 0.8, 0.8; ...    % small massives
    1, 1, 1, 1, 1.2, 1.2];       % large massives

% Convert linear extensions to delta coral in two steps.
% First calculate what proportion of coral numbers that change size class
% given linear extensions. This is based on the simple assumption that
% coral sizes are evenly distributed within each bin
bin_widths = [2, 3, 5, 10, 20, 40];
diam_bin_widths = repmat(bin_widths, [length(bin_widths), 1]);
prop_change = linear_extension ./ diam_bin_widths;

%Second, growth as transitions of cover to higher bins is estimated as
r = prop_change .* (colony_area_m2_to./colony_area_m2_from);
params.growth_rate = reshape(r', [], 1);

%note that we use proportion of bin widths and linear extension to estimate
% number of corals changing size class, but we use the bin means to estimate
% the cover equivalent because we assume coral sizes shift from edges to mean
% over the year (used in 'growthODE4()'.

%Scope for fecundity as a function of colony area (Hall and Hughes 1996)
fec_par_a = [1.02; 1.02; 1.69; 1.69; 0.86; 0.86]; %fecundity parameter a 
fec_par_b = [1.28; 1.28; 1.05; 1.05; 1.21; 1.21]; %fecundity parameter b 
%fecundity as a function of colony basal area (cm2) from Hall and Hughes 1996
fec = exp(fec_par_a + fec_par_b.*log(colony_area_m2_from.*10^4));
fec_m2 = fec./colony_area_m2_from; %convert from per colony area to per m2
fec_m2_rel = fec_m2./ mean(fec_m2(:,3:6),2); %as a proportion of adult corals
params.fec = reshape(fec_m2_rel', [], 1);

%% Mortality

% Wave mortality risk : wave damage for the 90 percentile of routine wave stress
wavemort90 = ...
   [0, 0, 0.00, 0.02, 0.05, 0.05; ... % Tabular Acropora Enhanced
    0, 0, 0.00, 0.02, 0.05, 0.05; ...  % Tabular Acropora Unenhanced
    0, 0, 0.00, 0.02, 0.04, 0.05; ...  % Corymbose Acropora Enhanced
    0, 0, 0.00, 0.02, 0.04, 0.05; ...  % Corymbose Acropora Unenhanced
    0, 0, 0.00, 0.02, 0.02, 0.02; ...  % Small massives
    0, 0, 0.00, 0.02, 0.01, 0.01];     % Large massives

params.wavemort90 = reshape(wavemort90', [], 1);

% Background mortality taken from Bozec et al. 2021 (Table S2)
mb = [0.2, 0.15, 0.10, 0.05, 0.05, 0.05; ... % Tabular Acropora Enhanced
      0.2, 0.15, 0.10, 0.05, 0.05, 0.05; ...   % Tabular Acropora Unenhanced
      0.2, 0.15, 0.10, 0.05, 0.04, 0.03; ...   % Corymbose Acropora Enhanced
      0.2, 0.15, 0.10, 0.05, 0.04, 0.03; ...   % Corymbose Acropora Unenhanced
      0.2, 0.04, 0.04, 0.02, 0.02, 0.02; ...   % small massives and encrusting
      0.2, 0.04, 0.04, 0.02, 0.02, 0.02];      % large massives

params.mb_rate = reshape(mb', [], 1);

% Background rates of natural adaptation. User-defined natad rates will be 
% added to these

natad = repmat(0.025, 36, 1);
params.natad = natad;

% Estimated bleaching resistance (as DHW) relative to the assemblage 
% response for 2016 bleaching on the GBR (based on Hughes et al. 2018). 
bleach_resist = [...  
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0;    
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0;
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0;
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0;
    1.5, 1.5, 1.5, 1.5, 1.5, 1.5;
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0];

params.bleach_resist = reshape(bleach_resist', [], 1);

