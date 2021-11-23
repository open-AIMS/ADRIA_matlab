function pes = FuncPES2(C1,C)
    evprov = 0.2; % Relative importance of coral evenness for provisioning ES (proportion)
    strprov = 0.8; % Relative importance of structural complexity for provisioning ES (proportion)
    TCsatProv = 0.5; % Total coral cover at which scope to support Provisioning ES is maximised
    s = C1;
    tc = squeeze(sum(C,'all'))+C1;
    e = (((C1/tc).^2+(C(1)/tc).^2+(C(2)/tc).^2).^2)/3;
    pes = tanh(tc/TCsatProv)*(evprov*e+strprov*s);       
end