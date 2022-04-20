
rng(101) % set seed for reproducibility

%% 1. initialize ADRIA interface

ai = ADRIA();

%% 2. Build a parameter table using default values

param_table = ai.raw_defaults;
% param_table.Guided = 1;
% param_table.Seed1 = 500000;
% param_table.Seed2 = 500000;
% param_table.Aadpt =4;
% param_table.Seedfreq = 0;

%% Run ADRIA

n_reps = 50;

% Run all years
ai.constants.tf = 74;
tf = ai.constants.tf;
% Load site specific data
ai.loadSiteData('./Inputs/Brick/site_data/Brick_2015_637_reftable.csv');
ai.loadConnectivity('Inputs/Brick/connectivity/2015/');
ai.loadCoralCovers("./Inputs/Brick/site_data/coralCoverBrickTruncated.mat");
ai.loadDHWData('./Inputs/Brick/DHWs/dhwRCP45.mat', n_reps);

opts = struct('reltol',1e-3,'abstol',1e-6);
%% with ode45
odestr = @ode45;
tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr,odeopts=opts);
Y45 = res.Y;  % get raw results
tmp = toc;

N = size(Y45, 4);
disp(strcat("Ode45 took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))

%% with ode23
odestr = @ode23;
tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr,odeopts=opts);
Y23 = res.Y;  % get raw results
tmp = toc;

N = size(Y23, 4);
disp(strcat("Ode23 took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))

%% with ode78
odestr = @ode78;
tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr,odeopts=opts);
Y78 = res.Y;  % get raw results
tmp = toc;

N = size(Y78, 4);
disp(strcat("Ode78 took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))

%% with ode89
odestr = @ode89;
tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr,odeopts=opts);
Y89 = res.Y;  % get raw results
tmp = toc;

N = size(Y89, 4);
disp(strcat("Ode89 took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))

%% with stiff solver ode23s
% odestr = "ode23s";
% tic
% % Run a single simulation with `n_reps` replicates
% res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr);
% Y23t = res.Y;  % get raw results
% tmp = toc;
% 
% N = size(Y23t, 4);
% disp(strcat("With ",odestr, ". Took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))
%% with variable order method ode113
odestr = @ode113;
tic
% Run a single simulation with `n_reps` replicates
res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr,odeopts=opts);
Y113 = res.Y;  % get raw results
tmp = toc;

N = size(Y113, 4);
disp(strcat("Ode113 took ", num2str(tmp), " seconds to run ", num2str(N*n_reps), " simulations (", num2str(tmp/(N*n_reps)), " seconds per run)"))
%% plot difference to ode45
diff23 = sqrt(sum(sum(sum(sum((Y45-Y23).^2,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan'));
diff113 = sqrt(sum(sum(sum(sum((Y45-Y113).^2,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan'));
diff78 = sqrt(sum(sum(sum(sum((Y45-Y78).^2,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan'));
diff89 = sqrt(sum(sum(sum(sum((Y45-Y89).^2,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan'));

mean23 = mean(mean(mean(mean(Y23,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan');
mean45 = mean(mean(mean(mean(Y45,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan');
mean113 = mean(mean(mean(mean(Y113,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan');
mean78 = mean(mean(mean(mean(Y78,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan');
mean89 = mean(mean(mean(mean(Y89,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan');

nperm = 1009800;
dist23 = zeros(tf,nperm);
dist45 = zeros(tf,nperm);
dist78 = zeros(tf,nperm);
dist113 = zeros(tf,nperm);
dist89 = zeros(tf,nperm);
for kk = 1:tf
    dist23(kk,:) = reshape(Y23(kk,:,:,:,:),1,nperm);
    dist45(kk,:)  = reshape(Y45(kk,:,:,:,:),1,nperm);
    dist113(kk,:)  = reshape(Y113(kk,:,:,:,:),1,nperm);
    dist78(kk,:)  = reshape(Y78(kk,:,:,:,:),1,nperm);
    dist89(kk,:)  = reshape(Y89(kk,:,:,:,:),1,nperm);
end
dist23(isnan(dist23)) = 0;
dist45(isnan(dist45)) = 0;
dist113(isnan(dist113)) = 0;
dist78(isnan(dist78)) = 0;
dist89(isnan(dist89)) = 0;
years = 2025+(1:tf);

figure(1)
subplot(1,3,1)
plot(years',diff23,years',diff113,years',diff78,years',diff89)
legend('ode23','ode113','ode78','ode89')
xlabel('Year')
ylabel('Mean difference in coral cover to ode45')
subplot(1,3,2)
plot(years',mean45,years',mean23,years',mean113,years',mean78,years',mean89)
legend('ode45','ode23','ode113','ode78','ode89')
xlabel('Year')
ylabel('Mean coral cover')
subplot(1,3,3)
cols = parula(5);
hold on 
plot_distribution_prctile(years',dist45','Color',cols(1,:))
plot_distribution_prctile(years',dist23','Color',cols(2,:))
plot_distribution_prctile(years',dist113','Color',cols(3,:))
plot_distribution_prctile(years',dist78','Color',cols(4,:))
plot_distribution_prctile(years',dist89','Color',cols(5,:))
legend('ode45','ode23','ode113','ode78','ode89')
xlabel('Year')
ylabel('Mean coral cover')

%% test absolute and relative error tolerances
abs_tols = [1e-7,1e-6,1e-5,1e-4];
rel_tols = [1e-4,1e-3,1e-2,0.1];
y45_times = zeros(1,length(abs_tols));
y23_times = zeros(1,length(abs_tols));
diffstore = zeros(length(abs_tols),tf);
mean45store = diffstore;
mean23store = diffstore;
%%
for tt = 1:length(abs_tols)
    opts = struct('reltol',rel_tols(tt),'abstol',abs_tols(tt))
    % with ode45
    tic
    % Run a single simulation with `n_reps` replicates
    res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc = @ode45,odeopts =opts);
    Y45 = res.Y;  % get raw results
    tmp = toc;    
    N = size(Y45, 4);
    y45_times(tt) = tmp/(N*n_reps);
    % with ode23
    odestr = @ode23;
    tic
    % Run a single simulation with `n_reps` replicates
    res = ai.run(param_table, sampled_values=false, nreps=n_reps,odefunc=odestr,odeopts=opts);
    Y23 = res.Y;  % get raw results
    tmp = toc;
    
    N = size(Y23, 4);
    y23_times(tt) = tmp/(N*n_reps);
    
    % store means and differences
    diff23 = sqrt(sum(sum(sum(sum((Y45-Y23).^2,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan'));
    diffstore(tt,:) = diff23;
    mean23 = mean(mean(mean(mean(Y23,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan');
    mean45 = mean(mean(mean(mean(Y45,2,'omitnan'),3,'omitnan'),4,'omitnan'),5,'omitnan');
    mean45store(tt,:) = mean45;
    mean23store(tt,:) = mean23;
end
%%
figure(2)
subplot(1,3,1)
hold on
for ll = 1:length(abs_tols)
    plot(years',diffstore(ll,:))
end
xlabel('Year')
ylabel('Mean difference in coral cover to ode45')
legend('1e-7','1e-6','1e-5','1e-4');
subplot(1,3,2)
hold on
for ll = 1:length(abs_tols)
    plot(years',mean45store(ll,:),'-')
    plot(years',mean23store(ll,:),'--')
end
legend('ode45 1e-7','ode23 1e-7','ode45 1e-6', ...
    'ode23 1e-6','ode45 1e-5','ode23 1e-5',...
    'ode45 1e-4','ode23 1e-4');
xlabel('Year')
ylabel('Mean coral cover')

subplot(1,3,3)
hold on
plot(-log(abs_tols),y45_times,-log(abs_tols),y23_times)
legend('ode45','ode23')
xticklabels({'-log(1e-7)','-log(1e-6)','-log(1e-5)','-log(1e-4)'})
xlabel('-log(Abs Tol)')
ylabel('Time for one simulation (s)')