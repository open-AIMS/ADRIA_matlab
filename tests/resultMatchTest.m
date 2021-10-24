if exist(['../Outputs', '/Results60'], 'file')
    expected = load("../Outputs/Orig_Results60");
    changed = load("../Outputs/Results60");
    
    assert(isequaln(expected, changed));
end

