function params = coralDetails()
% Create structs with coral parameter values for ADRIA.
% Includes "vital" bio/ecological parameters.
%
% Notes:
% Values for the historical, temporal pattern of degree heating weeks between bleaching years come from [1].
%
% Outputs:
%   params : table, parameters for each coral taxa, group and size class
%
% References
% 1. Lough, J.M., Anderson, K.D. and Hughes, T.P. (2018)
%        'Increasing thermal stress for tropical coral reefs: 1871–2017',
%        Scientific Reports, 8(1), p. 6079.
%        doi: 10.1038/s41598-018-24530-9.
%
% 2. (Bozec et al 2021 Table S2) ...

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

size_classes = [2; 5; 10; 20; 40; 80];

% Create combinations of taxa names and size classes
[sc, tn] = ndgrid(size_classes, taxa_names);
taxa_size_ids = join([tn(:), sc(:)], "_");

params.coral_id = taxa_size_ids;
params.name = humanReadableName(tn(:), true);
params.size_class = sc(:);

% total number of "species" modelled in the current version.
nspecies = height(params);

nclasses = length(size_classes);
params.taxa_id = reshape(repmat(1:nclasses, nclasses, 1), nspecies, []);

params.class_id = reshape(repmat(1:nclasses, 1, nclasses), nspecies, []);

% rec = [0.00, 0.01, 0.00, 0.01, 0.01, 0.01];
% params.recruitment_factor = repmat(rec, 1, nclasses)';

%% Ecological parameters

% To be more consistent with parameters in ReefMod, IPMF and RRAP
% interventions, we express coral abundance as colony numbers in different
% size classes and growth rates as linear extention (in cm per year).

%%% Base covers
%First express as number of colonies per size class per 100m2 of reef
base_coral_numbers = ...
    [0, 0, 0, 0, 0, 0; ...             % Tabular Acropora Enhanced
    2000, 500, 200, 100, 100, 100; ... % Tabular Acropora Unenhanced
    0, 0, 0, 0, 0, 0; ...              % Corymbose Acropora Enhanced
    2000, 500, 200, 100, 100, 100; ... % Corymbose Acropora Unenhanced
    2000, 200, 100, 100, 100, 100; ... % small massives
    2000, 200, 100, 100, 50, 10];      % large massives

% To convert to covers we need to first calculate the area of colonies,
% multiply by how many corals in each bin, and divide by reef area

% The coral colony diameter bin edges (cm) are: 0, 2, 5, 10, 20, 40, 80
% To convert to cover we locate bin means and calculate bin mean areas
colony_diam_edges = repmat(size_classes', length(size_classes), 1);
colony_area_m2 = pi .* ((colony_diam_edges ./ 2).^2) ./ (10^4);

a_arena = 100; % m2 of reef arena where corals grow, survive and reproduce

% convert to coral covers (proportions) and convert to vector
basecov = base_coral_numbers .* colony_area_m2 ./ a_arena;

% as nspecies*1 vector
params.basecov = reshape(basecov', [], 1);

%% Coral growth rates as linear extensions (Bozec et al 2021 Table S2)
% we assume similar growth rates for enhanced and unenhanced corals
linear_extension = ...
    [1, 1, 2, 4.4, 4.4, 4.4; ... % Tabular Acropora Enhanced
    1, 1, 2, 4.4, 4.4, 4.4; ...  % Tabular Acropora Unenhanced
    1, 1, 3, 3, 3, 3; ...        % Corymbose Acropora Enhanced
    1, 1, 3, 3, 3, 3; ...        % Corymbose Acropora Unenhanced
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
r = base_coral_numbers .* prop_change .* colony_area_m2 ./ a_arena;
params.growth_rate = reshape(r', [], 1);

%% Background mortality

% coral mortality risk attributable to 38: wave damage for the 90 percentile of routine wave stress
wavemort90 = ...
    [0, 0, 0.02, 0.03, 0.04, 0.05; ... % Tabular Acropora Enhanced
    0, 0, 0.02, 0.03, 0.04, 0.05; ...  % Tabular Acropora Unenhanced
    0, 0, 0.02, 0.02, 0.03, 0.04; ...  % Corymbose Acropora Enhanced
    0, 0, 0.02, 0.02, 0.03, 0.04; ...  % Corymbose Acropora Unenhanced
    0, 0, 0.00, 0.01, 0.02, 0.02; ...  % Small massives
    0, 0, 0.00, 0.01, 0.02, 0.02];     % Large massives

params.wavemort90 = reshape(wavemort90', [], 1);

% Taken from Bozec et al. 2021 (Table S2)
mb = [0.2, 0.19, 0.10, 0.05, 0.03, 0.03; ... % Tabular Acropora Enhanced
    0.2, 0.19, 0.10, 0.05, 0.05, 0.03; ...   % Tabular Acropora Unenhanced
    0.2, 0.20, 0.17, 0.05, 0.03, 0.03; ...   % Corymbose Acropora Enhanced
    0.2, 0.20, 0.17, 0.05, 0.05, 0.05; ...   % Corymbose Acropora Unenhanced
    0.2, 0.20, 0.04, 0.04, 0.02, 0.02; ...   % small massives
    0.2, 0.20, 0.04, 0.04, 0.02, 0.02];      % large massives

params.mb_rate = reshape(mb', [], 1);

natad = [...
    0.2, 0.2, 0.2, 0.2, 0.2, 0.2; ...
    0.2, 0.2, 0.2, 0.2, 0.2, 0.2; ...
    0.05, 0.05, 0.05, 0.05, 0.05, 0.05; ...
    0.05, 0.05, 0.05, 0.05, 0.05, 0.05; ...
    0.10, 0.10, 0.10, 0.10, 0.10, 0.10; ...
    0.10, 0.10, 0.10, 0.10, 0.10, 0.10];

params.natad = reshape(natad', [], 1);

%% growth functions for each taxa/size group
% P_x = P - max(0.0, sum(X, 2));
% P_x = P_x(ind)

% %Tabular Acropora Enhanced
% Y(1) = P_x.*(X(1) + rec(1)) + X(1).*(1-r(1)) - X(1).*mb(1);
% Y(2) = P_x.*(X(2) + X(1).*(1+r(1))) + X(2).*(1-r(2)) - X(2).*mb(2);
% Y(3) = P_x.*(X(3) + X(2).*(1+r(2))) + X(3).*(1-r(3)) - X(3).*mb(3);
% Y(4) = P_x.*(X(4) + X(3).*(1+r(3))) + X(4).*(1-r(4)) - X(4).*mb(4);
% Y(5) = P_x.*(X(5) + X(4).*(1+r(4))) + X(5).*(1-r(5)) - X(5).*mb(5);
% Y(6) = P_x.*(X(6) + X(5).*(1+r(5)) + X(6).*comp*sum(X(25:30))) - X(6).*mb(6);
% 
% %Tabular Acropora Unenhanced
% Y(7) = P_x.*(X(7) + rec(2)) + X(7).*(1-r(7)) - X(7).*mb(7);
% Y(8) = P_x.*(X(8) + X(7).*(1+r(7))) + X(8).*(1-r(8)) - X(8).*mb(8);
% Y(9) = P_x.*(X(9) + X(8).*(1+r(8))) + X(9).*(1-r(9)) - X(9).*mb(9);
% Y(10) = P_x.*(X(10) + X(9).*(1+r(9))) + X(10).*(1-r(10)) - X(10).*mb(10);
% Y(11) = P_x.*(X(11) + X(10).*(1+r(10))) + X(11).*(1-r(11)) - X(11).*mb(11);
% Y(12) = P_x.*(X(12) + X(11).*(1+r(11)) + X(12).*comp*sum(X(25:30))) - X(12).*mb(12);
% 
% %Corymbose Acropora Enhanced
% Y(13) = P_x.*(X(13) + rec(3)) + X(13).*(1-r(13))- X(13).*mb(13);
% Y(14) = P_x.*(X(14) + X(13).*(1+r(13))) + X(14).*(1-r(14)) - X(14).*mb(14);
% Y(15) = P_x.*(X(15) + X(14).*(1+r(14))) + X(15).*(1-r(15)) - X(15).*mb(15);
% Y(16) = P_x.*(X(16) + X(15).*(1+r(15))) + X(16).*(1-r(16)) - X(16).*mb(16);
% Y(17) = P_x.*(X(17) + X(16).*(1+r(16))) + X(17).*(1-r(17)) - X(17).*mb(17);
% Y(18) = P_x.*(X(18) + X(17).*(1+r(17))) - X(18).*mb(18);
% 
% %Corymbose Acropora Unenhanced
% Y(19) = P_x.*(X(19) + rec(4)) + X(19).*(1-r(19))- X(19).*mb(19);
% Y(20) = P_x.*(X(20) + X(19).*(1+r(19))) + X(20).*(1-r(20)) - X(20).*mb(20);
% Y(21) = P_x.*(X(21) + X(20).*(1+r(20))) + X(21).*(1-r(21)) - X(21).*mb(21);
% Y(22) = P_x.*(X(22) + X(21).*(1+r(21))) + X(22).*(1-r(22)) - X(22).*mb(22);
% Y(23) = P_x.*(X(23) + X(22).*(1+r(22))) + X(23).*(1-r(23)) - X(23).*mb(23);
% Y(24) = P_x.*(X(24) + X(23).*(1+r(23))) - X(24).*mb(24);
% 
% %small massives Unenhanced
% Y(25) = P_x.*(X(25) + rec(5)) + X(25).*(1-r(25))- X(25).*mb(25);
% Y(26) = P_x.*(X(26) + X(25).*(1+r(25))) + X(26).*(1-r(26)) - X(26).*(mb(26) + comp*(X(6) + X(12)));
% Y(27) = P_x.*(X(27) + X(26).*(1+r(26))) + X(27).*(1-r(27)) - X(27).*(mb(27) + comp*(X(6) + X(12)));
% Y(28) = P_x.*(X(28) + X(27).*(1+r(27))) + X(28).*(1-r(28)) - X(28).*(mb(28) + comp*(X(6) + X(12)));
% Y(29) = P_x.*(X(29) + X(28).*(1+r(28))) - X(29).*(mb(29) + comp*(X(6) + X(12)));
% Y(30) = 0; %small massives and encrusting constrained to less than 40 cm diameter  
% 
% %Large massives Unenhanced
% Y(31) = P_x.*(X(31) + rec(6)) + X(31).*(1-r(31))- X(31).*mb(31);
% Y(32) = P_x.*(X(32) + X(31).*(1+r(31))) + X(32).*(1-r(32)) - X(32).*mb(32);
% Y(33) = P_x.*(X(33) + X(32).*(1+r(32))) + X(33).*(1-r(33)) - X(33).*mb(33);
% Y(34) = P_x.*(X(34) + X(33).*(1+r(33))) + X(34).*(1-r(34)) - X(34).*mb(34);
% Y(35) = P_x.*(X(35) + X(34).*(1+r(34))) + X(35).*(1-r(35)) - X(35).*mb(35);
% Y(36) = P_x.*(X(36) + X(35).*(1+r(35))) - X(36).*mb(36);
% Y(Y < 0) = 0;  % function is called with non-negative = true
% Y(Y > P) = P;  % constrain to max cover

% Growth function for bin 1
small_growth = @(X, P_x, rec, r, mb, comp, ind, P) max(min(P, P_x .* (X(ind, :) + rec) + X(ind) .* (1-r(ind)) - X(ind, :) .* mb(ind)), 0.0);

% Growth function for bin 2 - 5
mid_growth = @(X, P_x, rec, r, mb, comp, ind, P) max(min(P, P_x .* (X(ind, :) + X(ind-1, :) .* (1+r(ind-1))) + X(ind, :) .* (1-r(ind)) - X(ind, :) .* mb(ind)), 0.0);

% Growth function for bin 6
large_growth = @(X, P_x, rec, r, mb, comp, ind, P) max(min(P, P_x .* (X(ind, :) + X(ind-1, :) .* (1+r(ind-1))) - X(ind, :) .* mb(ind)), 0.0);

% Growth function for bin 2 - 5, including competition with Tabular Acropora
% where X6 and X12 relate to the largest size class for Tabular Acropora Enhanced/Unenhanced 
mid_growth_with_comp = @(X, P_x, rec, r, mb, comp, ind, P) max(min(P, P_x .* (X(ind, :) + X(ind-1, :) .* (1+r(ind-1))) + X(ind, :) .* (1-r(ind)) - X(ind, :) .* comp * (X(6) + X(12))), 0.0);

% Growth function for bin 6, for Tabular Acropora including competition
% with Small Massives
% X(25:30) relate to small massives (need to clean up!)
large_growth_with_comp = @(X, P_x, rec, r, mb, comp, ind, P) max(min(P, P_x .* (X(ind, :) + X(ind-1, :).*(1+r(ind-1)) + X(ind, :) .* comp * sum(X(25:30))) - X(ind, :) .* mb(ind)), 0.0);

% Growth functions for each species
growth_function = { ...
    % Tabular Acropora Enhanced
    small_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    large_growth_with_comp; ...
    
    % Tabular Acropora Unenhanced
    small_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    large_growth_with_comp; ...
    
    % Corymbose Acropora Enhanced
    small_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    large_growth; ...
    
    % Corymbose Acropora Unenhanced
    small_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    large_growth; ...
    
    % Small Massives Unenhanced
    small_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth_with_comp; ...
    
    % constrained small massives to < 40cm
    @(X, P_x, rec, r, mb, comp, ind, P, d) 0.0; ...
    
    % Large Massives Unenhanced
    small_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    mid_growth; ...
    large_growth;
};

params.growth_function = growth_function;

