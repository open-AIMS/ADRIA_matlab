function [IT,N,Itable] = InterventionTable(Interv)
%
% Input: 
%   Interv: structure containing the set of intervention input selected by
%   the user
%
% Output:
%   TBL: 2D matrix that contains the interventions
%   N: Total number of elements in table
%   Itable: Table that contains the interventions selected
%   

%% Constructing the table
nA = numel(Interv.Guided);
nB = numel(Interv.PrSites);
nC = numel(Interv.Seed1);
nD = numel(Interv.Seed2);
nE = numel(Interv.SRM);
nF = numel(Interv.Aadpt);
nG = numel(Interv.Natad);
nH = numel(Interv.Seedyrs);
nI = numel(Interv.Shadeyrs);
nJ = numel(Interv.sims);

nvar = length(fieldnames(Interv));

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

IT(:,1) = reshape(repmat(Interv.Guided,A,1),N,N/(nA*A)); %then reshape and stack according to components
IT(:,2) = reshape(repmat(Interv.PrSites,B,N/(nB*B)),N,1);
IT(:,3) = reshape(repmat(Interv.Seed1,C,N/(nC*C)),N,1);
IT(:,4) = reshape(repmat(Interv.Seed2,D,N/(nD*D)),N,1);
IT(:,5) = reshape(repmat(Interv.SRM,E,N/(nE*E)),N,1);
IT(:,6) = reshape(repmat(Interv.Aadpt,F,N/(nF*F)),N,1);
IT(:,7) = reshape(repmat(Interv.Natad,G,N/(nG*G)),N,1);
IT(:,8) = reshape(repmat(Interv.Seedyrs,H,N/(nH*H)),N,1);
IT(:,9) = reshape(repmat(Interv.Shadeyrs,I,N/(nI*I)),N,1);
IT(:,10) = reshape(repmat(Interv.sims,I,N/(nJ*J)),N,1);

Itable = table(Interv.Guided,Interv.PrSites,Interv.Seed1,Interv.Seed2,...
    Interv.SRM,Interv.Aadpt,Interv.Natad,Interv.Seedyrs,Interv.Shadeyrs,Interv.sims);
end
