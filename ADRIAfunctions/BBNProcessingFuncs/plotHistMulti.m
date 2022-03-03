function plotHistMulti(F,indx)
% Plots multiple histograms from a BBN inference
% Inputs -
%          F : BBN inference object (Cell object)
%          indx : index of the metric of interest in the inference object F
%
% Outputs - 
%         fig - figure handle for plot
%

hold on
    for b = 1:length(F)
        f = F{b};
        h = histogram(f{indx},20,'FaceAlpha',0.3);
        h.Normalization = 'probability';
    end
end