function consts = extractConstantsUsed(fn)
    consts = simConstants();
    fns = fieldnames(consts);
    for f = string(fns')
        consts.(f) = ncreadatt(fn, "constants", f);
    end
end