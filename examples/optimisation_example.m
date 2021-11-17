%% Example for 2 simple usages of the optimisation function ADRIAOptimisation
%% 1 : only optimise for average total coral cover av_TC

% use simplest MDCA algorithm for now
alg = 1;

% use all sites (C)
prsites = 3; 

% optimisation specification - want to optimise over TC only
opti_ind = [1,0,0,0,0];

% declare filename appendage to tag as example
file_ap = 'Example1obj';

% perform optimisation (takes a while, be warned, improvements to
% efficiency to be made)
[x,fval] = ADRIAOptimisation(alg,opti_ind,prsites,rcp,file_ap);

% print results (also automatically saved to a struct in a .mat file) 
sprintf('Optimal intervention values were found to be Seed1: %1.4f, Seed2: %1.4f, SRM: %2.0f, AsAdt: %2.0f, NatAdt: %1.2f, with av_TC = %1.4f',...
    x(1),x(2),x(3),x(4),x(5),fval);

%% 2 : optimise for average total coral cover av_TC and scope for cultural ecosystem services av_CES

% use simplest MDCA algorithm for now
alg = 1;

% use all sites (C)
prsites = 3; 

% optimisation specification - want to optimise over TC and CES now
opti_ind = [1,0,0,1,0];

% declare filename appendage to tag as example
file_ap = 'Example2obj';

% perform optimisation (takes a while, be warned, improvements to
% efficiency to be made)
[x,fval] = ADRIAOptimisation(alg,opti_ind,prsites,rcp,file_ap);

% print results (also automatically saved to a struct in a .mat file) 
sprintf('Optimal intervention values were found to be Seed1: %1.4f, Seed2: %1.4f, SRM: %2.0f, AsAdt: %2.0f, NatAdt: %1.2f, with av_TC = %1.4f, av_CES = %1.4f',...
    x(1),x(2),x(3),x(4),x(5),fval(1),fval(2));