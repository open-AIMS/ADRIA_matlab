function inputs = extractInputsUsed(fn)
% Convenience function to extract the input set used for a batch run.
%
% Inputs:
%     fn : str, path and filename of input record in netCDF format
%
% Outputs:
%     inputs : table, input table used for set of runs
    values = ncread(fn, "input_parameters");
    
    tmp = ADRIA();
    inputs = tmp.setParameterValues(values);
end