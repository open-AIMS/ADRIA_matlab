if exist(['../Outputs', '/Results60'], 'file')
    expected = load("../Outputs/Orig_Results_RCP60_Alg1_reef");
    changed = load("../Outputs/Results_RCP60_Alg1_ES");
    
    assert(isequaln(expected, changed));
end

