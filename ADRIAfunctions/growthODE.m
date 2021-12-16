function Y = growthODE(X, r, P, mb, rec, comp)

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

%% Work in progress as at 10PM on 9th Nov 21

X = reshape(X, 36, 26);

% density dependent growth - constrain to zero at carrying capacity
P_x = min( max(P - sum(X, 3), 0.0), P);  % per species, per site (species * sites)

r_i = 1 - r;
r_p = 1 + r;

Y = zeros(36, 26);

%Tabular Acropora Enhanced
Y(1, :) = P_x(1, :) .* (X(1, :) + rec(1, :)) + X(1, :) .* r_i(1) - X(1, :) .* mb(1);
Y(2, :) = P_x(2, :) .* (X(2, :) + X(1, :) .* r_p(1)) + X(2, :) .* r_i(2) - X(2) .* mb(2);
Y(3, :) = P_x(3, :) .* (X(3, :) + X(2, :) .* r_p(2)) + X(3, :) .* r_i(3) - X(3) .* mb(3);
Y(4, :) = P_x(4, :) .* (X(4, :) + X(3, :) .* r_p(3)) + X(4, :) .* r_i(4) - X(4) .* mb(4);
Y(5, :) = P_x(5, :) .* (X(5, :) + X(4, :) .* r_p(4)) + X(5, :) .* r_i(5) - X(5) .* mb(5);
Y(6, :) = P_x(6, :) .* (X(6, :) + X(5, :) .* r_p(5)) + X(6, :) .* comp .* sum(X(25:30, :)) - X(6) .* mb(6);

%Tabular Acropora Unenhanced
Y(7, :) = P_x(7, :) .* (X(7, :) + rec(7, :)) + X(7, :) .* r_i(7) - X(7, :) .* mb(7);
Y(8, :) = P_x(8, :) .* (X(8, :) + X(7, :) .* r_p(7)) + X(8, :) .* r_i(8) - X(8, :) .* mb(8);
Y(9, :) = P_x(9, :) .* (X(9, :) + X(8, :) .* r_p(8)) + X(9, :) .* r_i(9) - X(9, :) .* mb(9);
Y(10, :) = P_x(10, :) .* (X(10, :) + X(9, :) .* r_p(9)) + X(10, :) .* r_i(10) - X(10, :) .* mb(10);
Y(11, :) = P_x(11, :) .* (X(11, :) + X(10, :) .* r_p(10)) + X(11, :) .* r_i(11) - X(11, :) .* mb(11);
Y(12, :) = P_x(12, :) .* (X(12, :) + X(11, :) .* r_p(11)) + X(12, :) .* comp .* sum(X(25:30, :)) - X(12, :) .* mb(12);

%Corymbose Acropora Enhanced
Y(13, :) = P_x(13, :) .* (X(13, :) + rec(13, :)) + X(13, :) .* r_i(13) - X(13, :) .* mb(13);
Y(14, :) = P_x(14, :) .* (X(14, :) + X(13, :) .* r_p(13)) + X(14, :) .* r_i(14) - X(14, :) .* mb(14);
Y(15, :) = P_x(15, :) .* (X(15, :) + X(14, :) .* r_p(14)) + X(15, :) .* r_i(15) - X(15, :) .* mb(15);
Y(16, :) = P_x(16, :) .* (X(16, :) + X(15, :) .* r_p(15)) + X(16, :) .* r_i(16) - X(16, :) .* mb(16);
Y(17, :) = P_x(17, :) .* (X(17, :) + X(16, :) .* r_p(16)) + X(17, :) .* r_i(17) - X(17, :) .* mb(17);
Y(18, :) = P_x(18, :) .* (X(18, :) + X(17, :) .* r_p(17)) - X(18, :) .* mb(18);

%Corymbose Acropora Unenhanced
Y(19, :) = P_x(19, :) .* (X(19, :) + rec(19, :)) + X(19, :) .* (r_i(19)) - X(19, :) .* mb(19);
Y(20, :) = P_x(20, :) .* (X(20, :) + X(19, :) .* (r_p(19))) + X(20, :) .* (r_i(20)) - X(20, :) .* mb(20);
Y(21, :) = P_x(21, :) .* (X(21, :) + X(20, :) .* (r_p(20))) + X(21, :) .* (r_i(21)) - X(21, :) .* mb(21);
Y(22, :) = P_x(22, :) .* (X(22, :) + X(21, :) .* (r_p(21))) + X(22, :) .* (r_i(22)) - X(22, :) .* mb(22);
Y(23, :) = P_x(23, :) .* (X(23, :) + X(22, :) .* (r_p(22))) + X(23, :) .* (r_i(23)) - X(23, :) .* mb(23);
Y(24, :) = P_x(24, :) .* (X(24, :) + X(23, :) .* (r_p(23))) - X(24, :) .* mb(24);

%small massives Unenhanced
Y(25, :) = P_x(25, :) .* (X(25, :) + rec(25, :)) + X(25, :) .* r_i(25) - X(25, :) .* mb(25);
Y(26, :) = P_x(26, :) .* (X(26, :) + X(25, :) .* (r_p(25))) + X(26, :) .* (r_i(26)) - X(26, :) .* (mb(26) + comp .* (X(6, :) + X(12, :)));
Y(27, :) = P_x(27, :) .* (X(27, :) + X(26, :) .* (r_p(26))) + X(27, :) .* (r_i(27)) - X(27, :) .* (mb(27) + comp .* (X(6, :) + X(12, :)));
Y(28, :) = P_x(28, :) .* (X(28, :) + X(27, :) .* (r_p(27))) + X(28, :) .* (r_i(28)) - X(28, :) .* (mb(28) + comp .* (X(6, :) + X(12, :)));
Y(29, :) = P_x(29, :) .* (X(29, :) + X(28, :) .* (r_p(28))) - X(29, :) .* (mb(29) + comp .* (X(6, :) + X(12, :)));
Y(30, :) = 0; %small massives and encrusting constrained to less than 40 cm diameter

%Large massives Unenhanced
Y(31, :) = P_x(31, :) .* (X(31, :) + rec(31, :)) + X(31, :) .* r_i(31) - X(31, :) .* mb(31);
Y(32, :) = P_x(32, :) .* (X(32, :) + X(31, :) .* r_p(31)) + X(32, :) .* r_i(32) - X(32, :) .* mb(32);
Y(33, :) = P_x(33, :) .* (X(33, :) + X(32, :) .* r_p(32)) + X(33, :) .* r_i(33) - X(33, :) .* mb(33);
Y(34, :) = P_x(34, :) .* (X(34, :) + X(33, :) .* r_p(33)) + X(34, :) .* r_i(34) - X(34, :) .* mb(34);
Y(35, :) = P_x(35, :) .* (X(35, :) + X(34, :) .* r_p(34)) + X(35, :) .* r_i(35) - X(35, :) .* mb(35);
Y(36, :) = P_x(36, :) .* (X(36, :) + X(35, :) .* r_p(35)) - X(36, :) .* mb(36);

% constrain between 0 and max cover
Y(Y < 0) = 0;
Y(Y > P) = P; 
Y = Y(:); % convert to column vector
end
