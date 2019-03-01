clear all
close all
load('Acel.mat')
load('Gyro.mat')

%load('Radar.mat')
load('Radar-sesgo-vel.mat')
%load('Radar-sesgo-pos.mat')

load('trayectoria.mat')
clc 

% Variables temporales
tiempo = Acel(:,1);
tiempoRadar = Pradar(:,1);
h = tiempo(2)-tiempo(1);
hRadar = tiempoRadar(2)-tiempoRadar(1);

sigmaPos = 10; %Ruido del radar (pos)
sigmaVel = 0.1; %Ruido del radar (vel)
medicionesRadar = [Pradar(:,2:3) Vradar(:,2:3)];

% Condiciones iniciales
angInicial = (randn()*40)*pi/180;
x0 = [Preal(1,2)+100*randn()
    Preal(1,3)+100*randn()
    Vreal(1,2)+0.2*randn()
    Vreal(1,3)+0.2*randn()
    cos(angInicial)
    -sin(angInicial)
    sin(angInicial)
    cos(angInicial)
    0%-(400.6-410.9)
    0];%-(399.6-380.1)]; 

P0 = diag([100^2, 100^2, 0.2^2, 0.2^2, ...
    (sin(angInicial)*40*pi/180)^2, ...
    (cos(angInicial)*40*pi/180)^2, ...
    (cos(angInicial)*40*pi/180)^2, ...
    (sin(angInicial)*40*pi/180)^2, ...
    20^2, ...
    20^2]);
    
%Ruido de proceso (suponemos nulo, aunque no sea así por discretizar)
Q = eye(10)*0.00000000000;%zeros(8);
%Ruido de medición (del radar)
R = diag([sigmaPos^2,sigmaPos^2, sigmaVel^2,sigmaVel^2]); 

B = eye(10);
%Sesgo en posición
C = [eye(2) zeros(2,6) eye(2)
     zeros(2,2) eye(2) zeros(2,4) zeros(2,2)]; %Agregado sesgo en pos
 %Sesgo en velocidad
 C = [eye(2) zeros(2,8) 
     zeros(2,2) eye(2) zeros(2,4) eye(2)]; %Agregado sesgo en vel

x = x0;
P = P0;
kRadar = 1;
xPred = zeros(10,length(tiempo));

for k=1:length(tiempo)
    A = [1 0 h 0 0 0 0 0
         0 1 0 h 0 0 0 0
         0 0 1 0 h*Acel(k,2) h*Acel(k,3) 0 0
         0 0 0 1 0 0 h*Acel(k,2) h*Acel(k,3)
         0 0 0 0 1 h*Gyro(k,2) 0 0
         0 0 0 0 -h*Gyro(k,2) 1 0 0
         0 0 0 0 0 0 1 h*Gyro(k,2)
         0 0 0 0 0 0 -h*Gyro(k,2) 1];
    
     A = [A zeros(8,2)
         zeros(2,8) eye(2)];
     
    x = A*x;
    P = A*P*A' + B*Q*B';
    
    if mod(k,hRadar/h) == 1 && k~=1       
        K = P*C'*inv(C*P*C'+R);
        x = x + K*(medicionesRadar(kRadar,:)'-C*x);
        P = (eye(10)-K*C)*P;
        
        %Guardamos las innovaciones
        xInnov(:,kRadar) = medicionesRadar(kRadar,:)'-C*x;
        kRadar = kRadar + 1;       
    end
        
    xPred(:,k) = x;
end

figure
hold all
title('Trayectoria real y estimada');
plot(Preal(:,2),Preal(:,3))
plot(xPred(1,:),xPred(2,:))
grid on

figure
hold all
title('Ángulo real y estimado (arcotangente)');
plot(tiempo,unwrap(atan2(-xPred(6,:),xPred(8,:))))
plot(tiempo,Theta(:,2)/180*pi)
grid on

figure
hold all
title('cos(Ángulo) real y estimado');
plot(tiempo,xPred(5,:))
plot(tiempo,xPred(8,:))
plot(tiempo,cos(Theta(:,2)/180*pi))
grid on

%Error de posición
figure
hold all
title('Error de posición');
plot(tiempo,Preal(:,2)-xPred(1,:)')
plot(tiempo,Preal(:,3)-xPred(2,:)')
grid on

%Error de velocidad
figure
hold all
title('Error de estimacion de velocidad');
plot(tiempo,Vreal(:,2)-xPred(3,:)')
plot(tiempo,Vreal(:,3)-xPred(4,:)')
grid on

%Sesgo
figure
hold all
title('Estimación del sesgo');
plot(tiempo,xPred(9,:)')
plot(tiempo,xPred(10,:)')
grid on

%Error de Ángulo
figure
hold all
title('Error de ángulo');
plot(tiempo,xPred(5,:)-cos(Theta(:,2)'/180*pi))
grid on

%Correlacion de innovaciones
figure
hold all
title('Correlación de innovaciones (medición 1)');
plot(xcorr(xInnov(1,:)))
plot(xcorr(xInnov(2,:)))
grid on

figure
hold all
title('Correlación de innovaciones (medición 2)');
plot(xcorr(xInnov(3,:)))
plot(xcorr(xInnov(4,:)))
grid on