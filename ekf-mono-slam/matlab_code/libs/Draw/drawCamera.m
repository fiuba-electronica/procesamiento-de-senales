function drawCamera( location, color )
% 
% DRAW_CAMERA: draw a camera in the current figure
%
% draw_camera( location, color )
%
% input
%   location: 3D position and orientation (via quaternion)

q = location(4:7);

camera_size = 0.2;

vertices = [ 0    1 -1  0 ;
             0    0  0  0 ;
            2 -1 -1 2  ]*camera_size;
        
% Rotate the camera
r = q2r(q);
vertices = r * vertices;

% Translate the camera
vertices = vertices + [location(1:3) location(1:3) location(1:3) location(1:3)];

% Draw the vertices
plot3(vertices(1,:), vertices(2,:), vertices(3,:), color, 'LineWidth', 2);