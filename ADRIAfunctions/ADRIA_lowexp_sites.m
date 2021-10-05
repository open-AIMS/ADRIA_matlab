
function lowexpsites = ADRIA_lowexp_sites(nlowexpsites,swh_array,resdhwsites,figshow)

% Select subset of reefs that have low wave and heat exposure

wavesites = swh_array(:,[1,7]);
heatsites = mean(resdhwsites(:,[5:7]),2);
%heatsites_sort = sortrows(heatsites,2,'ascend');

expsites = zeros(26,3); 
expsites = horzcat(wavesites,heatsites);
mexpw = mean(expsites(:,2)); 
mexph = mean(expsites(:,3));

x = 1:26;
mexp(:,1) = x;
mexp(:,2) = expsites(:,2) - mexpw;
mexp(:,3) = expsites(:,3) - mexph;

normexp(:,1) = x;
normexp(:,2) = mexp(:,2)/max(mexp(:,2));
normexp(:,3) = mexp(:,3)/max(mexp(:,2));


mnormexp(:,1) = x;
mnormexp(:,2) = mean(normexp,2);
sortexpsites = sortrows(mnormexp, 2,'ascend');
lowexpsites = sortexpsites(1:nlowexpsites)';

%Run PCA
if figshow == 1
figure('Position', [100, 50, 500, 500]);
[~,~,~,~,~] = pca(normexp(:,2:3));
varnames = num2str(normexp(:,1));
biplot(normexp(:,2:3),'varlabels',varnames)

xlabel('1st Principal Component')
ylabel('2nd Principal Component')
axis([-1.5,1.5, -inf,inf])
end
end

