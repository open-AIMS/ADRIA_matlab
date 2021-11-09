function [IT,Itable] = interventionTable(interv)
%
% Input: 
%   Interv : structure containing the set of intervention input selected by
%            the user
%
% Output:
%   IT     : 2D matrix that contains the interventions
%   Itable : Table that contains the interventions selected
%   

%% Constructing the table
nA = numel(interv.Guided);
nB = numel(interv.PrSites);
nC = numel(interv.Seed1);
nD = numel(interv.Seed2);
nE = numel(interv.SRM);
nF = numel(interv.Aadpt);
nG = numel(interv.Natad);
nH = numel(interv.Seedyrs);
nI = numel(interv.Shadeyrs);
nJ = numel(interv.sims);

nvar = length(fieldnames(interv));

%% Total number of rows in table
N = nA.*nB.*nC.*nD.*nE.*nF.*nG.*nH.*nI.*nJ;

IT = zeros(N,nvar);

%Cutting the table up into stacked components
A = N/nA; %Whole length of table divided by components in first column
B = A/nB; %Subsection of A divided up by components in second column
C = B/nC;  %etc
D = C/nD;
E = D/nE;
F = E/nF;
G = F/nG;
H = G/nH;
I = H/nI;
J = I/nJ; %Subsection of penultimate column divided up by components in the last column

IT(:,1) = reshape(repmat(interv.Guided,A,1),N,N/(nA*A)); %then reshape and stack according to components
IT(:,2) = reshape(repmat(interv.PrSites,B,N/(nB*B)),N,1);
IT(:,3) = reshape(repmat(interv.Seed1,C,N/(nC*C)),N,1);
IT(:,4) = reshape(repmat(interv.Seed2,D,N/(nD*D)),N,1);
IT(:,5) = reshape(repmat(interv.SRM,E,N/(nE*E)),N,1);
IT(:,6) = reshape(repmat(interv.Aadpt,F,N/(nF*F)),N,1);
IT(:,7) = reshape(repmat(interv.Natad,G,N/(nG*G)),N,1);
IT(:,8) = reshape(repmat(interv.Seedyrs,H,N/(nH*H)),N,1);
IT(:,9) = reshape(repmat(interv.Shadeyrs,I,N/(nI*I)),N,1);
IT(:,10) = reshape(repmat(interv.sims,I,N/(nJ*J)),N,1);

Itable = table(interv.Guided,interv.PrSites,interv.Seed1,interv.Seed2,...
    interv.SRM,interv.Aadpt,interv.Natad,interv.Seedyrs,interv.Shadeyrs,interv.sims);
end
