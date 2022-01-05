function [ax1,ax2] = plotBBNProbMap(F0,botz,lat,lon,Fp)
% Plots a contour map of the reef of interest with labeled reef sites (as
% given in F0). Then plots the probabilities given in Fp on top as heat map
% dots with colour giving the probability magnitude

    % Create two axes
    ax1 = axes;
    [~,h] = contourf(ax1,lon,lat,botz);
    view(2)
    ax2 = axes;
    scatter(ax2,F0(:,3),F0(:,4),600,Fp','filled')
    % Link them together
    linkaxes([ax1,ax2])
    % Hide the top axes
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];

    % Set this value to any value within the range of levels.  
    binaryThreshold = 2.0; 
    
    % Determine where the binary threshold is within the current colormap
    crng = caxis(ax1);  % range of color values 
    clrmap = ax1.Colormap; 
    nColor = size(clrmap,1); 
    binThreshNorm = (binaryThreshold - crng(1)) / (crng(2) - crng(1));
    binThreshRow = round(nColor * binThreshNorm); % round() results in approximation
    
    % Change colormap to binary
    % White section first to label values less than threshold.
    newColormap = [ones(binThreshRow,3); zeros(nColor-binThreshRow, 3)]; 
    ax1.Colormap = newColormap; 

    colormap(ax2,'cool')
    % Then add colorbar for probabilities (hide contour colormap) and get everything lined up
    set([ax1,ax2],'Position',[.17 .11 .685 .815]);
    cb1 = colorbar(ax1);
    colorbar(cb1,'hide');
    cb2 = colorbar(ax2,'Position',[.88 .11 .0675 .815]);
    ax1.FontSize = 16;
    ax2.FontSize = 16;
    set(ax1,'XLim',[min(min(lon)) max(max(lon))],...
        'YLim',[min(min(lat)) max(max(lat))])
    
    % plot site locations
    text(ax2,F0(:,3),F0(:,4), cellstr(num2str(F0(:,1))), 'FontSize', 18, 'Color', 'k');
    ylabel(cb2,'$P(Coral Cover \geq 0.7)$','FontSize',16,'Interpreter','latex');
end

