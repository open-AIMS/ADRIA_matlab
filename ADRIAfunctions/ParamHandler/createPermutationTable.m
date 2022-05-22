function perm_tbl = createPermutationTable(params_tbl)
    % Creates a table of all permutations of the intervention inputs, which can be added to
    % ai.default_params to make a run parameter table
    % INPUTS:
    %       params_tbl: 1 by k table where k is the number of parameters to
    %       permute. The ith column contains an array which lists each value
    %       for the ith parameter.
    % OUTPUTS:
    %       perm_tbl: N by k table where N is the number of possible
    %       permutations (unique combinations) of the k parameters.

    nvar = width(params_tbl);
    
    % number of different values for each intervention parameter
    n = zeros(1, nvar);
    for l = 1:nvar
        n(l) = length(params_tbl{1, l});
    end
    
    % total number of permutations
    Nperms = prod(n);
    
    % create storage table
    perm_tbl = zeros(Nperms, nargin);
    
    % vector denoting size of blocks for parameter repetitions
    N = zeros(1, length(n)+1);
    N(1) = Nperms;
    for k = 2:length(N)
        N(k) = N(k-1) ./ n(k-1);
    end
    
    % building permutation table
    perm_tbl(:, 1) = reshape(repmat(params_tbl{1, 1}, N(2), 1), N(1), N(1)/(N(2) * n(1)));
    for j = 2:nvar
        perm_tbl(:, j) = reshape(repmat(params_tbl{1, j}, N(j+1), N(1)/(n(j) * N(j+1))), N(1), 1);
    end

end