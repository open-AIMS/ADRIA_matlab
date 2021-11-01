function result = paramCombinations(elements)
% Generate distinct combinations
%
% Source:
% https://au.mathworks.com/matlabcentral/answers/98191-how-can-i-obtain-all-possible-combinations-of-given-vectors-in-matlab#answer_107541
%
% Example:
%   >> elements = {0:1; 0:1};
%   >> paramCombinations(elements)
%   result =
% 
%      0     0
%      1     0
%      0     1
%      1     1
    combinations = cell(1, numel(elements)); %set up the varargout result
    [combinations{:}] = ndgrid(elements{:});
    combinations = cellfun(@(x) x(:), combinations,'uniformoutput',false); %there may be a better way to do this
    tmp = [combinations{:}]; % NumberOfCombinations by N matrix. Each row is unique.
    
    % This has to be of cell type, as the resulting table could hold
    % multiple ranges/combinations of varying lengths
    result = num2cell(tmp, 2);
end