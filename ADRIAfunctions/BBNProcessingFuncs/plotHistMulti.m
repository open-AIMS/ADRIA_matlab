function plotHistMulti(F,indx,varargin)
% Plots multiple histograms from a BBN inference
% Inputs -
%          F : BBN inference object (Cell object)
%          indx : index of the metric of interest in the inference object F
%
% Outputs - 
%         fig - figure handle for plot
%
if ~isempty(varargin{1})
    n = ceil(sqrt(varargin{1}));
else
    n = 25;
end
hold on
    for b = 1:length(F)
        f = F{b};
        h = histogram(f{indx},n,'FaceAlpha',0.3);
        h.Normalization = 'probability';
    end
end