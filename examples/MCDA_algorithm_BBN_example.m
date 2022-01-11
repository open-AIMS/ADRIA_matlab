[n,m,k] = size(alg_cont_TC);

alg1_TC = squeeze(alg_cont_TC(:,1,:));
alg2_TC = squeeze(alg_cont_TC(:,2,:));
alg3_TC = squeeze(alg_cont_TC(:,3,:));
alg4_TC = squeeze(alg_cont_TC(:,4,:));

BBN_dat_cont = [];
% parameter combos 2,6 and 5 seem to favour Alg2 or 3 whereas the other
% combos are similar for each algorithm

% maybe do mc runs, create these plots and save parameter combos where the
% correlation between algorithm and TC >0 and not small (above a thresh
% hold)
for t = 1:25
    for k = 1:8
        BBN_dat_cont = [BBN_dat_cont; repmat(t,4,1),[ones(1,1);2*ones(1,1);3*ones(1,1);4*ones(1,1)], ...
                        repmat([IT.Seed1(k), IT.Seed2(k), IT.SRM(k), IT.Aadpt(k),IT.Natad(k),IT.Seedyrs(k),IT.Shadeyrs(k)],4,1),...
                        [alg1_TC(t,k);alg2_TC(t,k);alg3_TC(t,k);alg4_TC(t,k)]];
    end
end


names = {'Years','Algorithm','Seed1','Seed2','SRM','Aadpt','Natad','Seyrs','Shyrs','TC'};
nnodes = 10;
parent_cell = cell(1, nnodes);
for i = 1:nnodes-1
    parent_cell{i} = [];
end
parent_cell{nnodes} = 1:nnodes-1;

R = bn_rankcorr(parent_cell, BBN_dat_cont, 1, 1, names);

figure(2);

bn_visualize(parent_cell, R, names, gca);

% make the same inference but now with incrementally increasing years and
% retrieve the full distribution
F1 = cell(1, 7);
F2 = cell(1, 7);
F3 = cell(1, 7);
F4 = cell(1, 7);

x = linspace(0,1,50);
for l = 1:4:25
    figure
    hold on
    F1 = inference(1:4, [l 1,0.0008,0.5], R, BBN_dat_cont, 'full', 1000, 'near');
    F2 = inference(1:4, [l 2,0.0008,0.5], R, BBN_dat_cont, 'full', 1000, 'near');
    F3 = inference(1:4, [l 3,0.0008,0.5], R, BBN_dat_cont, 'full', 1000, 'near');
    F4 = inference(1:4, [l 4,0.0008,0.5], R, BBN_dat_cont, 'full', 1000, 'near');
    % plot the coral cover distribution as a histogram
    h1 = histogram(F1{6}, 'NumBins', 30, 'Normalization', 'probability');
    h2 = histogram(F2{6}, 'NumBins', 30, 'Normalization', 'probability');
    h3 = histogram(F3{6}, 'NumBins', 30, 'Normalization', 'probability');
    h4 = histogram(F4{6}, 'NumBins', 30, 'Normalization', 'probability');
%     pd1 = fitdist(F1{7},'kernel','Kernel','normal');
%     y1 = pdf(pd1,x);
%     pd2 = fitdist(F2{7},'kernel','Kernel','normal');
%     y2 = pdf(pd2,x);
%     pd3 = fitdist(F3{7},'kernel','Kernel','normal');
%     y3 = pdf(pd3,x);
%     pd4 = fitdist(F4{7},'kernel','Kernel','normal');
%     y4 = pdf(pd4,x);
   % plot(x,y1,x,y2,x,y3,x,y4)
    legend('Alg1', 'Alg2','Alg3','Alg4');
    title(sprintf('Year %2.0f',l));
    hold off
end
