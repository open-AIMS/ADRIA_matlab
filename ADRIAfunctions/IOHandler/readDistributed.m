function data = readDistributed(filename, var_names)
    if ~exist("var_names", "var")
        var_names = {'TC', 'C', 'E', 'S'};
    end

    data = struct();
    for v = var_names
        data.(v) = ncread(filename, v);
    end
end