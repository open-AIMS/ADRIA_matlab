function tInd = taxaIndex(taxa,taxa_id)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    ind_tmp =1:length(taxa_id);
    tInd = ind_tmp(taxa_id == taxa);
end

