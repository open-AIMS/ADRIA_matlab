function BBN_data_table = BBNTableMCData(filetype,rcps,algs,var_names,nsims,yr,sites,metrics)
% Function to convert MC data generated from ADRIA into a BBN compatible
% table
% Inputs : 
%         filetype : 'mat' or 'nc', designating a mat file or netcdf file
%                     to be loaded from the Outputs folder
%                     (form of the data saved from ADRIA runs)
%         rcps : array of rcps to load data from
%         algs : array of alg_inds to load data from
%         var_names : cell of variable names for table (intervention
%                       variables)
%         nsims : number of simulations used in data
%         yr : 1 by 3 array with ['start year', 'increment','end year'] as
%              integers
%         sites : 1 by M array containing the site numbers included in the
%               data sets (indexes sites you want to include out of total
%               set of sites)
%
% Outputs :
%          BBN_data_table : table of BBN compatible data with nodes as 
%                           named columns
% 

    % no. of intervention variables
    nvars = length(var_names);
    % vector of the yr increments used 
    yrs = yr(1):yr(2):yr(3);
    % no. of years
    nyrs = length(yrs);
    % no. of sites
    nsites = length(sites);
    % number of output metrics captured in the ADRIA data
    nmetrics = length(metrics);
    data_container_total = [];
    % check filetype
    if strcmp(filetype,'mat')
        % iterate through algorithms and rcps
        for l = 1:length(algs)
            for k = 1:length(rcps)
                filename = strcat('Outputs/Results_RCP',num2str(rcps(k)),'_Alg',num2str(algs(l)),'.mat');
                % check if file exists and if so, load
                if isfile(filename)
                    data = load(filename);
                    dfields = fields(data);
                    nvarperms = size(data.(dfields{1}),1);
                    % total number of variable permutations
                    Nperm = nyrs*nsites*nsims*nvarperms;
                    % number of repetitions for yrs vector
                    Nyrs = Nperm/nyrs;
                    % number of repetitions for sites vector
                    Nsites = Nyrs/nsites;
                    % create data container to store outputs
                    data_container = zeros(Nperm,nvars+4+nmetrics);
                    
                    % first 4 columns with rcp, alg, yrs and sites
                    data_container(:,1) = repmat(rcps(k),Nperm,1);
                    data_container(:,2) = repmat(algs(l),Nperm,1);
                    data_container(:,3) = reshape(repmat(yrs,Nyrs,1),Nperm,Nperm/(Nyrs*nyrs));
                    data_container(:,4) = reshape(repmat(sites,Nsites,Nperm/(Nsites*nsites)),Nperm,1);
                    
                    temp_mat = [];
                    % next fill variable permulation table
                    for ll = 1:nvarperms
                        temp_mat = [temp_mat;repmat(data.(dfields{1})(ll,:),nsims,1)];
                    end
                    data_container(:,5:5+nvars-1) = repmat(temp_mat,nyrs*nsites,1);
                    
                    % next fill in metrics columns
                    % create temporary container to filter time increments
                    data_metrics = data.(dfields{2});
                    for mm = 1:nmetrics
                        % select out specified sites and years
                        temp_cont = zeros(Nperm,1);
                        temp_mat = data_metrics.(metrics{mm})(1:yr(2):end,sites,:,1:nsims);
                        count = 1;
                        for nn = 1:length(yrs)
                            for hh = sites
                                for gg = 1:nvarperms
                                    for jj = 1:nsims
                                        temp_cont(count) = temp_mat(nn,hh,gg,jj);
                                        count = count+1;
                                    end
                                end
                            end
                        end
                        data_container(:,mm+4+nvars) = temp_cont;
                    end
                    data_container_total = [data_container_total;data_container];
                end
            end
        end
    elseif strcmp(filetype,'nc')
    else
        warning('File type not compatible.')
        BBN_data_table = [];
        return
    end
    if isempty(data_container_total)
        BBN_data_table = [];
    else
        names = cat(2,var_names,metrics);
        names = cat(2,{'RCP','Alg','Yrs','Sites'},names);

        BBN_data_table = array2table(data_container_total,'VariableNames',names);
    end
end

