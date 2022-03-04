function F0 = multiBBNInf(Data, R, knownVars,infNodes,increArray,nodePos)
% Calculates a series of posteriors based on BBN inferences, given a vector of known variables,
% a vector of the incremented variable, and information about the BBN.
% structure.
%
% Inputs -
%           Data : aray of data used to build the BBN size no. cases * no.
%                  nodes
%           R : rank correlation matrix for BBN
%           knownVars : vector of values which are known in the inference
%                       (in same order as ParentCell.
%           infNodes : vector of node numbers for nodes to perform inference on
%                        (unknown values). Must be of size
%                        length(ParentCell)-length(knownVars).
%           increArray : vector of once variable to increment over and plot
%                        histogram for (e.g. for years [10 20 30 40])
%           nodePos : indicator array where nodePos(1) indicates the node number
%                     for the incremented variable (as designated in ParentCell) 
%
% Outputs -
%           F0 : Cell strucutre containing the full distributions for each
%                inference

% Cell strucutre to store distributions
    F0 = cell(1,length(increArray));
    
    for l = 1:length(increArray)
        F0{l} = inference(infNodes,[knownVars(1:nodePos(1)-1) increArray(l) knownVars(nodePos(1):end)],...
            R,Data,'full',1000,'near');   
    end
    
end