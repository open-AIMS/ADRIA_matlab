function Y = growthODE4_KA(X, r, P, mb, rec, comp)

% Inputs:   X, array, coral state. Dimensions: nspecies (36) by nsites
%           r: array, growth rates (transitions). Dimensions: nspecies
%           mb: array, mortality rates (background). Dimensions: nspecies
%           P: scalar, max cover. Will be changed to a site function
%           rec: array, recruitment. Dimensions: ngroups (6) by nsites

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

Y = zeros(size(X));  % output matrix

% Total cover of small massives and encrusting
X_sm = sum(X(26:28, :));

% Total cover of largest tabular Acropora
X_tabular = (X(6, :) + X(12, :)); % this is for enhanced and unenhanced

k_X_r = k .* X .* r;
k_rec = k .* rec;
X_mb = X .* mb;

%Tabular Acropora Enhanced
% Y(1, :) = k_rec(1, :) - k_X_r(1, :) - X_mb(1,:);
% Y(2:4, :) = k_X_r(1:3, :) - k_X_r(2:4, :) - X_mb(2:4, :);
Y(5, :) = k_X_r(4, :) - k .* X(5, :) .* (r(5) + comp .* X_sm) - X_mb(5, :);
Y(6, :) = k .* X(5, :) .* (r(5) + comp .* X_sm) + k_X_r(6, :) - X_mb(6, :);

%Tabular Acropora Unenhanced
% Y(7, :) = k_rec(2, :) - k_X_r(7, :) - X_mb(7,:);
% Y(8:10, :) = k_X_r(7:9, :) - k_X_r(8:10, :) - X_mb(8:10, :);
Y(11, :) = k_X_r(10, :) - k .* X(11, :) .* (r(11) + comp .* X_sm) - X_mb(11, :);
Y(12, :) = k .* X(11, :) .* (r(11) + comp .* X_sm) + k_X_r(12, :) - X_mb(12, :);

%Corymbose Acropora Enhanced
Y(13, :) = k_rec(3, :) - k .* X(13, :) .* r(13) - X_mb(13,:);
% Y(14:17, :) = k_X_r(13:16, :) - k_X_r(14:17, :) - X_mb(14:17, :);
% Y(18, :) = k_X_r(17, :) + k_X_r(18, :) - X_mb(18, :);

%Corymbose Acropora Unenhanced
% Y(19, :) = k_rec(4, :) - k_X_r(19, :) - X_mb(19,:);
% Y(20:23, :) = k_X_r(19:22, :) - k_X_r(20:23, :) - X_mb(20:23, :);
% Y(24, :) = k_X_r(23, :) + k_X_r(24, :) - X_mb(24, :);

%small massives and encrusting Unenhanced
Y(25, :) = k_rec(5, :) - k .* X(25, :) .* r(25) - X_mb(25,:);
Y(26:28, :) = k_X_r(25:27, :) - k_X_r(26:28, :) - X(26:28, :) .* (mb(26) + comp .* X_tabular);
% Y(29, :) = k_X_r(28, :) - k_X_r(29, :) - X_mb(29, :);
% Y(30, :) = k_X_r(29, :) + k_X_r(30, :) - X_mb(30, :);

%Large massives Unenhanced
% Y(31, :) = k_rec(6, :) - k_X_r(31, :) - X_mb(31,:);
% Y(32:35, :) = k_X_r(31:34, :) - k_X_r(32:35, :) - X_mb(32:35, :);
% Y(36, :) = k_X_r(35, :) + k_X_r(36, :) - X_mb(36, :);

% Small size classes
Y([1,7,19,31], :) = k_rec([1,2,4,6], :) - k_X_r([1,7,19,31], :) - X_mb([1,7,19,31],:);

% Mid size classes
Y([2:4,8:10,14:17,20:23,29,32:35], :) = k_X_r([1:3,7:9,13:16,19:22,28,31:34], :) - k_X_r([2:4,8:10,14:17,20:23,29,32:35], :) - X_mb([2:4,8:10,14:17,20:23,29,32:35], :);

% Larger size classes
Y([18,24,30,36], :) = k_X_r([17,23,29,35], :) + k_X_r([18,24,30,36], :) - X_mb([18,24,30,36], :);

% Ensure no non-negative values
Y = max(Y, 0);

Y = Y(:); % convert to column vector (necessary for ODE to work)
end
