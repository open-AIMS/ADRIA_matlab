function plotMeanRankings(rankings, opts)
    arguments
        rankings double
        opts.p_title string = ""
    end
    figure;
    
    barh(1:length(rankings), rankings);
    
    if strlength(opts.p_title) > 0
        title(opts.p_title);
    end
    
    xlabel("Rank");
    ylabel("Site ID");
    set(gca, 'YDir','reverse');
    
end