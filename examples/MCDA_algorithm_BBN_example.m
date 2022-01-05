[n,m,k] = size(alg_cont_TC);

alg1_TC = alg_cont_TC(:,1,:);
alg2_TC = alg_cont_TC(:,2,:);
alg3_TC = alg_cont_TC(:,3,:);

BBN_dat_cont = [];
% parameter combos 2,6 and 5 seem to favour Alg2 or 3 whereas the other
% combos are similar for each algorithm

% maybe do mc runs, create these plots and save parameter combos where the
% correlation between algorithm and TC >0 and not small (above a thresh
% hold)
for t = 1:25
    BBN_dat_cont = [BBN_dat_cont; repmat(t,3,1), [ones(1,1);2*ones(1,1);3*ones(1,1)], [alg1_TC(t,4)';alg2_TC(t,4)';alg3_TC(t,4)']];
end

names = {'Years','Algorithm','TC'};

parent_cell = cell(1, 3);
for i = 1:2
    parent_cell{i} = [];
end
parent_cell{3} = 1:2;

R = bn_rankcorr(parent_cell, BBN_dat_cont, 1, 1, names);

figure(2);

bn_visualize(parent_cell, R, names, gca);

% make the same inference but now with incrementally increasing years and
% retrieve the full distribution
F1 = cell(1, 7);
F2 = cell(1, 7);
F3 = cell(1, 7);
x = linspace(0,1,50);
for l = 1:4:25
    figure
    hold on
    F1 = inference(1:2, [l,1], R, BBN_dat_cont, 'full', 1000, 'near');
    F2 = inference(1:2, [l,2], R, BBN_dat_cont, 'full', 1000, 'near');
    F3 = inference(1:2, [l,3], R, BBN_dat_cont, 'full', 1000, 'near');
    % plot the coral cover distribution as a histogram
%     h1 = histogram(F1{1}, 'NumBins', 30, 'Normalization', 'probability');
%     h2 = histogram(F2{1}, 'NumBins', 30, 'Normalization', 'probability');
%     h3 = histogram(F3{1}, 'NumBins', 30, 'Normalization', 'probability');
    pd1 = fitdist(F1{1},'kernel','Kernel','normal');
    y1 = pdf(pd1,x);
    pd2 = fitdist(F2{1},'kernel','Kernel','normal');
    y2 = pdf(pd2,x);
    pd3 = fitdist(F3{1},'kernel','Kernel','normal');
    y3 = pdf(pd3,x);
    plot(x,y1,x,y2,x,y3)
    legend('Alg1', 'Alg2','Alg3');
    title(sprintf('Year %2.0f',l));
    hold off
end
