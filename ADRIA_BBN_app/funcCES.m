function CES = funcCES(x,z)
    strcult = 0.5; % Relative importance of coral evenness for cultural ES (proportion)
    evcult = 0.5; % Relative importance of structural complexity for cultural ES (proportion)
    TCsatCult = 0.5; % Total coral cover at which scope to support Cultural ES is maximise
    CES = tanh(x/TCsatCult)*(evcult*z(1)+strcult*z(2));
end

