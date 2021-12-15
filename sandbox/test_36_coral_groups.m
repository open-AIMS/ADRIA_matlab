%Data for 40 group ODE test


Xn = [500,50,20,10,5,0;     %Tabular Acropora Enhanced
      500,50,20,10,5,0;       %Tabular Acropora Unenhanced
      1000,20,20,10,5,0;       %Corymbose Acropora Enhanced
      1000,20,20,10,5,0;       %Corymbose Acropora Unenhanced
      200,50,10,0,0,0;       %small massives
      100,10,10,0,0,10];      %large massives

rcm = [1, 1, 2, 4.4, 4.4, 4.4;   %Tabular Acropora Enhanced
       1, 1, 2, 4.4, 4.4, 4.4;   %Tabular Acropora Unenhanced
       1, 1, 3, 3, 3, 3;         %Corymbose Acropora Enhanced
       1, 1, 3, 3, 3, 3;         %Corymbose Acropora Unenhanced
       1, 1, 1, 1, 0.8, 0.8;     %small massives
      1, 1, 1, 1, 1.2, 1.2];     %large massives
    
  
mb = [0.2, 0.15, 0.05, 0.02, 0.02, 0.02;     %Tabular Acropora Enhanced
      0.2, 0.19, 0.10, 0.03, 0.03, 0.03;     %Tabular Acropora Unenhanced
      0.2, 0.15, 0.15, 0.02, 0.02, 0.02;     %Corymbose Acropora Enhanced
      0.2, 0.20, 0.17, 0.03, 0.03, 0.03;     %Corymbose Acropora Unenhanced
      0.2, 0.20, 0.04, 0.04, 0.04, 0.04;     %small massives
      0.2, 0.20, 0.04, 0.04, 0.04, 0.04];    %large massives

colony_diam_edges = repmat([2, 5, 10, 20, 40, 80], size(Xn,1),1);
colony_area_edges = pi.*(colony_diam_edges./2).^2;
colony_diam_means =  repmat([1, 3.5, 7.5, 15, 30, 60],size(Xn,1),1);
colony_area_means = pi.*(colony_diam_means./2).^2;
diam_bin_widths = repmat([2, 3, 5, 10, 20, 40],[size(Xn,1),1]);
prop_change = rcm./diam_bin_widths;
prop_stay = 1-rcm./diam_bin_widths;

a_arena = 100;  %size of reef cell in m2

rec = [0.00, 0.01, 0.00, 0.01, 0.01, 0.01];
comp = 0.8; %probability that large tabular Acropora overtop small massives


Xn = reshape(Xn',numel(Xn),1);
rcm = reshape(rcm',numel(Xn),1);
mb = reshape(mb',numel(Xn),1);
colony_diam_means = reshape(colony_diam_means',numel(Xn),1);
colony_area_means = reshape(colony_area_means',numel(Xn),1);
colony_diam_edges = reshape(colony_diam_edges',numel(Xn),1);
colony_area_edges = reshape(colony_area_edges',numel(Xn),1);
diam_bin_widths = reshape(diam_bin_widths',numel(Xn),1);
prop_change = reshape(prop_change',numel(Xn),1);

X = Xn.*colony_area_edges./a_arena/(10^4);
r = Xn.*prop_change.*colony_area_edges./a_arena/(10^4);
r = r';
P = 0.8;

tf = 50;
M = zeros(numel(Xn),tf); 
for t = 1:tf 
    M(:,t) = ADRIA_36CoralGroups(X, r, P, mb, rec, comp);
    X = M(:,t);
end
figure;

plot(M')
legend
figure

SP(1,:) = sum(M(1:6,:));
SP(2,:) = sum(M(7:12,:));
SP(3,:) = sum(M(13:18,:));
SP(4,:) = sum(M(19:24,:));
SP(5,:) = sum(M(25:30,:));
SP(6,:) = sum(M(31:36,:));

A1 = plot(SP(1,:)');
A1.LineWidth = 3;
A1.Color = 'b';
A1.LineStyle = '- .';
hold on
A2 = plot(SP(2,:)');
A2.LineWidth = 3;
A2.Color = 'b';
A2.LineStyle = '-';
hold on
A3 = plot(SP(3,:)');
A3.LineWidth = 3;
A3.Color = 'r';
A3.LineStyle = '- .';
hold on
A4 = plot(SP(4,:)');
A4.LineWidth = 3;
A4.Color = 'r';
A4.LineStyle = '-';
hold on
A5 = plot(SP(5,:)');
A5.LineWidth = 3;
A5.Color = 'g';
hold on
A6 = plot(SP(6,:)');
A6.LineWidth = 3;
A6.Color = 'm';


legend
sum(SP(:,tf))

