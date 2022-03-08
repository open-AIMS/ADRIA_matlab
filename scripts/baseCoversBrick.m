%% Generate initial covers for Brick

%extractInitialCCBrick;

%Load Rose's TC data for Brick based on ReefMod counterfactuals
F = load('coralCoverBrickData_OLD');
mcover = squeeze(mean(F.TC, 1)); % average over replicates (sims)

%Extract cover for year 2026 
cover2026 = squeeze(mcover(:,20,:)); 

%% Initialise covers

nsites = size(cover2026, 1);
covers = zeros(nsites, 36);

for n = 1:nsites
    for sp = 1:36
   target_covers = cover2026(n, :);
   base_cover =  baseCoralNumbersFromCoversAllTaxaReefMod(target_covers);
   base_cover = reshape(base_cover', [], 1); %reshape to column vecor
   basecover = base_cover'; %flip to row vector
   covers(n,sp) = base_cover(sp);
end
end
   
save coralCoverBrickData covers
   
   
   
   