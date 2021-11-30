function Y = ADRIA4groupsODE(X, r, P, mb)

P_x = P - sum(X);
Y = r' .* X .* P_x - X .* mb';
% Y(Y < 0) = 0;  % function is called with non-negative=true
Y(Y > P) = P;  % constrain to max cover

end
