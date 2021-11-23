function Y = ADRIA4groupsODE(t, X, parms)
Y = zeros(4, 1);

% Unenhanced sensitive
Y(1) = parms.r(1) * X(1) * (parms.P - sum(X)) - X(1) * parms.mb(1);
% Enhanced sensitive
Y(2) = parms.r(2) * X(2) * (parms.P - sum(X)) - X(2) * parms.mb(2);
% Unenhanced hardy
Y(3) = parms.r(3) * X(3) * (parms.P - sum(X)) - X(3) * parms.mb(3);
% Enhanced hardy
Y(4) = parms.r(4) * X(4) * (parms.P - sum(X)) - X(4) * parms.mb(4);
Y(Y < 0) = 0;
% Y(Y>parms.P) = parms.P;
end
