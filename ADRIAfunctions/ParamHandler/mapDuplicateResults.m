function Y = mapDuplicateResults(Yi, u_r, g_idx)
% Map results back to their duplicate scenario entries.
%
% Inputs:
%   Yi    : struct, of results
%   u_r   : array of unique row
%   g_idx : array, of unique ids of same height as `Yi`
%
% Outputs:
%   Y     : struct, collated results
    num_unique = length(u_r);
    
    % Prep result struct
    Y = struct();
    f_n = fieldnames(Yi);
    n_fn = length(f_n);
    for f = 1:n_fn
        fn = f_n(f);
        fn = fn{1};
        
        Y_ss = Yi.(fn);
        Y.(fn) = zeros(size(Y_ss));
        
        if ~(fn == "C")
            for i = 1:num_unique
                Y.(fn)(:, :, g_idx == i, :) = Y_ss(:, :, i, :);
            end
        else
            for i = 1:num_unique
                Y.(fn)(:, :, :, g_idx == i, :) = Y_ss(:, :, :, i, :);
            end
        end
    end

end
