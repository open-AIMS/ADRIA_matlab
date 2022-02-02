function consts = extractConstantsUsed(fn)
% Convenience function to extract the constants used for a batch run.
%
% Inputs:
%     fn : str, path and filename of input record in netCDF format
%
% Outputs:
%     consts : struct, of constants used
    consts = simConstants();
    fns = fieldnames(consts);
    for f = string(fns')
        consts.(f) = ncreadatt(fn, "constants", f);
    end
end