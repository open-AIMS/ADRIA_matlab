function colorsm = buildColormap(type)

% Build a custom colormap
%
% Input: 
%   type: name I gave in this function to the colormap type
%       Options:
%           'white-red'
%           'blue-white-red'
%           'red-white-purple'
%           'purple-white-red'
%           'white-pink-red'
%           'white-turquoise-blue'
%           'pink-blue-notransition'
%
% Output:
%   colorsm: custom colormap to feed to the colormap function
%
% By Veronique Lago, July 2017, UNSW/CCRC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch type
    case 'white-red' % Good for MLD
        % White to red
        colorsm = [1:-0.005:0.6; 1:-0.0112:0.1; 1:-0.0105:0.15]';
        
    case 'blue-white-red'
        colorsm = zeros(31,3);
        % Blue
        colorsm(1:16,:) = [0.2:0.035:0.75; 0.2:0.0457:0.9; 0.9:-0.0026:0.86]';
        % White
        colorsm(17,:) = [1; 1; 0.9]';
        % Red
        colorsm(18:33,:) = [0.86:0.0026:0.9; 0.9:-0.046:0.2; 0.55:-0.0233:0.2]';
        
    case 'red-white-purple'
        colorsm = zeros(42,3);
        % Red
        colorsm(1:19,:) = [0.9:-0.0022:0.86; 0.2:0.0369:0.9; 0.2:0.0185:0.55]';
        % White
        colorsm(20:22,:) = ones(3,3);
        % Blue
        colorsm(23:37,:) = [0.75:-(0.001+(0.75-0.2)/15):0.2; 0.9:-(0.001+(0.9-0.2)/15):0.2;...
            0.86:-(-0.0001+(0.86-0.9)/15):0.9]';
        % Purple
        colorsm(38:42,:) = [0.3:-(-0.001+(0.3-0.6)/5):0.6; 0.1:-(0.001+(0.1-0)/5):0;...
            0.7:-(0.0001+(0.7-0.55)/5):0.55]';
        
    case 'purple-white-red'
        colorsm = zeros(40,3);
        % Purple
        colorsm(1:3,:) = [0.6:-(0.001+(0.6-0.3)/3):0.3; 0:-(-0.001+(0-0.1)/3):0.1;...
            0.55:-(-0.0001+(0.55-0.7)/3):0.7]';
        % Blue
        colorsm(4:18,:) = [0.2:-(-0.001+(0.2-0.75)/15):0.75; 0.2:-(-0.001+(0.2-0.9)/15):0.9;...
            0.9:-(0.0001+(0.9-0.86)/15):0.86]';
        % White
        colorsm(19:21,:) = ones(3,3);
        % Red
        colorsm(22:40,:) = [0.86:0.0022:0.9; 0.9:-0.0369:0.2; 0.55:-0.0185:0.2]';
        
    case 'white-pink-red'
        colorsm = zeros(41,3);
        % White to pink
        colorsm(1:21,:) = [1:-0.01:0.8; 1:-0.0475:0.05; 0.95:-0.0075:0.8]';
        % Pink to purple
        colorsm(22:42,:) = [0.8:-0.01:0.6; 0.05:0.005:0.15; 0.8:-0.01:0.6]';
        % Purple to red
        colorsm(43:69,:) = [0.6:0.0075:0.8; 0.15:-0.0019:0.1; 0.6:-0.0167:0.15]';
        
    case 'white-turquoise-blue'
        colorsm = zeros(41,3);
        colorsm(1,:) = [1 1 1];
        % White to turquoise
        colorsm(2:22,:) = [0.95:-0.045:0.05; 1:-0.01:0.8; 1:-0.01:0.8]';
        % Turquoise to teal
        colorsm(23:43,:) = [0.05:0.005:0.15; 0.8:-0.01:0.6; 0.8:-0.01:0.6]';
        % Teal to blue
        colorsm(44:70,:) = [0.15:-0.0019:0.1; 0.6:-0.0167:0.15; 0.6:0.0038:0.7]';
    case 'pink-blue-notransition'
        colorsm = zeros(3,3);
        colorsm(1,:) = [0.93 0.93 1];
        colorsm(2,:) = [1 1 1];
        colorsm(3,:) = [1 0.93 0.93];
    case 'categories5'
        colorsm = zeros(5,3);
        colorsm(1,:) = [0 0 0]; %category 1: black
        colorsm(2,:) = [0.35 0.25 1]; % category 2: Blue
        colorsm(3,:) = [0.68 0.21 0.88]; % category 3: Purple
        colorsm(4,:) = [0 0.75 0.3]; % category 4: Pale Green
        colorsm(5,:) = [0.85 0.73 0.36]; % category 5: Ocre
end