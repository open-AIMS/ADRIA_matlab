function ES_Tourism = ES_Tourism_fun(Indices) 
% Prediction is based on Vercelloni et al. (2017) 
alpha = 1e-4; 
% alpha is an intercept parameter 
% These are coefficients estimated by Vercelloni et al. 
beta_citizen_coralcoloruniformity = -1.4; 
beta_citizen_structuralcomplexity = +1.6;
LinearComponent = alpha + ... 
    Indices.StructuralComplexityVisual.*beta_citizen_structuralcomplexity + ... 
    (1 - Indices.CoralColourDiversity).*beta_citizen_coralcoloruniformity; 
    % The link function of the GLM is logit 
    ES_Tourism = exp(LinearComponent)./(1 + exp(LinearComponent)); 
end