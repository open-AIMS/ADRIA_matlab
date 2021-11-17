Data = readmatrix('ADRIA_BBN_Data.csv');

strcult = 0.5; % Relative importance of coral evenness for cultural ES (proportion)
evcult = 0.5; % Relative importance of structural complexity for cultural ES (proportion)
evprov = 0.2; % Relative importance of coral evenness for provisioning ES (proportion)
strprov = 0.8; % Relative importance of structural complexity for provisioning ES (proportion)
TCsatCult = 0.5; % Total coral cover at which scope to support Cultural ES is maximised
TCsatProv = 0.5; % Total coral cover at which scope to support Provisioning ES is maximised

% average over time
TC_i = squeeze(mean(TC,1));
S_i = squeeze(mean(S,1));
E_i = squeeze(mean(E,1));


%%
% plotting CES against PES
% CES and PES for example intervention scenarios on sites 1-26 (alternatively could
% average over sites)
CES_i = tanh(TC_i/TCsatCult).*(evcult*E_i+strcult*S_i);
PES_i = tanh(TC_i/TCsatProv).*(evprov*E_i+strprov*S_i);


% comparison of fronts for range of sites on 2 intervention schemes
count =1;
for k = 1:8:26
    figure(count)
    hold on
    title(sprintf('Site %2.0f',k), 'Interpreter','latex','Fontsize',12);
    plot(squeeze(CES_i(k,1,:)),squeeze(PES_i(k,1,:)),'*');
    plot(squeeze(CES_i(k,192,:)),squeeze(PES_i(k,192,:)),'*');
    legend('$Int 1$', '$Int 192$', 'Interpreter','latex','FontSize',10);
    xlabel('CES','Interpreter','latex','Fontsize',12)
    ylabel('PES','Interpreter','latex','Fontsize',12)
    count = count+1;
end


for k = 1:30:192
    figure(count)
    hold on
    title(sprintf('Seed1 %1.2f Seed2 %1.2f SRM %1.2f AsAdt %1.2f NatAdt %1.2f',Data(k+1,6:10)), 'Interpreter','latex','Fontsize',12);
    plot(squeeze(CES_i(1,k,:)),squeeze(PES_i(1,k,:)),'*')
    plot(squeeze(CES_i(26,k,:)),squeeze(PES_i(26,k,:)),'*')
    xlabel('CES','Interpreter','latex','Fontsize',12)
    ylabel('PES','Interpreter','latex','Fontsize',12)
    legend('$Site 1$', '$Site 26$', 'Interpreter','latex','FontSize',10);
    count = count+1;
end


hold on 
[x,y] = meshgrid(linspace(0,max(squeeze(CES_i(26,57,:))),10),linspace(0,max(squeeze(PES_i(26,57,:))),10));
plot(squeeze(CES_i(1,57,:)),squeeze(PES_i(1,57,:)),'*')
plot(squeeze(CES_i(26,57,:)),squeeze(PES_i(26,57,:)),'*')
xlabel('CES','Interpreter','latex','Fontsize',12)
ylabel('PES','Interpreter','latex','Fontsize',12)
% example utility isoclines representing 0.3 loss in CES due to 0.7
% increase in PES
quiver(x,y,0.9*tanh(x),0.1*y)
legend('$Site 1$', '$Site 26$', 'Interpreter','latex','FontSize',10);

%%
% plotting E againts S

% comparison of fronts for range of sites on 2 intervention schemes
count =1;
for k = 1:8:26
    figure(count)
    hold on
    title(sprintf('Site %2.0f',k), 'Interpreter','latex','Fontsize',12);
    plot(squeeze(E_i(k,1,:)),squeeze(S_i(k,1,:)),'*');
    plot(squeeze(E_i(k,192,:)),squeeze(S_i(k,192,:)),'*');
    xlabel('E','Interpreter','latex','Fontsize',12)
    ylabel('S','Interpreter','latex','Fontsize',12)
    legend('$Int 1$', '$Int 192$', 'Interpreter','latex','FontSize',10);
    count = count+1;
end


for k = 1:30:192
    figure(count)
    hold on
    title(sprintf('Seed1 %1.2f Seed2 %1.2f SRM %1.2f AsAdt %1.2f NatAdt %1.2f',Data(k+1,6:10)), 'Interpreter','latex','Fontsize',12);
    plot(squeeze(E_i(1,k,:)),squeeze(S_i(1,k,:)),'*')
    plot(squeeze(E_i(26,k,:)),squeeze(S_i(26,k,:)),'*')
    xlabel('E','Interpreter','latex','Fontsize',12)
    ylabel('S','Interpreter','latex','Fontsize',12)
    legend('$Site 1$', '$Site 26$', 'Interpreter','latex','FontSize',10);
    count = count+1;
end


hold on 
[x,y] = meshgrid(linspace(0,max(squeeze(E_i(26,57,:))),10),linspace(0,max(squeeze(S_i(26,57,:))),10));
plot(squeeze(E_i(1,57,:)),squeeze(S_i(1,57,:)),'*')
plot(squeeze(E_i(26,57,:)),squeeze(S_i(26,57,:)),'*')
xlabel('E','Interpreter','latex','Fontsize',12)
ylabel('S','Interpreter','latex','Fontsize',12)
% example utility isoclines representing 0.3 loss in CES due to 0.7
% increase in PES
quiver(x,y,0.9*tanh(x),0.1*y)
legend('$Site 1$', '$Site 26$', 'Interpreter','latex','FontSize',10);

%% optimisation?
A = [];
b = [];
Aeq = [];
beq = [];
lb = [0 0];
ub = [1 1];
ES = [];
CES = [];
PES = [];

for x = 0.00001:0.05:1

    % create objective with this level of TC and E and S as variables
    CESobj = @(zz) -1*funcCES(x,zz);
    z0 = rand(1,2);
    
    % solve for max CES
    [es,fval] = fmincon(CESobj,z0,A,b,Aeq,beq,lb,ub);
    % calculate corresponding PES
    pes = funcPES(x,es);
    PES = [PES;pes];
    ES = [ES;es];
    CES = [CES;-1*fval];
end


hold on 
plot(PES,CES,'*')
xlabel('PES','Interpreter','latex','Fontsize',12)
ylabel('CES','Interpreter','latex','Fontsize',12)

hold on
plot(ES(:,1),ES(:,2),'*')

xlabel('E','Interpreter','latex','Fontsize',12)
ylabel('S','Interpreter','latex','Fontsize',12)

