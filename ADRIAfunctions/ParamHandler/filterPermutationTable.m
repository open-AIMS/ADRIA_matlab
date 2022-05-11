function perm_table_fil = filterPermutationTable(perm_table,params_table)

    % filter out nonsensical or repetitive values
    % repeating counterfactuals - find all rows where all intervention
    % parameters are zero and remove all but one (these are all
    % equivalent counterfactuals)
    inds_cf = find((perm_table.SRM==0)&(perm_table.fogging==0)&(perm_table.Seed1==0)&(perm_table.Seed2==0));
    perm_table(inds_cf(2:end),:) = [];
    % now find cases of duplicates where just seeding or just shading
    % parameters are zero
    inds_seed = find((perm_table.Seed1==0)&(perm_table.Seed2==0));
    % where seeding is not occuring, set dependent parameters to zero
    perm_table.Seedyrs(inds_seed) = zeros(size(perm_table.Seedyrs(inds_seed)));
    perm_table.Seedfreq(inds_seed) = zeros(size(perm_table.Seedfreq(inds_seed)));
    perm_table.Seedyr_start(inds_seed) = zeros(size(perm_table.Seedyr_start(inds_seed)));

    inds_shade = find((perm_table.SRM==0)&(perm_table.fogging==0));
    % where shading is not occuring, set dependent parameters to zero
    perm_table.Shadeyrs(inds_shade) = zeros(size(perm_table.Shadeyrs(inds_shade)));
    perm_table.Shadefreq(inds_shade) = zeros(size(perm_table.Shadefreq(inds_shade)));
    perm_table.Shadeyr_start(inds_shade) = zeros(size(perm_table.Shadeyr_start(inds_shade)));
    % remove duplicate entries
    perm_table_fil =unique(perm_table,'rows','stable');

end