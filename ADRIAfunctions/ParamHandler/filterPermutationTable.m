function perm_tbl_fil = filterPermutationTable(perm_tbl)
    % Filters out nonsensical or repetitive values from an ADRIA() parameter 
    % table
    % INPUTS:
    %       perm_tbl: table of parameter permutations (k by 312)
    % OUTPUTS:
    %       perm_tbl_fil: filtered version of input table of parameter
    %       permutations

    % repeating counterfactuals - find all rows where all intervention
    % parameters are zero and remove all but one 
    inds_cf = find((perm_tbl.SRM==0)&(perm_tbl.fogging==0)&(perm_tbl.Seed1==0)&(perm_tbl.Seed2==0));
    perm_tbl(inds_cf(2:end),:) = [];

    % now find cases of duplicates where just seeding parameters are zero
    inds_seed = find((perm_tbl.Seed1==0)&(perm_tbl.Seed2==0));
    % where seeding is not occuring, set dependent parameters to zero
    perm_tbl.Seedyrs(inds_seed) = zeros(size(perm_tbl.Seedyrs(inds_seed)));
    perm_tbl.Seedfreq(inds_seed) = zeros(size(perm_tbl.Seedfreq(inds_seed)));
    perm_tbl.Seedyr_start(inds_seed) = zeros(size(perm_tbl.Seedyr_start(inds_seed)));

    % find cases of duplicates where just shading parameters are zero
    inds_shade = find((perm_tbl.SRM==0)&(perm_tbl.fogging==0));
    % where shading is not occuring, set dependent parameters to zero
    perm_tbl.Shadeyrs(inds_shade) = zeros(size(perm_tbl.Shadeyrs(inds_shade)));
    perm_tbl.Shadefreq(inds_shade) = zeros(size(perm_tbl.Shadefreq(inds_shade)));
    perm_tbl.Shadeyr_start(inds_shade) = zeros(size(perm_tbl.Shadeyr_start(inds_shade)));

    % remove duplicate entries
    perm_tbl_fil = unique(perm_tbl,'rows','stable');

end