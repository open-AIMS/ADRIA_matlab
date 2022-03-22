function site_map = recomToSiteIDIndexMap(recom_connectivity,site_ids)
% Creates a nsites*2 array mapping site id indexs to their positions in the
% connectivity matrix (necessary for pure site selection)
% Inputs -
%         recom_connectivity : nsites*1 cell of strings of IDs as they are
%                               ordered in the connectivity matrix.
%         site_ids : nsites*1 cell of strings of IDs as they are
%                               ordered in site data site_id column.

    nsites = length(recom_connectivity);
    site_map = zeros(nsites,2);
    site_map(:,1) = (1:nsites)';
    for ns = 1:nsites
        ind = find(ismember(recom_connectivity,site_ids{ns}));
        site_map(ns,2) = ind;
    end
end