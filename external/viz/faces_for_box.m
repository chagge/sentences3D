function faces = faces_for_box()

% assumes we want faces for a box with the following numbering of vertices:
%     8-----7
%    /|    /|
%   4-----3 |
%   | 5---|-6
%   1-----2/
%

faces = [1,2,3,4; % front
         1,2,6,5; % ground
         2,6,7,3; % right
         5,1,4,8; % left
         4,3,7,8; % top
         6,5,8,7; % back
         ];        