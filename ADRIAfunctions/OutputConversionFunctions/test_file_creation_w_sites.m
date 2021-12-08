filetype = 'mat';
rcps = [26,45,60];
algs = 1:3;
sites = 1:26;
col_names = {'Guided','PrSites','Seed1','Seed2','SRM','Aadpt','Natad','Seedyrs','Shadeyrs'};
metrics = {'TC','S','E'};
nsims = 50;
yr = 1:2:25;

BBN_data_table = BBNTableMCData(filetype,rcps,algs,col_names,nsims,yr,sites,metrics);

head(BBN_data_table)
