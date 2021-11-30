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
catch
    disp("Trying older approach")
    % Try older approach if any errors are encountered
    proj = matlab.project.createProject(pwd);
    proj.Name = 'ADRIA';
    
end

addPath(proj, pwd);

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
%       For now I am manually adding directories directly
addFolderIncludingChildFiles(proj, './ADRIAfunctions/ParamHandler');

% Add main directories and files to project spec
addFolderIncludingChildFiles(proj, './ADRIAfunctions');
addFolderIncludingChildFiles(proj, './ADRIAmain');
addFolderIncludingChildFiles(proj, './examples');
addFolderIncludingChildFiles(proj, './Inputs');


% Add to MATLAB path
addPath(proj, './ADRIAfunctions/ParamHandler');
addPath(proj, './ADRIAfunctions');
addPath(proj, './ADRIAmain');
addPath(proj, './examples');
addPath(proj, './Inputs');


% Programmatically install toolbox:
% https://au.mathworks.com/help/matlab/ref/matlab.addons.toolbox.installtoolbox.html