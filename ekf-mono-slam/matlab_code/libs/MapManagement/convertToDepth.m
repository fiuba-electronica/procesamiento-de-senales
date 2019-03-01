function [ cartesian ] = convertToDepth( inverse_depth )

rWC = inverse_depth(1:3,:);
theta = inverse_depth(4,:);
phi = inverse_depth(5,:);
rho = inverse_depth(6,:);

cphi = cos(phi);
m = [cphi.*sin(theta);   -sin(phi);  cphi.*cos(theta)];   
cartesian(1,:) = rWC(1) + (1./rho).*m(1,:);
cartesian(2,:) = rWC(2) + (1./rho).*m(2,:);
cartesian(3,:) = rWC(3) + (1./rho).*m(3,:);