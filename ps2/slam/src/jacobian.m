clear all
close all
clc

%% Calculo del Jacobiano de g(x)
syms px py vx vy ax ay z1x z1y z2x z2y z3x z3y x1x x1y x2x x2y x3x x3y x4x x4y
g = [
    ax
    ay
    sqrt((px-z1x)^2 + (py-z1y)^2)
    sqrt((px-z2x)^2 + (py-z2y)^2)
    sqrt((px-z3x)^2 + (py-z3y)^2)
    sqrt((px-x1x)^2 + (py-x1y)^2)
    sqrt((px-x2x)^2 + (py-x2y)^2)
    sqrt((px-x3x)^2 + (py-x3y)^2)
    sqrt((px-x4x)^2 + (py-x4y)^2)
    ];
v = [px py vx vy ax ay z1x z1y z2x z2y z3x z3y];

G = jacobian(g,v);
xi = [0 0 0 1000 1000 1000 1000 0];

x = [0.123 0.45 3 1.34 4.67 5.09 10.30 7.5 2 3];
G = subs(G,[x1x x1y x2x x2y x3x x3y x4x x4y],xi);
