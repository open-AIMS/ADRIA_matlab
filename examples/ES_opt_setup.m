%% Optimisation for plotting efficiency frontiers
%% average coral cover vs. average shelter volume
ai = ADRIA();
param_table = ai.raw_defaults;
[~,criteria,coral_parms] = ai.splitParameterTable(param_table);
n_reps = 20;
%% Modify table as desired...
param_table.Seed1 = 9000;
param_table.Seed2 = 5000;
param_table.SRM = 2;
param_table.Seedfreq = 5;
param_table.Shadefreq = 5;
nsiteint = 5;

%%Connectivity and site data
ai.loadConnectivity('Inputs/Moore/connectivity/2015/');
ai.loadSiteData('./Inputs/Moore/site_data/MooreReefCluster_Spatial_w4.5covers.csv', ["Acropora2026", "Goniastrea2026"]);

max_depth = criteria.depth_min + criteria.depth_offset;
depth_criteria = (site_data.sitedepth > -max_depth) & (site_data.sitedepth < -criteria.depth_min);
depth_priority = site_data{depth_criteria, "recom_connectivity"};

lb = zeros(1,2*length(depth_priority));
ub = ones(1,2*length(depth_priority));
Aeq = [ones(1,length(depth_priority)) zeros(1,length(depth_priority));
    zeros(1,length(depth_priority)) ones(1,length(depth_priority))];
beq = [nsiteint;nsiteint];
A = [];
b = [];
gam = 0:0.1:1;
storeseeding = zeros(length(gam),nsiteint);
storeshading = zeros(length(gam),nsiteint);
for g = 1:length(gam)
    ppfobj = @(x) PPFObjectiveFunc(x,gam(g),ai,param_table,coral_parms,n_reps);
    [x,fval] = ga(ppfobj,2*length(depth_priority),A,b,Aeq,beq,lb,ub,[],1:2*length(depth_priority));
    storeseeding(g,:) = depth_priority(x(1:length(depth_priority)));
    storeshading(g,:) = depth_priority(x(length(depth_priority)+1:end));
end