function [TP_data, site_ranks, strongpred, site_ids] =  siteConnectivity(file_loc, con_cutoff, agg_func, swap)
% Create transitional probability matrix indicating connectivity between
% sites, level of centrality, and the strongest predecessor for each site.
%
% NOTE: Transposes transitional probability matrix
%       If multiple files are read in, this assumes all file rows/cols 
%       follow the same order as the first file read in.
%
% Inputs:
%   file_loc   : str, path to data file (or datasets) to load.
%                  If a folder, searches subfolders as well.
%   con_cutoff : float, percent thresholds of max for weak connections in 
%                  network (defined by user or defaults in simConstants)
%   agg_func   : function_handle, defaults to `mean`.
%   swap       : logical, whether to transpose data.
%
% Output:
%   TP_data    : table[float], containing the transition probability for 
%                  all sites
%   site_ranks : table[float], centrality for each site
%   strongpred : matrix[float], strongest predecessor for each site
%   transpose  : logical, whether to transpose matrix or not.
%
% Example: 
%     siteConnectivity('MooreTPmean.xlsx', 0.1)
arguments
    file_loc
    con_cutoff {mustBeFloat}
    agg_func = function_handle @mean
    swap logical = false
end

if isfolder(file_loc)
    % Get list of files to combine
    files = dir(file_loc);
    
    t_dirs = [files.isdir];
    if isempty(files(~t_dirs))
        % no files in given directory, search subfolders
        
        t_file = strcat(file_loc, "/*/");
        files = dir(t_file);
        
        t_dirs = [files.isdir];
    end
    
    % Get list of files from list ignoring (sub)folders
    t_files = files(~t_dirs);

    locs = string({t_files.folder});
    fns = string({t_files.name});
    
    % Create list of full, absolute, paths
    num_files = length(locs);
    full_paths = string(zeros(num_files, 1));
    for i = 1:length(locs)
        full_paths(i) = fullfile(locs(i), fns(i));
    end

    % Load first file to determine size (width/height)
    x = readtable(full_paths(1), 'PreserveVariableNames', true, 'ReadVariableNames', true, 'CommentStyle', '#');
    
    % Retrieve and sort by site ids
    % This is to ensure identical indexes when matching up with spatial 
    % site data, which will also be ordered by site id.
    site_ids = x{:, 1};
    x(:, 1) = []; % remove row ID column
    [site_ids, order_idx] = sort(site_ids);  % reordering
    x = x(order_idx, order_idx);  % enforce order
    
    x_tmp = table2array(x);
    if swap
        x_tmp = transpose(x_tmp);
    end
    
    site_ids = string(site_ids);

    [w, h] = size(x_tmp);
    
    data = zeros(length(full_paths), w, h);
    data(1, :, :) = x_tmp;
    for fn_i = 2:length(full_paths)
        t_fn = full_paths(fn_i);
        x = readtable(t_fn, 'PreserveVariableNames', true, 'ReadVariableNames', true, 'CommentStyle', '#');
        x(:, 1) = [];  % remove row ID column
        
        % Reorder rows/columns, assuming identical ID orders...
        x = x(order_idx, order_idx);
        
        % Store data
        % Transition probability matrix for all sites
        % Data set is flipped from what ADRIA expects, so transpose.
        x_tmp = table2array(x);
        if swap
            x_tmp = transpose(x_tmp);
        end
        data(fn_i, :, :) = x_tmp;
    end
    
    % aggregate data with indicated aggregation method (default: mean)
    TPbase = squeeze(agg_func(data, 1));
else
    %% Load a single transitional probability matrix
    x = readtable(file_loc, 'PreserveVariableNames', true, 'ReadVariableNames', true, 'CommentStyle', '#');

    % remove site ids
    % F1(1, :) = [];
    site_ids = string(x{:, 1});
    x(:, 1) = [];
    
    % Reorder rows/columns to ensure identical indexes when matching up
    % with ordered spatial data
    [site_ids, order_idx] = sort(site_ids);
    x = x(order_idx, order_idx);
    
    % Transition probability matrix for all sites
    TPbase = table2array(x);
    if swap
        TPbase = transpose(TPbase);
    end
end

maxTP1cut = max(TPbase,[],'all')*con_cutoff;
TPbase(TPbase<maxTP1cut) = 0;  % filter out weak connections
        
% Change connectivity as a function of wind and tides
TP_data(:,:,1) = TPbase;
% NOTE we need to instead make this a variable adjacency matrix that changes 
% continuously as a function of wind and time and their combination


%% Create the digraphs, and modify plot parameters
DGbase = digraph(TPbase);
%Edgeweights
EW_base = DGbase.Edges.Weight;

C1 = centrality(DGbase, 'outdegree', 'Importance', EW_base);

%% Find strongest predecessors
nsites = length(C1);
strongpred = zeros(nsites, 2);
strongpred(:,1) = 1:nsites;
%need to find a way here to deal with empty cells for eid
for s = 1:nsites
    [eid,~] = inedges(DGbase,s);
    if isempty(eid) == 1 
        strongpred(s,2) = nan;
    else
        X = table2array(DGbase.Edges(eid,:));
        X(:,2) =[];
        mxm = max(X(:,2));
        strongpred(s,2) = find(X(:,2)==mxm, 1);
    end
end

site_ranks = table(C1);
% site_ranks(nsites+1:end,:) = [];  % Not sure what this was for

end