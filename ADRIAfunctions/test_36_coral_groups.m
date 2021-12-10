%Data for 40 group ODE test

Xn = [2000,0,0,0,0,0;     %Tabular Acropora Enhanced
      2000,0,0,0,0,0;       %Corymbose Acropora Enhanced
      2000,0,0,0,0,0;       %Tabular Acropora Unenhanced
      2000,0,0,0,0,0;       %Corymbose Acropora Unenhanced
      2000,200,20,0,0,0;       %small massives
      2000,50,10,20,0,0];      %large massives

rcm = [1, 1, 2, 4.4, 4.4, 4.4;   %Tabular Acropora Enhanced
       1, 1, 3, 3, 3, 3;         %Corymbose Acropora Enhanced
       1, 1, 2, 4.4, 4.4, 4.4;   %Tabular Acropora Unenhanced
       1, 1, 3, 3, 3, 3;         %Corymbose Acropora Unenhanced
       1, 1, 1, 1, 0.8, 0.8;     %small massives
      1, 1, 1, 1, 1.2, 1.2];     %large massives
    
  
mb = [0.2, 0.19, 0.10, 0.05, 0.03, 0.03;   %Tabular Acropora Enhanced
      0.2, 0.20, 0.17, 0.05, 0.03, 0.03;     %Corymbose Acropora Enhanced
      0.2, 0.19, 0.10, 0.10, 0.05, 0.05;     %Tabular Acropora Unenhanced
      0.2, 0.20, 0.17, 0.10, 0.05, 0.05;     %Corymbose Acropora Unenhanced
      0.2, 0.20, 0.04, 0.04, 0.02, 0.02;   %small massives
      0.2, 0.20, 0.04, 0.04, 0.02, 0.02];   %large massives

diam_means =  repmat([1, 3.5, 7.5, 15, 30, 60],[size(Xn,1),1]);
area_means = pi.*(diam_means./2).^2;
diam_bin_widths = repmat([2, 3, 5, 10, 20, 40],[size(Xn,1),1]);
area_bin_widths = pi.*(diam_means./2).^2;
prop_change = rcm./diam_bin_widths;
prop_stay = 1-rcm./diam_bin_widths;

a_arena = 100;  %size of reef cell in m2

rec = [0.02, 0.02, 0.02, 0.02, 0.01, 0.01];

Xn = reshape(Xn',numel(Xn),1);
rcm = reshape(rcm',numel(Xn),1);
mb = reshape(mb',numel(Xn),1);
diam_means = reshape(diam_means',numel(Xn),1);
area_means = reshape(area_means',numel(Xn),1);
diam_bin_widths = reshape(diam_bin_widths',numel(Xn),1);
prop_change = reshape(prop_change',numel(Xn),1);

X = Xn.*area_means./a_arena/(10^4);
r = Xn.*prop_change.*area_means./a_arena/(10^4);
r = r';
P = 1;

tf = 300;
M = zeros(numel(Xn),tf); 
for t = 1:tf 
    M(:,t) = ADRIA_36CoralGroups(X, r, P, mb,rec);
    X = M(:,t);
end
figure;
plot(M');
sum(M(:,tf))

