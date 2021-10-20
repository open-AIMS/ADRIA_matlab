function DHWdisttime = ADRIA_DHWprojectfun(tf,nsites,mdhwdist0,sdhwdist0,dhwmax25,RCP,wb1,wb2)

%explanation
if RCP == 26
    heatrate = 0.2; 
elseif RCP == 45
    heatrate = 0.3;
elseif RCP == 60
    heatrate = 0.5;
elseif RCP == 6085
    heatrate = 0.75;
elseif RCP == 85
    heatrate = 1.5;
end

DHW = ones(tf,nsites); %initialise
for t = 1:tf
    wblsample = wblrnd(wb1,wb2,1); %sample from under the maxDHW curve
    wblsample(wblsample>1) = 1; 
    DHW(t,:) = wblsample*((dhwmax25 + normrnd(mdhwdist0,sdhwdist0))+heatrate*t); 
end
DHW(DHW<0) = 0; 
DHWdisttime = DHW;

end %function