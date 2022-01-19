function Y = growthODE4_KA(X, r, P, mb, rec, comp)

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

% Reshape flattened input from ODE back to expected matrix shape
% Dims: (coral species, sites)
X = reshape(X, [length(r), length(X) / length(r)]);

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
Y(2, :) = P_x(2, :) .* X(1, :) .* r(1) - P_x(3, :) .* X(2, :) .* r(2) - X(2, :) .* mb(2);
Y(3, :) = P_x(3, :) .* X(2, :) .* r(2) - P_x(4, :) .* X(3, :) .* r(3) - X(3, :) .* mb(3);
Y(4, :) = P_x(4, :) .* X(3, :) .* r(3) - P_x(5, :) .* X(4, :) .* r(4) - X(4, :) .* mb(4);
Y(5, :) = P_x(5, :) .* X(4, :) .* r(4) - P_x(6, :) .* X(5, :) .* (r(5) + comp .* X_sm) - X(5, :) .* mb(5);
Y(6, :) = P_x(6, :) .* X(5, :) .* (r(5) + comp .* X_sm) + P_x(6, :) .* X(6, :) .* r(6) - X(6, :) .* mb(6);

%Tabular Acropora Unenhanced
Y(7, :) = P_x(7, :) .* rec(2, :) - P_x(8, :) .* X(7, :) .* r(7) - X(7,:) .* mb(7);
Y(8, :) = P_x(8, :) .* X(7, :) .* r(7) - P_x(9, :) .* X(8, :) .* r(8) - X(8, :) .*mb(8);
Y(9, :) = P_x(9, :) .* X(8, :) .* r(8) - P_x(10, :) .* X(9, :) .* r(9) - X(9, :) .* mb(9);
Y(10, :) = P_x(10, :) .* X(9, :) .* r(9) - P_x(11, :) .* X(10, :) .* r(10) - X(10, :) .* mb(10);
Y(11, :) = P_x(11, :) .* X(10, :) .* r(10) - P_x(12, :) .* X(11, :) .* (r(11) + comp .* X_sm) - X(11, :) .* mb(11);
Y(12, :) = P_x(12, :) .* X(11, :) .* (r(11) + comp .* X_sm) + P_x(12, :) .* X(12, :) .* r(12) - X(12, :) .* mb(12);

%Corymbose Acropora Enhanced
Y(13, :) = P_x(13, :) .* rec(3, :) - P_x(14, :) .* X(13, :) .* r(13) - X(13,:) .* mb(13);
Y(14, :) = P_x(14, :) .* X(13, :) .* r(13) - P_x(15, :) .* X(14, :) .* r(14) - X(14, :) .* mb(14);
Y(15, :) = P_x(15, :) .* X(14, :) .* r(14) - P_x(16, :) .* X(15, :) .* r(15) - X(15, :) .* mb(15);
Y(16, :) = P_x(16, :) .* X(15, :) .* r(15) - P_x(17, :) .* X(16, :) .* r(16) - X(16, :) .* mb(16);
Y(17, :) = P_x(17, :) .* X(16, :) .* r(16) - P_x(18, :) .* X(17, :) .* r(17) - X(17, :) .* mb(17);
Y(18, :) = P_x(18, :) .* X(17, :) .* r(17) + P_x(18, :) .* X(18, :) .* r(18) - X(18, :) .* mb(18);

%Corymbose Acropora Unenhanced
Y(19, :) = P_x(19, :) .* rec(4, :) - P_x(20, :) .* X(19, :) .* r(19)  - X(19,:) .* mb(19);
Y(20, :) = P_x(20, :) .* X(19, :) .* r(19) - P_x(21, :) .* X(20, :) .* r(20) - X(20, :) .*mb(20);
Y(21, :) = P_x(21, :) .* X(20, :) .* r(20) - P_x(22, :) .* X(21, :) .* r(21) - X(21, :) .* mb(21);
Y(22, :) = P_x(22, :) .* X(21, :) .* r(21) - P_x(23, :) .* X(22, :) .* r(22) - X(22, :) .* mb(22);
Y(23, :) = P_x(23, :) .* X(22, :) .* r(22) - P_x(24, :) .* X(23, :) .* r(23) - X(23, :) .* mb(23);
Y(24, :) = P_x(24, :) .* X(23, :) .* r(23) + P_x(24, :) .* X(24, :) .* r(24) - X(24, :) .* mb(24);

%small massives and encrusting Unenhanced
Y(25, :) = P_x(25, :) .* rec(5, :) - P_x(26, :) .* X(25, :) .* r(25) - X(25,:) .* mb(25);
Y(26, :) = P_x(26, :) .* X(25, :) .* r(25) - P_x(27, :) .*  X(26, :) .* r(26) - X(26, :) .* (mb(26) + comp .* X_tabular);
Y(27, :) = P_x(27, :) .* X(26, :) .* r(26) - P_x(28, :) .*  X(27, :) .* r(27) - X(27, :) .* (mb(27) + comp .* X_tabular);
Y(28, :) = P_x(28, :) .* X(27, :) .* r(27) - P_x(29, :) .*  X(28, :) .* r(28) - X(28, :) .* (mb(28) + comp .* X_tabular);
Y(29, :) = P_x(29, :) .* X(28, :) .* r(28) - P_x(30, :) .*  X(29, :) .* r(29) - X(29, :) .* mb(29);
Y(30, :) = P_x(30, :) .* X(29, :) .* r(29) + P_x(30, :) .*  X(30, :) .* r(30) - X(30, :) .* mb(30); 

%Large massives Unenhanced
Y(31, :) = P_x(31, :) .* rec(6, :) - P_x(32, :) .* X(31, :) .* r(31) - X(31,:) .* mb(31);
Y(32, :) = P_x(32, :) .* X(31, :) .* r(31) - P_x(33, :) .* X(32, :) .* r(32) - X(32, :) .* mb(32);
Y(33, :) = P_x(33, :) .* X(32, :) .* r(32) - P_x(34, :) .* X(33, :) .* r(33) - X(33, :) .* mb(33);
Y(34, :) = P_x(34, :) .* X(33, :) .* r(33) - P_x(35, :) .* X(34, :) .* r(34) - X(34, :) .* mb(34);
Y(35, :) = P_x(35, :) .* X(34, :) .* r(34) - P_x(36, :) .* X(35, :) .* r(35) - X(35, :) .* mb(35);
Y(36, :) = P_x(36, :) .* X(35, :) .* r(35) + P_x(36, :) .* X(36, :) .* r(36) - X(36, :) .* mb(36);

% Ensure no non-negative values
Y = max(Y, 0);

Y = Y(:); % convert to column vector (necessary for ODE to work)
end
