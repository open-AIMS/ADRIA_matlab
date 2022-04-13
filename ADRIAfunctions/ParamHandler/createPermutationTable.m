function perm_table = createPermutationTable(params_tab,int_idx)
    % Creates a table of all permutations of the intervention inputs, which can be added to
    % ai.default params to make a run parameter table
    nvar = width(params_tab);
    
    % number of different values for each intervention parameter
    n = zeros(1, nvar);
    for l = 1:nvar
        n(l) = length(params_tab{1, l});
    end
    
    % total number of permutations
    Nperms = prod(n);
    
    % create storage table
    perm_table = zeros(Nperms, nargin);
    
    % vector denoting size of blocks for parameter repetitions
    N = zeros(1, length(n)+1);
    N(1) = Nperms;
    for k = 2:length(N)
        N(k) = N(k-1) ./ n(k-1);
    end
    
    % building permutation table
    perm_table(:, 1) = reshape(repmat(params_tab{1, 1}, N(2), 1), N(1), N(1)/(N(2) * n(1)));
    for j = 2:nvar
        perm_table(:, j) = reshape(repmat(params_tab{1, j}, N(j+1), N(1)/(n(j) * N(j+1))), N(1), 1);
    end

    % filter out nonsensical or repetitive values
    % repeating counterfactuals - find all rows where all intervention
    % parameters are zero and remover all but one (these are all
    % equivalent counterfactuals)
    inds_cf = find(sum(perm_table(:,int_idx),2)==0);
    perm_table(int_idx(2:end),:) = [];
end