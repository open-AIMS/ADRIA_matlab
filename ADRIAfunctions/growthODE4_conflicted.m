function Y = growthODE4_conflicted(X, r, P, mb, rec, comp)

% Inputs:   X, array, coral state. Dimensions: nspecies (36) by nsites (26)
%           r: array, growth rates (transitions). Dimensions: nspecies
%           mb: array, mortality rates (background). Dimensions: nspecies
%           P: scalar, max cover. Will be changed to a site function
%           rec: array, recruitment. Dimensions: ngroups (6) by sites (26)

% coral parameter values are defined in 'coralParams()'
% X is relative cover of 6 coral groups in 6 size classes
% r is the transition of relative covers between size classes
% mb is background mortality 
% rec is recruitment as added cover of the smallest size class

% Proportions of corals within a size class transitioning to the next size
% class up (r) is based on the assumption that colony sizes within each size
% bin are evenly distributed within bins. Transitions are then a simple
% ratio of the change in colony size to the width of the bin. See
% coralParms for further explanation of these coral metrics. 

%Note that recruitment pertains to coral groups (n = 6) and represents 
% the contribution to the cover of the smallest size class within each
% group.  While growth and mortality metrics pertain to groups (6) as well 
% as size classes (6) across all sites (total of 36 by 26), recruitment is
% a 6 by 26 array. 

X = reshape(X, [36, 26]); %reshape(X, size(rec));  %why are we reshaping X here?

%% Density dependent growth and recruitment
% P - sum over coral covers within each site
% This sets the carrying capacity P_x := 0.0 <= k <= P
% resulting in a matrix of (species * sites)
% ensuring that density dependence is applied per site
k = min( max(P - sum(X, 1), 0.0), P);
P_x = repmat(k, size(r));  

Y = zeros(size(X));  % output matrix

% Total cover of small massives and encrusting
X_sm = sum(X(26:28, :));

% Total cover of largest tabular Acropora
X_tabular = (X(6, :) + X(12, :)); % this is for enhanced and unenhanced

%Tabular Acropora Enhanced
Y(1, :) = P_x(1, :) .* rec(1, :) - P_x(2, :) .* X(1, :) .* r(1)  - X(1,:) .* mb(1);
Y(2:4, :) = P_x(2:4, :) .* X(1:3, :) .* r(1:3) - P_x(3:5, :) .* X(2:4, :) .* r(2:4) - X(2:4, :) .* mb(2:4);
Y(5, :) = P_x(5, :) .* X(4, :) .* r(4) - P_x(6, :) .* X(5, :) .* (r(5) + comp .* X_sm) - X(5, :) .* mb(5);
Y(6, :) = P_x(6, :) .* X(5, :) .* (r(5) + comp .* X_sm) + P_x(6, :) .* X(6, :) .* r(6) - X(6, :) .* mb(6);

%Tabular Acropora Unenhanced
Y(7, :) = P_x(7, :) .* rec(2, :) - P_x(8, :) .* X(7, :) .* r(7) - X(7,:) .* mb(7);
Y(8:10, :) = P_x(8:10, :) .* X(7:9, :) .* r(7:9) - P_x(9:11, :) .* X(8:10, :) .* r(8:10) - X(8:10, :) .*mb(8:10);
Y(11, :) = P_x(11, :) .* X(10, :) .* r(10) - P_x(12, :) .* X(11, :) .* (r(11) + comp .* X_sm) - X(11, :) .* mb(11);
Y(12, :) = P_x(12, :) .* X(11, :) .* (r(11) + comp .* X_sm) + P_x(12, :) .* X(12, :) .* r(12) - X(12, :) .* mb(12);

%Corymbose Acropora Enhanced
Y(13, :) = P_x(13, :) .* rec(3, :) - P_x(14, :) .* X(13, :) .* r(13) - X(13,:) .* mb(13);
Y(14:17, :) = P_x(14:17, :) .* X(13:16, :) .* r(13:16) - P_x(15:18, :) .* X(14:17, :) .* r(14:17) - X(14:17, :) .*mb(14:17);
Y(18, :) = P_x(18, :) .* X(17, :) .* r(17) + P_x(18, :) .* X(18, :) .* r(18) - X(18, :) .* mb(18);

%Corymbose Acropora Unenhanced
Y(19, :) = P_x(19, :) .* rec(4, :) - P_x(20, :) .* X(19, :) .* r(19)  - X(19,:) .* mb(19);
Y(20:23, :) = P_x(20:23, :) .* X(19:22, :) .* r(19:22) - P_x(21:24, :) .* X(20:23, :) .* r(20:23) - X(20:23, :) .*mb(20:23);
Y(24, :) = P_x(24, :) .* X(23, :) .* r(23) + P_x(24, :) .* X(24, :) .* r(24) - X(24, :) .* mb(24);

%small massives and encrusting Unenhanced
Y(25, :) = P_x(25, :) .* rec(5, :) - P_x(26, :) .* X(25, :) .* r(25) - X(25,:) .* mb(25);
Y(26:28, :) = P_x(26:28, :) .* X(25:27, :) .* r(25:27) - P_x(27:29, :) .*  X(26:28, :) .* r(26:28) - X(26:28, :) .* (mb(26:28) + comp .* X_tabular);
Y(29, :) = P_x(29, :) .* X(28, :) .* r(28) - P_x(30, :) .*  X(29, :) .* r(29) - X(29, :) .* mb(29);
Y(30, :) = P_x(30, :) .* X(29, :) .* r(29) + P_x(30, :) .*  X(30, :) .* r(30) - X(30, :) .* mb(30); 

%Large massives Unenhanced
Y(31, :) = P_x(31, :) .* rec(6, :) - P_x(32, :) .* X(31, :) .* r(31) - X(31,:) .* mb(31);
Y(32:35, :) = P_x(32:35, :) .* X(31:34, :) .* r(31:34) - P_x(32:35, :) .* X(31:34, :) .* r(31:34) - X(32:35, :) .* mb(32:35);
Y(36, :) = P_x(36, :) .* X(35, :) .* r(35) + P_x(36, :) .* X(36, :) .* r(36) - X(36, :) .* mb(36);

% constrain between 0 and max cover
Y = max(Y, 0);
Y = min(Y, P);

Y = Y(:); % convert to column vector (necessary for ODE to work)
end
