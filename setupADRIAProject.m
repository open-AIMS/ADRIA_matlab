% This script generates ADRIA project structure.
% Assumes this is being run from the project root directory.


global ADRIA_INPUT_DIR
global ADRIA_OUTPUT_DIR

% Set these to your preferred input/output locations
ADRIA_INPUT_DIR = "Inputs/";
ADRIA_OUTPUT_DIR = "Outputs/";


try
    proj = currentProject();

    if proj.Name == 'ADRIA'
        disp("ADRIA project is already loaded")
        return
    end
catch proj
    msgText = getReport(proj);
    
    if contains(msgText, 'No project is currently loaded.')
        disp("No project loaded, creating ADRIA project")
    end
end

proj = openProject('.');

% Add project directories and files
proj.addFolderIncludingChildFiles('./ADRIAfunctions');
proj.addFolderIncludingChildFiles('./ADRIAmain');
proj.addFolderIncludingChildFiles('./examples');
proj.addFolderIncludingChildFiles('./Inputs');
