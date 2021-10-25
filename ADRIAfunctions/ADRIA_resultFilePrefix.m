function prefix = ADRIA_resultFilePrefix(RCP, alg_ind, filepath)
% Generate file prefix for given RCP and alg_ind value.
% Note: uses hardcoded 'Outputs' directory if `filepath` is not specified
% 
% Inputs:
%     RCP      : int, RCP number
%     alg_ind  : int, algorithm choice (1 - 3)
%     filepath : str, location to save file to. Defaults to 'Outputs/'
    if ~exist('filepath', 'var')
        filepath = "Outputs/";
    end
        
    prefix = strcat(filepath, 'Results_RCP', num2str(RCP), '_Alg', num2str(alg_ind));
end