function Y = growthODE4(X, r, P, mb, rec, comp)

% X is defined here as number of colonies of 4 species in 6 size classes
% r is lateral colony extension (cm) of 4 coral species in 6 size classes
% Source for colony extension is Bozec et al. 2021.

% X will converted below to cover based on the area of the modelled arena
% similar for r

% Proportions of corals within a size class transitioning to the next size
% class up is based on the assumption that colony sizes within each size
% bin are evenly distributed within bins. Transitions are then a simple
% ratio of the change in colony size to the width of the bin. Similarly,
% proporions of corals that do not change bin is 1 - transitions.
%

%Establish 6 coral size bins. Needed for structure and habitat (shelter).
%These values should be set outside of function (in the parameters).
%Used here as part of developing the method

X = reshape(X, size(rec));

%% Density dependent growth
% P - sum over coral covers within each site
% This sets the carrying capacity P_x := 0.0 <= k <= P
% resulting in a matrix of (species * sites)
% ensuring that density dependence is applied per site
k = min( max(P - sum(X, 1), 0.0), P);
P_x = repmat(k, size(r));  

Y = zeros(size(X));  % output matrix

% Total size of small massives
X_sm = sum(X(25:30, :));

% Total size of largest enhanced tabular and corymbose acropora
X_enhanced = (X(6, :) + X(12, :));

%Tabular Acropora Enhanced
Y(1, :) = P_x(1, :) .* rec(1, :) - P_x(2, :) .* X(1, :) .* (r(1)  - X(1,:) .* mb(1));
Y(2, :) = P_x(2, :) .* X(1, :) .* r(1) - P_x(3, :) .* X(2, :) .* r(2) - X(2, :) .* mb(2);
Y(3, :) = P_x(3, :) .* X(2, :) .* r(2) - P_x(4, :) .* X(3, :) .* r(3) - X(3, :) .* mb(3);
Y(4, :) = P_x(4, :) .* X(3, :) .* r(3) - P_x(5, :) .* X(4, :) .* r(4) - X(4, :) .* mb(4);
Y(5, :) = P_x(5, :) .* X(4, :) .* r(4) - P_x(6, :) .* X(5, :) .* (r(5) + comp .* X_sm) - X(5, :) .* mb(5);
Y(6, :) = P_x(6, :) .* X(5, :) .* (r(5) + comp .* X_sm) + P_x(6, :) .* X(6, :) .* r(6) - X(6, :) .* mb(6);

%Tabular Acropora Unenhanced
Y(7, :) = P_x(7, :) .* rec(7, :) - P_x(8, :) .* X(7, :) .* r(7) - X(7,:) .* mb(7);
Y(8, :) = P_x(8, :) .* X(7, :) .* r(7) - P_x(9, :) .* X(8, :) .* r(8) - X(8, :) .*mb(8);
Y(9, :) = P_x(9, :) .* X(8, :) .* r(8) - P_x(10, :) .* X(9, :) .* r(9) - X(9, :) .* mb(9);
Y(10, :) = P_x(10, :) .* X(9, :) .* r(9) - P_x(11, :) .* X(10, :) .* r(10) - X(10, :) .* mb(10);
Y(11, :) = P_x(11, :) .* X(10, :) .* r(10) - P_x(12, :) .* X(11, :) .* (r(11) + comp .* X_sm) - X(11, :) .* mb(11);
Y(12, :) = P_x(12, :) .* X(11, :) .* (r(11) + comp .* X_sm) + P_x(12, :) .* X(12, :) .* r(12) - X(12, :) .* mb(12);

%Corymbose Acropora Enhanced
Y(13, :) = P_x(13, :) .* rec(13, :) - P_x(14, :) .* X(13, :) .* r(13) - X(13,:) .* mb(13);
Y(14, :) = P_x(14, :) .* X(13, :) .* r(13) - P_x(15, :) .* X(14, :) .* r(14) - X(14, :) .*mb(14);
Y(15, :) = P_x(15, :) .* X(14, :) .* r(14) - P_x(16, :) .* X(15, :) .* r(15) - X(15, :) .* mb(15);
Y(16, :) = P_x(16, :) .* X(15, :) .* r(15) - P_x(17, :) .* X(16, :) .* r(16) - X(16, :) .* mb(16);
Y(17, :) = P_x(17, :) .* X(16, :) .* r(16) - P_x(18, :) .* X(17, :) .* r(17) - X(17, :) .* mb(17);
Y(18, :) = P_x(18, :) .* X(17, :) .* r(17) + P_x(18, :) .* X(18, :) .* r(18) - X(18, :) .* mb(18);

%Corymbose Acropora Unenhanced
Y(19, :) = P_x(19, :) .* rec(19, :) - P_x(20, :) .* X(19, :) .* r(19)  - X(19,:) .* mb(19);
Y(20, :) = P_x(20, :) .* X(19, :) .* r(19) - P_x(21, :) .* X(20, :) .* r(20) - X(20, :) .*mb(20);
Y(21, :) = P_x(21, :) .* X(20, :) .* r(20) - P_x(22, :) .* X(21, :) .* r(21) - X(21, :) .* mb(21);
Y(22, :) = P_x(22, :) .* X(21, :) .* r(21) - P_x(23, :) .* X(22, :) .* r(22) - X(22, :) .* mb(22);
Y(23, :) = P_x(23, :) .* X(22, :) .* r(22) - P_x(24, :) .* X(23, :) .* r(23) - X(23, :) .* mb(23);
Y(24, :) = P_x(24, :) .* X(23, :) .* r(23) + P_x(24, :) .* X(24, :) .* r(24) - X(24, :) .* mb(24);

%small massives Unenhanced
Y(25, :) = P_x(25, :) .* rec(25, :) - P_x(26, :) .* X(25, :) .* r(25) - X(25,:) .* mb(25);
Y(26, :) = P_x(26, :) .* X(25, :) .* r(25) - P_x(26, :) .*  X(25, :) .* r(25) - X(26, :) .* (mb(26)+ comp .* X_enhanced);
Y(27, :) = P_x(27, :) .* X(26, :) .* r(26) - P_x(27, :) .*  X(26, :) .* r(26) - X(27, :) .* (mb(27)+ comp .* X_enhanced);
Y(28, :) = P_x(28, :) .* X(27, :) .* r(27) - P_x(28, :) .*  X(27, :) .* r(27) - X(28, :) .* (mb(28)+ comp .* X_enhanced);
Y(29, :) = P_x(29, :) .* X(28, :) .* r(28) + P_x(29, :) .*  X(29, :) .* r(29) - X(29, :) .* (mb(29) + comp .* X_enhanced);

% Unnecessary as Y is initialized to all zeros
% Y(30, :) = 0; %small massives and encrusting constrained to less than 40 cm diameter

%Large massives Unenhanced
Y(31, :) = P_x(31, :) .* rec(31, :) - P_x(32, :) .* X(31, :) .* r(31) - X(31,:) .* mb(31);
Y(32, :) = P_x(32, :) .* X(31, :) .* r(31) - P_x(32, :) .* X(31, :) .* r(31) - X(32, :) .* mb(32);
Y(33, :) = P_x(33, :) .* X(32, :) .* r(32) - P_x(33, :) .* X(32, :) .* r(32) - X(33, :) .* mb(33);
Y(34, :) = P_x(34, :) .* X(33, :) .* r(33) - P_x(34, :) .* X(33, :) .* r(33) - X(34, :) .* mb(34);
Y(35, :) = P_x(35, :) .* X(28, :) .* r(28) - P_x(35, :) .* X(34, :) .* r(34) - X(35, :) .* mb(35);
Y(36, :) = P_x(36, :) .* X(35, :) .* r(35) + P_x(36, :) .* X(36, :) .* r(36) - X(36, :) .* mb(36);

% constrain between 0 and max cover
Y = max(Y, 0);
Y = min(Y, P);

Y = Y(:); % convert to column vector (necessary for ODE to work)
end
