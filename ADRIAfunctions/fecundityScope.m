function Y = fecundityScope(Y_pstep,coral_params)
% The scope that different coral size classes have for .
%
% Inputs:
%    Y_pstep, array with size nspecies x nsites
%    coral_params, structure
%    coral_params.fec, vector

%relative scope for fecundity of all size classes and species by multiplying with
%proportional cover
fec_all =  coral_params.fec.*Y_pstep; 
fec_species = zeros(size(Y_pstep,1),size(Y_pstep,2));
fec_species(1, :) = sum(fec_all(1:6, :)); %Tabular Acropora enhanced
fec_species(7, :) = sum(fec_all(7:12, :)); %Tabular Acropora unenhanced
fec_species(13, :) = sum(fec_all(13:18, :)); %Corymbose Acropora enhanced
fec_species(19, :) = sum(fec_all(19:24, :)); %Corymbose Acropora unenhanced
fec_species(25, :) = sum(fec_all(25:30, :)); %Small massives
fec_species(31, :) = sum(fec_all(31:36, :)); %Large massives

Y = fec_species;
end
