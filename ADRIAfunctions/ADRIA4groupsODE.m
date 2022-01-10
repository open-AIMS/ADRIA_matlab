function Y = ADRIA4groupsODE(X, r, P, mb)
% Growth function (?)
%
% Inputs:
%   X  : matrix, base population
%   r  : matrix, growth rate
%   P  : float, maximum possible coral cover
%   mb : array, background mortality
P_x = P - sum(X);
Y = r' .* X .* P_x - X .* mb';
Y(Y > P) = P;  % constrain to max cover

end
