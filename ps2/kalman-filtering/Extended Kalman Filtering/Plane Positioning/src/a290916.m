clear all
close all
load('Acel.mat')
load('Gyro.mat')
load('Radar.mat')
load('trayectoria.mat')
clc 

% Variables temporales
tiempo = Acel(:,1);
tiempoRadar = Pradar(:,1);
h = tiempo(2)-tiempo(1);
hRadar = tiempoRadar(2)-tiempoRadar(1);

sigmaPos = 10; %Ruido del radar (pos)
sigmaVel = 0.1; %Ruido del radar (vel)
%etaPos = randn(length(tiempoRadar),2)*sigmaPos;
%etaVel = randn(length(tiempoRadar),2)*sigmaVel;
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
    0.2*randn()
    0.2*randn()]; 

P0 = diag([100^2, 100^2, 0.2^2, 0.2^2, ...
    (sin(angInicial)*40*pi/180)^2, ...
    (cos(angInicial)*40*pi/180)^2, ...
    (cos(angInicial)*40*pi/180)^2, ...
    (sin(angInicial)*40*pi/180)^2, ...
    0.2^2, 0.2^2]);
    
%Ruido de proceso (suponemos nulo, aunque no sea así por discretizar)
Q = eye(10)*0.0000000000;%zeros(8);
%Ruido de medición (del radar)
R = diag([sigmaPos^2,sigmaPos^2, sigmaVel^2,sigmaVel^2]); 

B = eye(10);
C = [eye(2) zeros(2,8)
     zeros(2,2) eye(2) zeros(2,6)];

x = x0;
P = P0;
kRadar = 1;
xPred = zeros(10,length(tiempo));

for k=1:length(tiempo)
   fx = [0 0 1 0 0 0 0 0 0 0
         0 0 0 1 0 0 0 0 0 0
         0 0 0 0 (Acel(k,2)-x(9)) (Acel(k,3)-x(10)) 0 0 0 0
         0 0 0 0 0 0 (Acel(k,2)-x(9)) (Acel(k,3)-x(10)) 0 0
         0 0 0 0 0 Gyro(k,2) 0 0 0 0
         0 0 0 0 -Gyro(k,2) 0 0 0 0 0
         0 0 0 0 0 0 0 Gyro(k,2) 0 0
         0 0 0 0 0 0 -Gyro(k,2) 0 0 0
         0 0 0 0 0 0 0 0 0 0
         0 0 0 0 0 0 0 0 0 0];  
     
    x = x+h*fx*x;  
    
    AJ = [1 0 h 0 0 0 0 0 0 0
         0 1 0 h 0 0 0 0 0 0
         0 0 1 0 h*(Acel(k,2)-x(9)) h*(Acel(k,3)-x(10)) 0 0 -h*x(5) -h*x(6)
         0 0 0 1 0 0 h*(Acel(k,2)-x(9)) h*(Acel(k,3)-x(10)) -h*x(7) -h*x(8)
         0 0 0 0 1 h*Gyro(k,2) 0 0 0 0
         0 0 0 0 -h*Gyro(k,2) 1 0 0 0 0
         0 0 0 0 0 0 1 h*Gyro(k,2) 0 0
         0 0 0 0 0 0 -h*Gyro(k,2) 1 0 0
         0 0 0 0 0 0 0 0 1 0
         0 0 0 0 0 0 0 0 0 1];
    
    P = AJ*P*AJ' + B*Q*B';
    
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
plot(Preal(:,2),Preal(:,3))
plot(xPred(1,:),xPred(2,:))
grid on

figure
hold all
plot(tiempo,unwrap(atan2(-xPred(6,:),xPred(8,:))))
plot(tiempo,Theta(:,2)/180*pi)
grid on

figure
hold all
plot(tiempo,xPred(5,:))
plot(tiempo,xPred(8,:))
plot(tiempo,cos(Theta(:,2)/180*pi))
grid on

%Error de posición
figure
hold all
plot(tiempo,Preal(:,2)-xPred(1,:)')
plot(tiempo,Preal(:,3)-xPred(2,:)')
grid on

%Error de velocidad
figure
hold all
plot(tiempo,Vreal(:,2)-xPred(3,:)')
plot(tiempo,Vreal(:,3)-xPred(4,:)')
grid on

%Error de angulo
figure
hold all
plot(tiempo,xPred(5,:)-cos(Theta(:,2)'/180*pi))
grid on

%Innovaciones
figure
hold all
plot(tiempoRadar,xInnov(1,:))
plot(tiempoRadar,xInnov(2,:))
plot(tiempoRadar,xInnov(3,:))
plot(tiempoRadar,xInnov(4,:))
grid on

%Correlacion de innovaciones
figure
hold all
plot(xcorr(xInnov(1,:)))
plot(xcorr(xInnov(2,:)))
grid on

figure
hold all
plot(xcorr(xInnov(3,:)))
plot(xcorr(xInnov(4,:)))
grid on