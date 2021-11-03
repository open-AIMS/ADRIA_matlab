function y = ADRIA_siteobj(x, WS)
    % multi-objective function for optimal site selection
    % x is a 1*26 vec of normalised weightings
    % y is a 1*5 vector describing the additive value of the attributes
    % i.e. y(i) is the value of the ith attribute
    % WS is a matrix of values for each of the sites and attributes
    % i.e. WS(i,k) is the value of the kth attribute at the ith site
    
     y = zeros(1,size(WS,2));
     for k = 1:size(WS,2)
         y(k) = sum(x'.*WS(:,k)); % y(i is the value of the ith attribute for site selection x)
     end

end