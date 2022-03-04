function plotHistMulti(F,indx)
% Plots multiple histograms from a BBN inference
% Inputs -
%          F : BBN inference object (Cell object)
%          indx : index of the metric of interest in the inference object F

hold on
    for b = 1:length(F)
        f = F{b};
        numbins = ceil(sqrt(length(f{indx})));
        h = histogram(f{indx},20,'FaceAlpha',0.3,'NumBins',numbins,'Normalization', 'probability');
        h.Normalization = 'probability';
    end
end