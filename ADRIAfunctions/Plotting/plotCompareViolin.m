function plotCompareViolin(int,cf,yr,tstep,metric ,names, varargin)
    % Plots a time series of violin plots comparing metrics for 2 scenarios
    % int and cf
    % INPUTS -
    %         int - intervention metric values (struct of N*P summary
    %               statistics matrices, where N is the no. of time steps 
    %               and P is the population no. (e.g. sites))
    %         cf - counterfactual or comparison metric structure (same
    %              format as int.)
    %         yr - vector of yrs (size P)
    %         tstep - positive integer indicating year intervals at which to plot.
    %         metric - string indicating sum. stat. to use: 'mean', 'median',
    %                   'std', 'min','max'.
    %         names - 3*1 cell of strings with {'metric name', '1st
    %                 scenario name', '2nd Scenario name'}, e.g. {'Coral
    %                 cover', 'Interv.','Counterf.'};
    %         varagin{1} - struct with 'intv'- a string indicating to plot
    %                       "seed", "shade" or "both"
    %                       'site_rankings' - N*P*2 matrix for one of the
    %                       interventions of interest, indicating the
    %                       seeding and shading ranks. 
    %         varargin{2} - 2*3 rgb matrix indicating colours for 2
    %                       scenarios
    %         varargin{3} - optional 1*2 array indicating upper and lower
    %                       limit of the y axis.
    %         varargin{4} - string "Legend" if a legend is desired.

    yr_vec = yr(1:tstep:end);

     if nargin >=7 && (~isempty(varargin{1}))
         intv = varargin{1}.int;

        site_rankings = varargin{1}.site_rankings;
        if isa(site_rankings, 'ndSparse')
            site_rankings = full(site_rankings);
        end

        nsites = size(site_rankings);
        nsites = nsites(2);
        site_rankings(site_rankings == 0) = nsites + 1;
        
        if strcmp(intv,"seed")
            seed_site_rankings = site_rankings(:,:,1);
            store_shade_seed = zeros(length(yr),5);

        elseif strcmp(intv,"shade")
            shade_site_rankings = site_rankings(:,:,2);
            store_shade_seed = zeros(length(yr),5);

        elseif strcmp(intv,"both")
            seed_site_rankings = site_rankings(:,:,1);
            shade_site_rankings = site_rankings(:,:,2);
            store_shade_seed = zeros(length(yr),10);
        end
        for yy = 3:length(yr)
            if strcmp(intv,"seed")
                seed_ranks = sortrows([(1:nsites)',seed_site_rankings(yy,:)'],2,'ascend');
                seed_ranks_sites = seed_ranks(:,1);
                
                ind_nsites = min(length(seed_ranks_sites),5);
                seed_ranks_sites = seed_ranks_sites(1:ind_nsites);
                shade_ranks_sites = [];
                
            elseif strcmp(intv,"shade")
                shade_ranks = sortrows([(1:size(site_rankings,2))',shade_site_rankings(yy,:)'],2,'ascend');
                shade_ranks_sites = shade_ranks(:,1);
                
                ind_nsites = min(length(shade_ranks_sites),5);
                shade_ranks_sites = shade_ranks_sites(1:ind_nsites);
                seed_ranks_sites = [];
                
            elseif strcmp(intv,"both")
                seed_ranks = sortrows([(1:nsites)',seed_site_rankings(yy,:)'],2,'ascend');
                seed_ranks_sites = seed_ranks(:,1);
                
                ind_nsites = min(length(seed_ranks_sites),5);
                seed_ranks_sites = seed_ranks_sites(1:ind_nsites);
                
                shade_ranks = sortrows([(1:size(site_rankings,2))',shade_site_rankings(yy,:)'],2,'ascend');
                shade_ranks_sites = shade_ranks(:,1);
                
                ind_nsites = min(length(shade_ranks_sites),5);
                shade_ranks_sites = shade_ranks_sites(1:ind_nsites);
                
            end
                
           store_shade_seed(yy,:)= [seed_ranks_sites;shade_ranks_sites];
        end
     end
     
     if nargin >= 8 && (~isempty(varargin{2}))
         cols = varargin{2};
         col1 = cols(1,:);
         col2 = cols(2,:);
     else
         col1 = [51/255,153/255,1];
         col2 = [204/255,0,0];
     end

    scatter(yr(1),int.(metric)(1,1),'MarkerFaceColor',col1,'MarkerEdgeColor',col1)
    scatter(yr(1),cf.(metric)(1,1),'MarkerFaceColor',col2,'MarkerEdgeColor',col2)

    if nargin>=7  && (~isempty(varargin{1}))
        ind = find(ismember(yr,yr_vec(2)));
        plot(yr(ind),int.(metric)(ind,store_shade_seed(ind,1)),'ko')
    end

    al_goodplot(int.(metric)(1:tstep:end,:)', yr_vec, 0.5, col1, 'left')
    al_goodplot(cf.(metric)(1:tstep:end,:)', yr_vec, 0.5, col2, 'right')

    if nargin >=7  && (~isempty(varargin{1}))
        for yy = 3:length(yr)
            if ismember(yr(yy),yr_vec)
                plot(repmat(yr(yy),1,length(store_shade_seed(yy,:))),int.(metric)(yy,store_shade_seed(yy,:)),'ko');
            end
        end
    end

    if nargin >=9  && (~isempty(varargin{3}))
        ylims = varargin{3};
    else
        maxy = max(max([int.(metric);cf.(metric)]));
        ylims = [0, maxy+0.0001*maxy];
    end

    xlim([yr(1),yr(end)])
    ylim(ylims)
    xlabel('Year','Fontsize',16,'Interpreter','latex')
    ylabel(names{1},'Fontsize',16,'Interpreter','latex')

    if nargin == 10 && strcmp(varargin{4},"Legend")
        if nargin >=7  && (~isempty(varargin{1}))
            ll = legend(names{2},names{3},'Interv. site')
        else
            ll = legend(names{2},names{3})
        end
        set(ll,'Fontsize',12,'Interpreter','latex');
    end
    
    set(gca,'FontSize',12);
end