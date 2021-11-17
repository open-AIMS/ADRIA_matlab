function PES = funcPES(x,z)
%UNTITLED3 Summary of this function goes here
    evprov = 0.2; % Relative importance of coral evenness for provisioning ES (proportion)
    strprov = 0.8; % Relative importance of structural complexity for provisioning ES (proportion)
    TCsatProv = 0.5; % Total coral cover at which scope to support Provisioning ES is maximised
    PES = tanh(x/TCsatProv)*(evprov*z(1) + strprov*z(2));
end

