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
Names = {'RCP'; 'Alg';'Years';'Guided'; 'PrSites';'Seed1'; 'Seed2'; 'SRM'; 'AssAdt'; 'NatAdt'; 'Seedyrs';'Shadeyrs';...
    'CC';'S';'E'};


% construct ParentCell, a cell structure of size 1*(no. of nodes)
% each cell contains the parents of the node corresponding the the cell no.
ParentCell = cell(1,15);
for i = 1:12
    ParentCell{i} = [];
end
ParentCell{13} = 1:12;
ParentCell{14} = 1:12;
ParentCell{15} = 1:12;

Data = table2array(Data);

R = bn_rankcorr(ParentCell, Data, 1, 0, Names);

bn_visualize(ParentCell,R,Names,gca);