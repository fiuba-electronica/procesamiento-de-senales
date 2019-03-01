clear all
close all
load('Acel.mat')
load('Gyro.mat')

load('Radar.mat')
%load('Radar-sesgo-vel.mat')
%load('Radar-sesgo-pos.mat')

load('trayectoria.mat')
clc 

%Le sumamos un sesgo a la ac0eleración
Acel(:,2) = Acel(:,2) ;
Acel(:,3) = Acel(:,3) ;

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
    1
    -1]; 

P0 = diag([100^2, 100^2, 0.2^2, 0.2^2, ...
    (sin(angInicial)*40*pi/180)^2, ...
    (cos(angInicial)*40*pi/180)^2, ...
    (cos(angInicial)*40*pi/180)^2, ...
    (sin(angInicial)*40*pi/180)^2, ...
    1^2, ...
    1^2]);
    
%Ruido de proceso (suponemos nulo, aunque no sea así por discretizar)

%Ruido de proceso (solo al sesgo)
Q = [eye(8)*0.01^2 zeros(8,2)
    zeros(2,8) eye(2)*0.01000^2];
Q = zeros(10);
%Ruido de medición (del radar)
R = diag([sigmaPos^2,sigmaPos^2, sigmaVel^2,sigmaVel^2]); 

B = eye(10);
C = [eye(2) zeros(2,8)
     zeros(2,2) eye(2) zeros(2,6)]; %Ningun sesgo en las mediciones

x = x0;
P = P0;
kRadar = 1;
xPred = zeros(10,length(tiempo));
observable = zeros(1, length(tiempo));
dinamica = cell(1,length(tiempo));
 
for k=1:length(tiempo)  
    %Paso de predicción no lineal
    if x~=1 
        x = x+h*[ x(3) %Vx
                  x(4) %Vy
                    x(5)*(Acel(k-1,2) + x(9))+x(6)*(Acel(k-1,3)+x(10))
                    x(7)*(Acel(k-1,2) + x(9))+x(8)*(Acel(k-1,3)+x(10))
                    x(6)*Gyro(k-1,2)
                    -x(5)*Gyro(k-1,2)
                    x(8)*Gyro(k-1,2)
                    -x(7)*Gyro(k-1,2)
                    0
                    0
            ];
    end
    
    F = [zeros(1,2) 1 zeros(1,7)
        zeros(1,3) 1 zeros(1,6)
        zeros(1,4) (Acel(k,2)+x(9)) (Acel(k,3)+x(10)) zeros(1,2) x(5) x(6)
        zeros(1,6) (Acel(k,2)+x(9)) (Acel(k,3)+x(10)) x(7) x(8)
        zeros(1,5) Gyro(k,2) zeros(1,4)
        zeros(1,4) -Gyro(k,2) zeros(1,5)
        zeros(1,7) Gyro(k,2) zeros(1,2)
        zeros(1,6) -Gyro(k,2) zeros(1,3)
        zeros(1,10)
        zeros(1,10)
        ];
    F = (eye(10)+F*h); %Discretizar a primer orden
    
    P = F*P*F' + B*Q*B';
    
    dinamica{k} = F;
    
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
title('Trayectoria real y predicción');
plot(Preal(:,2),Preal(:,3))
plot(xPred(1,:),xPred(2,:))
grid on

figure
hold all
title('Error de estimación de ángulo (con arcotangente)');
plot(tiempo,unwrap(atan2(-xPred(6,:),xPred(8,:))))
plot(tiempo,Theta(:,2)/180*pi)
grid on

figure
hold all
title('Error de estimación de ángulo (con coseno)');
plot(tiempo,xPred(5,:))
plot(tiempo,xPred(8,:))
plot(tiempo,cos(Theta(:,2)/180*pi))
grid on

%Error de posición
figure
hold all
title('Error de estimación de posición');
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

%Sesgo estimado
figure
hold all
title('Sesgo estimado');
plot(tiempo,xPred(9,:)')
plot(tiempo,xPred(10,:)')
grid on

%Error de angulo
figure
hold all
title('Error de estimación de ángulo');
plot(tiempo,xPred(5,:)-cos(Theta(:,2)'/180*pi))
grid on

%Correlacion de innovaciones
figure
hold all
title('Autocorrelación de innovaciones de posición');
plot(xcorr(xInnov(1,:)))
plot(xcorr(xInnov(2,:)))
grid on

figure
hold all
title('Autocorrelación de innovaciones de velocidad');
plot(xcorr(xInnov(3,:)))
plot(xcorr(xInnov(4,:)))
grid on

matObs = [C];
for i=1:100
    matProd = eye(10);
    for k=1:i
        matProd = matProd*dinamica{k};
    end
    matObs = [matObs
             C*matProd];
         
    rango(i) = rank(matObs);
end

figure
plot(rango)