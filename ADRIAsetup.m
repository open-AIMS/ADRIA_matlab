function ADRIAsetup(varargin)
% script to run matlab project file on hpc
if size(varargin,1) == 0
    % if no path supplied use pwd
    open('ADRIA.prj');
    % run('config.m');
else
    % if path to project supplied, use this
    open(strcat(varargin{1},'ADRIA.prj'));
    % run(strcat(varargin{1}, 'config.m'));
    % run('config.m');
end
