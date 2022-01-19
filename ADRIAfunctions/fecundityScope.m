function Y = fecundityScope(Y_pstep,coral_params)
% The scope that different coral size classes have for .
%
% Inputs:
%    Y_pstep, array with dimensions: nspecies x nsites
%    coral_params, structure
%    coral_params.fec, vector
% Output: relative fecundity. Dimension: array of ntaxa (6) times nsites

% Coral fecundity per coral area of the different size classes from 
% coralParams are normalised (non-dimensionalised) such th6at relative 
% fecundity of the largest coral size classes = 1.  When multiplied by 
% relative cover of each size class within taxa, this allows us to
% estimate the total relative fecundity of each coral group.  

%relative scope for fecundity of all size classes and species by multiplying with
%proportional cover

ngroups = 6;
nsites = size(Y_pstep, 2);
fec_groups = zeros(ngroups, nsites);

fec_all =  coral_params.fec.* Y_pstep; %

fec_groups(1, :) = sum(fec_all(1:6, :)); %Tabular Acropora enhanced
fec_groups(2, :) = sum(fec_all(7:12, :)); %Tabular Acropora unenhanced
fec_groups(3, :) = sum(fec_all(13:18, :)); %Corymbose Acropora enhanced
fec_groups(4, :) = sum(fec_all(19:24, :)); %Corymbose Acropora unenhanced
fec_groups(5, :) = sum(fec_all(25:30, :)); %Small massives and encrusting
fec_groups(6, :) = sum(fec_all(31:36, :)); %Large massives

Y = fec_groups;
end 
