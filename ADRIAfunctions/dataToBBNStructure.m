function [R, ParentCell] = dataToBBNStructure(nodeNames,Data,outputVars,visVars)
% Creates a BBN structure (directed acyclic graph) using inputs for node
% names and data
%
% Inputs -
%           nodeNames : is a cell structure of strings containing the BBN node names
%                       in the desired order (which is used in inference)
%           Data : an m by n array where n is the number of nodes and m is the number
%                  of cases or variable permutations in the data set.
%           outputVars : array giving the indices of 'output/dependent'
%                         nodes. E.g. Coral cover will be dependent on the
%                         rest of the nodes. If coral cover is node no. 10
%                         then outputVars = 10.
%           visVars : a 1 by 2 array where visVars(1) = 1 if want to
%                     plot the correlation matrix for the BBN (0 if not)
%                     and visVars(2) = 1 if want to plot the BBN DAG with
%                     rank correlation weights (0 if not)
% 
% Outputs - 
%           R : rank correlation matrix (needed for any further inference)
%           ParentCell : 1 by (no. of nodes) cell structure designating DAG 
%                        links in the BBN
%        

    % number of nodes
    nNodes = length(nodeNames);
    % number of nodes which are dependent variables
    nOutput = length(outputVars);
    % create parant cell container for DAG structure
    ParentCell = cell(1,nNodes);
    
    % input variables assumed to have no dependent nodes (so corresponding
    % parent cell entry is blank
    for k = 1:(nNodes-nOutput)
        ParentCell{k} = [];
    end
    % output variables assumed to be dependent on all input variables
    for l = ((nNodes-nOutput)+1):nNodes
        ParentCell{l} = 1:(nNodes-nOutput)
    end
    
    % generate rank correlation matrix
    R =  bn_rankcorr(ParentCell, Data, 1, visVars(1), nodeNames);
    
    % if visVars(2) ==1, plot the DAG structure also
    if logical(visVars(2))
        figure(2)
        bn_visualize(ParentCell,R,nodeNames,gca);
    end
end

