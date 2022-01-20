function tInd = coralTaxaIndex(taxa_id)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    tInd = coralSpec().taxa_id == taxa_id;
    % ind_tmp = 1:length(taxa_ids);
    % tInd = taxa_ids == taxa_id;
end
