function Y = internalOptObjFunc(prefsites,nsitesdepth,nsitestotal,sites,ode_vars, coral_params)
% Warming and disturbance event going into the pulse function
        prefshadesites = prefsites(nsitesdepth+1:end);
        prefseedsites = prefsites(1:nsitesdepth);
        prefshadesites = sites(logical(prefshadesites));
        prefseedsites = sites(logical(prefseedsites));
       
        % Warming and disturbance event going into the pulse function
         ode_vars.Yshade(prefshadesites) = ode_vars.srm;
            
         % Apply reduction in DHW due to shading
         adjusted_dhw = max(0.0, ode_vars.dhw_step - ode_vars.Yshade);

        % Calculate bleaching mortality
        Sbl = 1 - ADRIA_bleachingMortality(ode_vars.tstep, ode_vars.neg_e_p1, ...
            ode_vars.neg_e_p2, ode_vars.assistadapt, ...
            ode_vars.natad, ode_vars.bleach_resist, adjusted_dhw);

        % proportional loss + proportional recruitment
        prop_loss = Sbl .* squeeze(ode_vars.Sw_t);
        Yin1 = ode_vars.Y_pstep .* prop_loss;

        % Seed each site with the value indicated with seed1/seed2
        Yin1(ode_vars.s1_idx, prefseedsites) = Yin1(ode_vars.s1_idx, prefseedsites) + ode_vars.seed1; % seed Enhanced Tabular Acropora
         Yin1(ode_vars.s2_idx, prefseedsites) = Yin1(ode_vars.s2_idx, prefseedsites) + ode_vars.seed2; % seed Enhanced Corymbose Acropora
            
        % Run ODE for all species and sites
        [~, Y] = ode45(@(t, X) growthODE4_KA(X, ode_vars.e_r, ode_vars.e_P, ode_vars.e_mb, ode_vars.rec, ode_vars.e_comp), ode_vars.tspan, Yin1, ode_vars.non_neg_opt);
        Y = Y(end, :);  % get last step in ODE
        
        % If any sites are above their maximum possible value,
        % proportionally adjust each entry so that their sum is <= P
        Y = reshape(Y, ode_vars.nspecies, nsitestotal);
        if any(sum(Y, 1) > ode_vars.e_P)
            idx = find(sum(Y, 1) > ode_vars.e_P);
            Ys = Y(:, idx);
            Y(:, idx) = (Ys ./ sum(Ys)) * ode_vars.e_P;
        end

        metrics = collectMetrics(Y,coral_params,{@coralTaxaCover});
        TC = mean(metrics.coralTaxaCover.total_cover,'all');
        Y = TC;
end
