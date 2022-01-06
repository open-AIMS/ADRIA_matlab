function Y = Derive_CoralColourDiversity(Indices)

%%% %%% %%% %%% %%% %%% %%% %%% %%% 
%%% EXPERT ELICITED MODEL
%%% %%% %%% %%% %%% %%% %%% %%% %%% 

% Parameter distributions obtained by surveying experts following RRAP 
% ES provisioning workshop in August 2021

surv_results = readtable('./Expert Data/Coral_Colour_Diversity_Results_processed.csv', 'PreserveVariableNames', true);

% Obtain independent variable coefficients to predict coral colour diversity (sample from expert survey
% responses, weighted by R2)

% WE WILL NEED TO NORMALISE INDEPENDENT VARIABLE VALUES, SO THAT OUTPUT OF
% STAT MODEL SCALES BETWEEN 0 AND 1. MORE THOUGHT NEEDED FOR THIS STEP.

% num_vars = width(surv_results)-2;

beta_arb_acro = randsample(repelem(surv_results.Arb_Acro,surv_results.R2),1);
beta_tab_acro = randsample(repelem(surv_results.Tab_Acro,surv_results.R2),1);
beta_cor_acro = randsample(repelem(surv_results.Cor_Acro,surv_results.R2),1);
beta_cor_n_acro = randsample(repelem(surv_results.Cor_N_Acro,surv_results.R2),1);
beta_small_enc_massives = randsample(repelem(surv_results.Small_enc_massives,surv_results.R2),1);
beta_large_massives = randsample(repelem(surv_results.Large_massives,surv_results.R2),1);
beta_reef_rug = randsample(repelem(surv_results.Reef_Rug,surv_results.R2),1);
beta_rubble = randsample(repelem(surv_results.Rubble,surv_results.R2),1);
beta_macroalgae = randsample(repelem(surv_results.Macroalgae,surv_results.R2),1);

% CHECK THAT YOU ARE CALLING CORRECT TAXA!!!
Y = (beta_arb_acro.*Indices.covers_rel(:,:,1)) +  ... 
                                beta_tab_acro.*Indices.covers_rel(:,:,2) + ...
                                beta_cor_acro.*Indices.covers_rel(:,:,3) + ...
                                beta_cor_n_acro.*Indices.covers_rel(:,:,4) + ...
                                beta_small_enc_massives.*Indices.covers_rel(:,:,5) + ...
                                beta_large_massives.*Indices.covers_rel(:,:,6) + ...
                                beta_reef_rug.*Indices.rugosity + ...
                                beta_rubble.*(1-Indices.rubble_complementary) + ...
                                beta_macroalgae.*(1-Indices.Macroalgae_complementary);
                                      
   
end