

%% reorganising dhwdisttime for Anna

F0 = load('ADRIA_dhwdisttime.mat')';
F = F0.dhwdisttime;
F1 = permute(F, [3,1,2])
F2 = zeros(300,26);
for block = 1:10
    F2(block,  *sim,sites) = F1(year,sim,sites);
        end
    end

end
