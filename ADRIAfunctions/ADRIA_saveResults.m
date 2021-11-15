function ADRIA_saveResults(data, filename)
    % Save results to file.
    %
    % If file is not specified, generates a filename based on date/time
    % 
    % Inputs:
    %     data     : any, data to save
    %     filename : str, file name and location to save data to
    if ~exist('filename', 'var')
        right_now = datetime(now, 'ConvertFrom', 'datenum');
        right_now = replace(string(right_now), ' ', '_');
        right_now = replace(right_now, ':', '');
        
        filename = strcat('ADRIA_results_', right_now, '.mat');
        
        fprintf('File name not provided. Saving results to %s \n', filename)
    end
    
    if ~endsWith(filename, '.mat')
        filename = strcat(filename, '.mat');
    end

    save(filename, 'data');    
end
