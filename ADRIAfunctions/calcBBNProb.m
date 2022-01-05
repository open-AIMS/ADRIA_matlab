function prob = calcBBNProb(dist,val,ind)
% Calculates a probability from input distribution
% Inputs -
%           dist : 1 by N (N large) array representing a sample from the distribution
%                  of the variable of interest
%           val : value to base conditional probability on (e.g P(x>val))
%           ind : integer indicating whetehr to calculate P(x>val) (ind =
%                 1) or P(x<val) (ind = 0)
% 
% Output -
%           prob : probability calculated from distribution

if logical(ind)
    prob = sum((dist>val))/length(dist);
else
    prob = sum((dist<val))/length(dist);
end
end

