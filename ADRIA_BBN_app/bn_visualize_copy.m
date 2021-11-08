function bn_visualize(ParentCell, R, Names, axes)

%% BN_VISUALIZE Visualize the structure of a defined Bayesian Network
%
%    bn_visualize(PARENTCELL) creates a directed digraph presenting the
%    structure of nodes and arcs of the Bayesian Network (BN), defined by
%    PARENTCELL. The function also displays the conditional rank
%    correlations at each arc.
%
%    INPUT. The required input is as follows:
%
%       PARENTCELL      A cell array containing the structure of the BN,
%                       the same as required in the bn_rankcorr function.
%       R               A matrix generated using bn_rankcorr function
%
%    OPTIONS. bn_visualize(DATA,R,NAMES) has the following option:
%
%       NAMES           A cell array containing names of the nodes of the
%                       BN; otherwise, default names are assigned.
%
%% ABOUT this code
%
%     Version: 1.2, 20-November-2020
%     Authors: Oswaldo Morales-Nápoles, Daniël Worm, 
%              Dominik Paprotny, Elisa Ragno
%     E-mail:  Paprotny@gfz-potsdam.de & O.MoralesNapoles@tudelft.nl
%
%     When using this script please cite:
%     Paprotny, D., Morales Nápoles, O., Worm, D.T.H., Ragno, E. (2020)
%     BANSHEEA Matlab Toolbox for Non-Parametric Bayesian Networks. 
%     SoftwareX, 12, 100588, https://doi.org/10.1016/j.softx.2020.100588
%
%% BANSHEE: A toolbox for non-parametric Bayesian Networks
%     Copyright (C) 2020 by Oswaldo Morales-Nápoles, Daniël Worm, 
%     Dominik Paprotny and Elisa Ragno.
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The only official release of BANSHEE is by the authors. If you wish 
%     to contribute to the official release of BANSHEE please contact the 
%     authors. The authors will decide which contributions would enter the 
%     official release of BANSHEE. 
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program. If not, see <https://www.gnu.org/licenses/>
%
%% calculation

% Reading the number of nodes in the BN
nod  = length(ParentCell);

% Assigning default optional parameters
if nargin<3
    Names = cell(nod,1);              % creates default node names
    for i=1:nod
        Names{i,1}=strcat('N',num2str(i));
    end
elseif nargin<2
    % Checking the number of input arguments and giving error if not enough
    error('Not enough input arguments')
end

% Creating an adjacency matrix
Ad = zeros(nod,nod);

for i=1:nod
    enod = ParentCell{1,nod-i+1};
    parent = size(enod,2);
    for j=1:parent
        par2 = enod(1,j);
        Ad(par2,nod-i+1)=1;
    end
end

% Calculating rank correlation per edge from matrix R
Rr = [];
for i=1:nod
    for j=1:nod
        if Ad(i,j)==1
            Rr = [Rr;R(i,j)];
        end
    end
end
Rr = round(Rr,3);

% Generating a Matlab digraph
G = digraph(Ad,Names);
G.Edges.Weight = abs(Rr);
% Creating a the plot
P = plot(axes,G,'Layout','force','EdgeLabel',Rr);
%
%set(gca,'visible','off')
% Customizing arcs
P.EdgeColor = [100/255,149/255,237/255];
%[135/255,206/255,235/255];
P.EdgeAlpha = 0.4;
LWidths = (18*G.Edges.Weight/max(G.Edges.Weight))+0.0001;
P.ArrowSize = 10;
P.LineWidth = LWidths;
P.NodeFontSize = 12;
P.EdgeFontSize = 12;
P.NodeFontWeight = 'bold';
P.EdgeLabelColor = [0/255,0/255,139/255];
% Customizing nodes
P.NodeLabelMode = 'auto';
P.EdgeLabelMode = 'auto'
P.NodeColor = [178/255,34/255,34/255];
P.MarkerSize = 12;
%P.Marker = 'o';