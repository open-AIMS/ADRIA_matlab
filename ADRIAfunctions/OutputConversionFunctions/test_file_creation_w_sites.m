% filetype of saved raw data
filetype = 'mat';
% rcps to include
rcps = [26,45,60];
% algorithms to include
algs = 1:3;
% sites to include
sites = 1:26;
% intervention variables to include
col_names = {'Guided','PrSites','Seed1','Seed2','SRM','Aadpt','Natad','Seedyrs','Shadeyrs'};
% output metrics to include
metrics = {'TC','S','E'};
% number of simulations
nsims = 50;
% first year, yr increment and last year to use
yr = [1,2,25];

% create data table
Data = BBNTableMCData(filetype,rcps,algs,col_names,nsims,yr,sites,metrics);

% check header
head(Data)

% declare nodes in BBN
Names = {'RCP'; 'Alg';'Years';'Sites';'Guided'; 'PrSites';'Seed1'; 'Seed2'; 'SRM'; 'AssAdt'; 'NatAdt'; 'Seedyrs';'Shadeyrs';...
    'CC';'S';'E'};


% construct ParentCell, a cell structure of size 1*(no. of nodes)
% each cell contains the parents of the node corresponding the the cell no.
ParentCell = cell(1,16);
for i = 1:13
    ParentCell{i} = [];
end
ParentCell{14} = 1:13;
ParentCell{15} = 1:13;
ParentCell{16} = 1:13;

Data = table2array(Data);

R = bn_rankcorr(ParentCell, Data, 1, 0, Names);

bn_visualize(ParentCell,R,Names,gca);

% example - what is the mean coral cover, E and S on site 26 for an RCP of 4.5,
% at year 10, with guided interventions, using all sites (Prsites = 3 ) and
% only seed1 and seed2 = 0.0005,seedyrs 12 and shadeyrs 3

% note that when performing inferences in this larger network, not enough
% degrees of freedom (e.g. setting too many variables as known) can result
% in Nans. It seems at least 5 variables need to be unknown to allow
% calculation.

% nodes we know
inf_cells = 1:13;
% their values
vals = [26,3,10,26,1,3,0.0009,0.0009,0,0,0,12,3];
outcome1 = inference(inf_cells,vals,R,Data,'mean',1000,'near');