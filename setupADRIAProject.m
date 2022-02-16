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

try
    proj = currentProject;
    close(proj);
catch err
    if ~(strcmp(err.identifier, 'MATLAB:project:api:NoProjectCurrentlyLoaded'))
        rethrow(err);
    end
end


%% Define project if necessary
if exist('ADRIA.prj', 'file')
    proj = openProject(pwd);
else
    disp("ADRIA project file not found, recreating project.");
end

try
    % For MATLAB 2021a
    proj = matlab.project.createProject("Name", "ADRIA", "Folder", pwd);
catch err
    if ~(strcmp(err.identifier, 'project:creation:failure'))
        disp("Trying older approach")
        % Try older approach if any errors are encountered
        proj = matlab.project.createProject(pwd);
        proj.Name = 'ADRIA';
    end
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
addFolderIncludingChildFiles(proj, './ADRIAfunctions/SystemInfo');
addFolderIncludingChildFiles(proj, './ADRIAfunctions/IOHandler');
addFolderIncludingChildFiles(proj, './ADRIAfunctions/Metrics');
addFolderIncludingChildFiles(proj, './ADRIAfunctions/Plotting');
addFolderIncludingChildFiles(proj, './ADRIAfunctions/Translation');
addFolderIncludingChildFiles(proj, './ADRIAfunctions/third_party/ndSparse');

% Add main directories and files to project spec
addFolderIncludingChildFiles(proj, './ADRIAfunctions');
addFolderIncludingChildFiles(proj, './ADRIAmain');
addFolderIncludingChildFiles(proj, './examples');
addFolderIncludingChildFiles(proj, './examples/running_ADRIA');
addFolderIncludingChildFiles(proj, './examples/running_ADRIA_HPC');
addFolderIncludingChildFiles(proj, './examples/optimization');

addFolderIncludingChildFiles(proj, './Inputs');
addFolderIncludingChildFiles(proj, './Inputs/Moore');
addFolderIncludingChildFiles(proj, './Inputs/Moore/connectivity');
addFolderIncludingChildFiles(proj, './Inputs/Moore/DHWs');
addFolderIncludingChildFiles(proj, './Inputs/Moore/site_data');


% Add to MATLAB path
addPath(proj, './ADRIAfunctions/SystemInfo');
addPath(proj, './ADRIAfunctions/ParamHandler');
addPath(proj, './ADRIAfunctions/IOHandler');
addPath(proj, './ADRIAfunctions/Metrics');
addPath(proj, './ADRIAfunctions/Plotting');
addPath(proj, './ADRIAfunctions/Translation');

addPath(proj, './ADRIAfunctions/third_party/ndSparse');

addPath(proj, './ADRIAfunctions');
addPath(proj, './ADRIAmain');
addPath(proj, './examples');
addPath(proj, './examples/running_ADRIA');
addPath(proj, './examples/running_ADRIA_HPC');
addPath(proj, './examples/optimization');
addPath(proj, './Inputs');

addPath(proj, './Inputs/Moore');
addPath(proj, './Inputs/Moore/connectivity');
addPath(proj, './Inputs/Moore/DHWs');
addPath(proj, './Inputs/Moore/site_data');
addPath(proj, './Inputs/inputs_forecast');
addPath(proj, './Inputs/inputs_hindcast');


% Programmatically install toolbox:
% https://au.mathworks.com/help/matlab/ref/matlab.addons.toolbox.installtoolbox.html