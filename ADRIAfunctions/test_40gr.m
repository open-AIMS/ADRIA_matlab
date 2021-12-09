%Data for 40 group ODE test

Xn = [1000,100,0,0,0,0;     %Tabular Acropora
    1000,100,0,0,0,0;       %Corymbose Acropora
    1000,0,0,0,0,0;       %small massives
    1000,0,0,0,0,0];      %large massives

rcm = [1, 1, 2, 4.4, 4.4, 4.4;   %Tabular Acropora
       1, 1, 3, 3, 3, 3;       %Corymbose Acropora
       1, 1, 1, 1, 0.8, 0.8;   %small massives
      1, 1, 1, 1, 1.2, 1.2];   %large massives
  
mb = [0.2, 0.19, 0.1, 0.1, 0.05, 0.05;   %Tabular Acropora
    0.2, 0.2, 0.17, 0.1, 0.05, 0.05; %Corymbose Acropora
     0.2, 0.2, 0.04, 0.04, 0.02, 0.02;  %small massives
    0.2, 0.2, 0.04, 0.04, 0.02, 0.02];  %large massives

diam_means =  repmat([1, 3.5, 7.5, 15, 30, 60],[4,1]);
area_means = pi.*(diam_means./2).^2;
diam_bin_widths = repmat([2, 3, 5, 10, 20, 40],[4,1]);
area_bin_widths = pi.*(diam_means./2).^2;
prop_change = rcm./diam_bin_widths;
prop_stay = 1-rcm./diam_bin_widths;

a_arena = 100;  %size of reef cell in m2

rec = [0.05, 0.05, 0.02, 0.02];

Xn = reshape(Xn',24,1);
rcm = reshape(rcm',24,1);
mb = reshape(mb',24,1);
diam_means = reshape(diam_means',24,1);
area_means = reshape(area_means',24,1);
diam_bin_widths = reshape(diam_bin_widths',24,1);
prop_change = reshape(prop_change',24,1);

X = Xn.*area_means./a_arena/(10^4);
r = Xn.*prop_change.*area_means./a_arena/(10^4);
r = r';
P = 1;

M = zeros(24,20); 
for t = 1:40; 
    M(:,t) = ADRIA_prep40CoralGroups(X, r, P, mb,rec);
    X = M(:,t);
end
figure;
plot(M');
sum(M(:,20))

