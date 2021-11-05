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
    if exist('ADRIA.prj', 'file')
        proj = openProject(pwd);
    else
        proj = currentProject();
    end
    
    if proj.Name == "ADRIA"
        disp("ADRIA project is already loaded")
        return
    else
        close(proj)
    end
catch proj
    msgText = getReport(proj);
    
    if contains(msgText, 'No project is currently loaded.')
        disp("No project loaded, creating ADRIA project")
    end
end

try
    % For MATLAB 2021a
    proj = matlab.project.createProject("Name", "ADRIA", "Folder", pwd);
    proj.addPath(pwd);
    
    % see note below
    proj.addPath('./ADRIAfunctions/ParamHandler');
catch
    disp("Trying older approach")
    % Try older approach if any errors are encountered
    proj = matlab.project.createProject(pwd);
    proj.Name = 'ADRIA';
    addPath(proj, pwd);
    
    % see note below
    addPath(proj, './ADRIAfunctions/ParamHandler');
end

% Note: Ran into an issue organizing files into related "modules"
%       e.g., 'ADRIAfunctions/ParamHandler'.
%       The docs for `addFolderIncludingChildFiles` state that it will
%       add subfolders to a project. In actuality it appears to add files 
%       to the project details, but does not add these to the search path 
%       so that defined functions are not accessible
%       (at least for R2021a).
%       This behavior differs from adding top-level directories.
%       https://au.mathworks.com/help/matlab/ref/matlab.project.project.addfolderincludingchildfiles.html
%
%       For now I am manually adding this directory...
proj.addFolderIncludingChildFiles('./ADRIAfunctions/ParamHandler');


% Add main project directories and files
proj.addFolderIncludingChildFiles('./ADRIAfunctions');
proj.addFolderIncludingChildFiles('./ADRIAmain');
proj.addFolderIncludingChildFiles('./examples');
proj.addFolderIncludingChildFiles('./Inputs');