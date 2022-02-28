function Y = fecundityScope(Y_pstep,coral_params, site_data)
% The scope that different coral groups and size classes have for 
% producing larvae without consideration of environment.
%
% Inputs:
%    Y_pstep, array with dimensions: nspecies x nsites
%    coral_params, structure
%    coral_params.fec, vector
% Output: fecundity per m2 of coral. Dimension: array of ntaxa (6) times nsites

% Coral fecundity per coral area of the different size classes.  
% When multiplied by the relative cover of each size class within taxa,
% this produces an estimate of the relative fecundity of each coral group and size.  
% Total relative fecundity of a group is then calculated as the sum of 
% fecundities across size classes. 

ngroups = 6;
nsites = size(Y_pstep, 2);
fec_groups = zeros(ngroups, nsites);

fec_all = coral_params.fec .* Y_pstep .*site_data.area';

fec_groups(1, :) = sum(fec_all(1:6, :)); %Tabular Acropora enhanced
fec_groups(2, :) = sum(fec_all(7:12, :)); %Tabular Acropora unenhanced
fec_groups(3, :) = sum(fec_all(13:18, :)); %Corymbose Acropora enhanced
fec_groups(4, :) = sum(fec_all(19:24, :)); %Corymbose Acropora unenhanced
fec_groups(5, :) = sum(fec_all(25:30, :)); %Small massives and encrusting
fec_groups(6, :) = sum(fec_all(31:36, :)); %Large massives

Y = fec_groups;
end 
