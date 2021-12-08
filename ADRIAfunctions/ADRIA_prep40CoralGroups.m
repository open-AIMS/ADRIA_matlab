function Y = ADRIA_prep40CoralGroups(X, r, P, mb, col_stats, a_arena)

% X is defined here as number of colonies of 4 species in 6 size classes
% r is lateral colony extension (cm) of 4 coral species in 6 size classes
% Source for colony extension is Bozec et al. 2021. 

% X will converted below to cover based on the area of the modelled arena 
% similar for r

% Proportions of corals within a size class transitioning to the next size 
% class up is based on the assumption that colonies within each size bin 
% are evenly distributed within bins. Transitions are then a simple ratio
% of the change in colony size to the width of the bin. Similarly,
% proporions of corals that do not change bin is 1 - transitions. 
%  

%Establish 6 coral size bins. Needed for structure and habitat (shelter).
%These values should be set outside of function (in the parameters).
%Used here as part of developing the method

%Example data
X = [10^4,5000,2500,1250,600,300; 10^3,4000,2000,1000,500,300];
r = [1, 1, 1, 2, 3, 4; 1, 1, 1, 1.5, 2, 3];
mb = [0.3, 0.2, 0.1, 0.05, 0.03, 0.02; 0.3, 0.2, 0.1, 0.05, 0.03, 0.02];
col_stats.diam_means =  [1, 3.5, 7.5, 15, 30, 60]; %
col_stats.area_means = pi.*(col_stats.diam_means./2).^2;
col_stats.diam_bin_widths = [2, 3, 5, 10, 20, 40];

tp_change = r./col_stats.diam__bin_widths;
tp_stay = 1-r./col_stats.diam__bin_widths;

delta_cover = X.*tp_new.*col_stat.area_means./a_arena;

%% Work in progress as at 10PM on 8th Nov 21 

P_x = P - sum(X);
Y = r' .* X .* (P_x - mb');
% Y(Y < 0) = 0;  % function is called with non-negative=true
Y(Y > P) = P;  % constrain to max cover

end

