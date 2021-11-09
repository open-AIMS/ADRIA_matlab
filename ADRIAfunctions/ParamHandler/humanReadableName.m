function converted_names = humanReadableName(names)
% Make presentable parameter labels
%
% Inputs:
%     names : array[str], of parameter names
%
% Outputs:
%     converted_names : array[str], of cleaned parameter names

    converted_names = names;
    converted_names = strrep(converted_names, '_', ' ');
end
