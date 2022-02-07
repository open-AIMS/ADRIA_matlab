function Y = internalOptObjFunc(prefsites,nsiteint,ode_vars)
% Warming and disturbance event going into the pulse function
        prefshadesites = prefsites(nsiteint+1:end);
        prefseedsites = prefsites(1:nsiteint);

        if (ode_vars.srm > 0) && (ode_vars.tstep <= ode_vars.shadeyears) && ~all(prefshadesites == 0)
            % Apply reduction in DHW due to shading
            adjusted_dhw = max(0.0, ode_vars.dhw_step - ode_vars.Yshade);
        else
            adjusted_dhw = ode_vars.dhw_step;
        end

        % Calculate bleaching mortality
        Sbl = 1 - ADRIA_bleachingMortality(ode_vars.tstep, ode_vars.neg_e_p1, ...
            ode_vars.neg_e_p2, ode_vars.assistadapt, ...
            ode_vars.natad, ode_vars.bleach_resist, adjusted_dhw);

        % proportional loss + proportional recruitment
        prop_loss = Sbl .* squeeze(ode_vars.Sw_t(p_step, :, :));
        Yin1 = Y_pstep .* prop_loss;

        if (tstep <= ode_vars.seedyears) && ~all(prefseedsites == 0)
            % Seed each site with the value indicated with seed1/seed2
            Yin1(ode_vars.s1_idx, prefseedsites) = Yin1(ode_vars.s1_idx, prefseedsites) + ode_vars.seed1; % seed Enhanced Tabular Acropora
            Yin1(ode_vars.s2_idx, prefseedsites) = Yin1(ode_vars.s2_idx, prefseedsites) + ode_vars.seed2; % seed Enhanced Corymbose Acropora
        end

        % Run ODE for all species and sites
        [~, Y] = ode45(@(t, X) growthODE4_KA(X, e_r, e_P, e_mb, rec, e_comp), tspan, Yin1, non_neg_opt);
        Y = Y(end, :);  % get last step in ODE
        
        % If any sites are above their maximum possible value,
        % proportionally adjust each entry so that their sum is <= P
        Y = reshape(Y, nspecies, nsites);
        if any(sum(Y, 1) > e_P)
            idx = find(sum(Y, 1) > e_P);
            Ys = Y(:, idx);
            Y(:, idx) = (Ys ./ sum(Ys)) * e_P;
        end

endode_vars.ode_vars.ode_vars.