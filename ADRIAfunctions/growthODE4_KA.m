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
% This sets the carrying capacity k := 0.0 <= k <= P
% resulting in a matrix of (species * sites)
% ensuring that density dependence is applied per site
k = max(P - sum(X, 1), 0.0);
% P_x = repmat(k, size(r));  

Y = zeros(size(X));  % output matrix

% Total cover of small massives and encrusting
X_sm = sum(X(26:28, :));

% Total cover of largest tabular Acropora
X_tabular = (X(6, :) + X(12, :)); % this is for enhanced and unenhanced

%Tabular Acropora Enhanced
Y(1, :) = k .* rec(1, :) - k .* X(1, :) .* r(1)  - X(1,:) .* mb(1);
Y(2:4, :) = k .* X(1:3, :) .* r(1:3) - k .* X(2:4, :) .* r(2:4) - X(2:4, :) .* mb(2:4);
Y(5, :) = k .* X(4, :) .* r(4) - k .* X(5, :) .* (r(5) + comp .* X_sm) - X(5, :) .* mb(5);
Y(6, :) = k .* X(5, :) .* (r(5) + comp .* X_sm) + k .* X(6, :) .* r(6) - X(6, :) .* mb(6);

%Tabular Acropora Unenhanced
Y(7, :) = k .* rec(2, :) - k .* X(7, :) .* r(7) - X(7,:) .* mb(7);
Y(8:10, :) = k .* X(7:9, :) .* r(7:9) - k .* X(8:10, :) .* r(8:10) - X(8:10, :) .* mb(8:10);
Y(11, :) = k .* X(10, :) .* r(10) - k .* X(11, :) .* (r(11) + comp .* X_sm) - X(11, :) .* mb(11);
Y(12, :) = k .* X(11, :) .* (r(11) + comp .* X_sm) + k .* X(12, :) .* r(12) - X(12, :) .* mb(12);

%Corymbose Acropora Enhanced
Y(13, :) = k .* rec(3, :) - k .* X(13, :) .* r(13) - X(13,:) .* mb(13);
Y(14:17, :) = k .* X(13:16, :) .* r(13:16) - k .* X(14:17, :) .* r(14:17) - X(14:17, :) .* mb(14:17);
Y(18, :) = k .* X(17, :) .* r(17) + k .* X(18, :) .* r(18) - X(18, :) .* mb(18);

%Corymbose Acropora Unenhanced
Y(19, :) = k .* rec(4, :) - k .* X(19, :) .* r(19)  - X(19,:) .* mb(19);
Y(20:23, :) = k .* X(19:22, :) .* r(19:22) - k .* X(20:23, :) .* r(20:23) - X(20:23, :) .* mb(20:23);
Y(24, :) = k .* X(23, :) .* r(23) + k .* X(24, :) .* r(24) - X(24, :) .* mb(24);

%small massives and encrusting Unenhanced
Y(25, :) = k .* rec(5, :) - k .* X(25, :) .* r(25) - X(25,:) .* mb(25);
Y(26:28, :) = k .* X(25:27, :) .* r(25:27) - k .*  X(26:28, :) .* r(26:28) - X(26:28, :) .* (mb(26) + comp .* X_tabular);
Y(29, :) = k .* X(28, :) .* r(28) - k .* X(29, :) .* r(29) - X(29, :) .* mb(29);
Y(30, :) = k .* X(29, :) .* r(29) + k .* X(30, :) .* r(30) - X(30, :) .* mb(30); 

%Large massives Unenhanced
Y(31, :) = k .* rec(6, :) - k .* X(31, :) .* r(31) - X(31,:) .* mb(31);
Y(32:35, :) = k .* X(31:34, :) .* r(31:34) - k .* X(32:35, :) .* r(32:35) - X(32:35, :) .* mb(32:35);
Y(36, :) = k .* X(35, :) .* r(35) + k .* X(36, :) .* r(36) - X(36, :) .* mb(36);

% Ensure no non-negative values
Y = max(Y, 0);

Y = Y(:); % convert to column vector (necessary for ODE to work)
end
