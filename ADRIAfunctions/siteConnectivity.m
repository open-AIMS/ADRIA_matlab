function [TP_data, site_ranks, strongpred, site_ids, truncated] =  siteConnectivity(file_loc, con_cutoff, agg_func, swap, site_order)
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
%   site_order : string, array of recom connectivity IDs indicating order
%                  of TP values
%
% Output:
%   TP_data    : table[float], containing the transition probability for 
%                  all sites
%   site_ranks : table[float], centrality for each site
%   strongpred : matrix[float], strongest predecessor for each site
%   site_ids   : string, site IDs, order of which indicates the row/columns
%   truncated  : vector, of index positions that were removed
%
% Example: 
%     siteConnectivity('MooreTPmean.xlsx', 0.1)
arguments
    file_loc
    con_cutoff {mustBeFloat}
    agg_func = function_handle @mean
    swap logical = false
    site_order = []
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
    % fns = string({t_files.name});
    year_dirs = unique(locs);  % should be directory for each year
    
    tmp_data = [];
    TPbase = [];
    truncated = [];
    for year_dir_id = 1:length(year_dirs)
        file_path = year_dirs(year_dir_id);
        year_files = dir(file_path);
        
        year_data = year_files(~[year_files.isdir]);
        
        % sublocs = string({year_data.folder});
        fns = string({year_data.name});
        for f_id = 1:length(fns)
            fname = fns(f_id);
            f_loc = strcat(file_path, filesep, fname);
            truncate = false;

            x = readtable(f_loc, 'ReadRowNames', true, 'ReadVariableNames', true, 'CommentStyle', '#', 'TreatAsEmpty', "NA");
            site_ids = string(x.Properties.RowNames);
            if ~isempty(site_order)
                % Match up matrix order with site ids
                order_idx = NaN(length(site_order), 1);
                for i = 1:length(site_order)
                    try
                        order_idx(i) = find(site_order(i) == site_ids);
                    catch err
                        if err.identifier == "MATLAB:matrix:singleSubscriptNumelMismatch"
                            if ~ismember(i, truncated)
                                warning(strcat(site_order(i), " not found in site_ids! This site will be removed from runs."))
                                truncated(end+1) = i;
                                truncate = true;
                            end
                        end
                    end
                end

                if truncate
                    order_idx(truncated) = [];
                    site_order(truncated) = [];
                end

                site_ids = site_order;
            else
                % Reorder rows/columns to ensure identical indexes when matching up
                % with ordered spatial data
                [site_ids, order_idx] = sort(site_ids);
            end
            
            x = x(order_idx, order_idx);  % enforce order
            x_tmp = table2array(x);
            x_tmp(isnan(x_tmp)) = 0;  % Convert NaNs to 0
            if swap
                x_tmp = transpose(x_tmp);
            end

            if isempty(tmp_data)
                [w, h] = size(x_tmp);
                tmp_data = zeros(length(fns), w, h);
            end
            
            if isempty(TPbase)
                TPbase = zeros(length(year_dirs), w, h);
            end

            tmp_data(f_id, :, :) = x_tmp;
        end
        
        TPbase(year_dir_id, :, :) = squeeze(agg_func(tmp_data, 1));
        tmp_data = [];
    end
    
    % get stat of stats across all available years
    % e.g., mean of mean connectivity over years
    TPbase = squeeze(agg_func(TPbase, 1));
else
    %% Load a single transitional probability matrix
    x = readtable(file_loc, 'ReadRowNames', true, 'ReadVariableNames', true, 'CommentStyle', '#', 'TreatAsEmpty', "NA");
    site_ids = string(x.Properties.RowNames);
    
    if ~isempty(site_order)
        % Match up matrix order with site ids
        order_idx = NaN(length(site_order), 1);
        truncated = [];
        for i = 1:length(site_order)
            try
                order_idx(i) = find(site_order(i) == site_ids);
            catch err
                if err.identifier == "MATLAB:matrix:singleSubscriptNumelMismatch"
                    warning(strcat(site_order(i), " not found in site_ids! This site will be removed from runs."))
                    truncated(max(1, length(truncated))) = i;
                end
            end
        end
        
        if truncated
            order_idx(truncated) = [];
            site_order(truncated) = [];
        end
        
        site_ids = site_order;
    else
        % Reorder rows/columns to ensure identical indexes when matching up
        % with ordered spatial data
        [site_ids, order_idx] = sort(site_ids);
    end
    
    % Connectivity data should be in same order as site_data
    x = x(order_idx, order_idx);
    
    x_tmp = table2array(x);
    x_tmp(isnan(x_tmp)) = 0;  % Convert NaNs to 0
    
    % Transition probability matrix for all sites
    if swap
        TPbase = transpose(x_tmp);
    else
        TPbase = x_tmp;
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
    if isempty(eid)
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