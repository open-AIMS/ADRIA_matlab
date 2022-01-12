function converted_names = humanReadableName(names, title_case)
% Make presentable parameter labels
%
% Inputs:
%     names : array[str], of parameter names
%     title_case
%
% Outputs:
%     converted_names : array[str], of cleaned parameter names

converted_names = names;
converted_names = strrep(converted_names, '_', ' ');

if exist('title_case', 'var') && (title_case == 1)
    for i = 1:length(converted_names)
        n = converted_names(i);
        orig_str = lower(n);
        expression = '(^|[\. ])\s*.';
        replace = '${upper($0)}';
        title_cased_str = regexprep(orig_str, expression, replace);
        converted_names(i) = title_cased_str;
    end
end
