function parent_cell = createParentCell(nnodes,nmetrics)
% Creates the parent cell structure for use with BBN toolbox
% INPUTS:
%        nnodes - scalar integer, total number of nodes in the network.
%        nmetrics - number of dependent (outcome) nodes, assumed to be last
%                   in the node order.
% OUTPUTS: 
%       parent_cell - cell structure where each cell gives the parent nodes
%                    for that cell's node.

parent_cell = cell(1,nnodes);

% independent nodes have no parents
for i = 1:nnodes-nmetrics
    parent_cell{i} = [];
end
% dependent nodes have all other nodes as parents
for k = 0:nmetrics-1
    parent_cell{nnodes-k} = 1:nnodes-nmetrics;
end
end