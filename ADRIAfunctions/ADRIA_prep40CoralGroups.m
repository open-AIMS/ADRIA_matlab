function Y = ADRIA_prep40CoralGroups(X, r, P, mb,rec)

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
P_x = P - sum(X,'All');
P_x(P_x <0) = 0; %density dependent growth - constrain to zero at carrying capacity

%Tabular Acropora
Y(1) = P_x.*(X(1).*(1-r(1)) + rec(1)) - X(1).*mb(1);
Y(2) = P_x.*(X(2).*(1-r(2)) + X(1).*(1+r(1))) - X(2).*mb(2);
Y(3) = P_x.*(X(3).*(1-r(3)) + X(2).*(1+r(2))) - X(3).*mb(3);
Y(4) = P_x.*(X(4).*(1-r(4)) + X(3).*(1+r(3))) - X(4).*mb(4);
Y(5) = P_x.*(X(5).*(1-r(5)) + X(4).*(1+r(4))) - X(5).*mb(5);
Y(6) = P_x.*(X(6).*(1-r(6)) + X(5).*(1+r(5))) - X(6).*mb(6);

%Corymbose Acropora
Y(7) = P_x.*(X(7).*(1-r(7)) + rec(2)) - X(7).*mb(7);
Y(8) = P_x.*(X(8).*(1-r(8)) + X(7).*(1+r(7))) - X(8).*mb(8);
Y(9) = P_x.*(X(9).*(1-r(9)) + X(8).*(1+r(8))) - X(9).*mb(9);
Y(10) = P_x.*(X(10).*(1-r(10)) + X(9).*(1+r(9))) - X(10).*mb(10);
Y(11) = P_x.*(X(11).*(1-r(11)) + X(10).*(1+r(10))) - X(11).*mb(11);
Y(12) = P_x.*(X(12).*(1-r(12)) + X(11).*(1+r(11))) - X(12).*mb(12);

%Small massives
Y(13) = P_x.*(X(13).*(1-r(13)) + rec(3)) - X(13).*mb(13);
Y(14) = P_x.*(X(14).*(1-r(14)) + X(13).*(1+r(13))) - X(14).*mb(14);
Y(15) = P_x.*(X(15).*(1-r(15)) + X(14).*(1+r(14))) - X(15).*mb(15);
Y(16) = P_x.*(X(16).*(1-r(16)) + X(15).*(1+r(15))) - X(16).*mb(16);
Y(17) = P_x.*(X(17).*(1-r(17)) + X(16).*(1+r(16))) - X(17).*mb(17);
Y(18) = P_x.*(X(18).*(1-r(18)) + X(17).*(1+r(17))) - X(18).*mb(18);

%Large massives
Y(19) = P_x.*(X(19).*(1-r(19)) + rec(4)) - X(19).*mb(19);
Y(20) = P_x.*(X(20).*(1-r(20)) + X(19).*(1+r(19))) - X(20).*mb(20);
Y(21) = P_x.*(X(21).*(1-r(21)) + X(20).*(1+r(20))) - X(21).*mb(21);
Y(22) = P_x.*(X(22).*(1-r(22)) + X(21).*(1+r(21))) - X(22).*mb(22);
Y(23) = P_x.*(X(23).*(1-r(23)) + X(22).*(1+r(22))) - X(23).*mb(23);
Y(24) = P_x.*(X(24).*(1-r(24)) + X(23).*(1+r(23))) - X(24).*mb(24);

% Y(Y < 0) = 0;  % function is called with non-negative = true
% Y(Y > P) = P;  % constrain to max cover

end

