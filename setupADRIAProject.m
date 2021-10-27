% This script generates ADRIA project structure.
% Assumes this is being run from the project root directory.

%% Set up location for example input/outputs if necessary
fileloc = pwd;
if ~exist([fileloc, '/Inputs'], 'dir')
    mkdir('Inputs')
end

if ~exist([fileloc, '/Outputs'], 'dir')
    mkdir('Outputs')
end


%% Define project if necessary
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

%proj = matlab.project.createProject("Name", "ADRIA", "Folder", pwd);

if exist('ADRIA.prj')
    proj = openProject(pwd);
else
     proj = matlab.project.createProject(pwd);
     proj.Name = 'ADRIA';
end


% Add project directories and files
proj.addFolderIncludingChildFiles('./ADRIAfunctions');
proj.addFolderIncludingChildFiles('./ADRIAmain');
proj.addFolderIncludingChildFiles('./examples');
proj.addFolderIncludingChildFiles('./Inputs');
