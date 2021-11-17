%%Calculate evenness across functional coral groups in ReefMod

function Y = coralEvennessReefMod(X)  
psqr = zeros(size(X.covers,1),size(X.covers,2),size(X.covers,3)); %indices are: (1) reef, (2) time steps, 3) coral groups
%sumpsqr(reef,t) = zeros(size(X.covers,1),size(X.covers,2));
for reef = 1:size(X.covers,1)
        for t = 1:size(X.covers,2)
            for group = 1:size(X.covers,3)
                psqr(reef,t,group) = (X.covers(reef,t,group)./X.total_cover(reef,t)).^2;
            end
            sumpsqr(reef,t) = sum(psqr(reef,t,:));
        end
end
N = X.NCORALGROUPS;
simpsonD = 1./sumpsqr; % Hill 1973, Ecology 54:427-432
Y = simpsonD./N;  %Group evenness 
end
   




