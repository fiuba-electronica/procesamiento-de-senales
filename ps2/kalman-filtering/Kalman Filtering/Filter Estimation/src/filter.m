clear all
close all
load('TP1-10dB.mat')
clc 

% Límites
N = 100; %Tiempo max
p = 10; %Coeficientes a estimar

% Condiciones iniciales
x0 = ones(p,1)*2; 
P0 = 0.5^2*eye(p);
    
%Ruido de proceso
Q = eye(p)*0.100000000000;
B = eye(p);

%Ruido de medición 
R = 0.1; %SNR=10 dB 

x = x0;
P = P0;

alpha = @(p,k) 0.001-(p-k)/10000;
u_delta = @(n) 1*(n==0);
u_escalon = @(n) 1*(n>=0).*(n<=N-1);
u_pulso = @(n) 1*(n>=0).*(n<=N/2-1);
u_sin = @(n) sin(pi/16 .* n);

%Caso a probar
u = u_pulso;
y = y_pulso;

for n=0:N-1
    A = diag(exp(-alpha(p,[0:p-1])*n));
         
    C = u(n-[0:p-1]);
    
    x = A*x;
    P = A*P*A' + B*Q*B';
  
    K = P*C'*inv(C*P*C'+R);
    x = x + K*(y(n+1)-C*x);
    P = (eye(p)-K*C)*P;
        
    %Guardamos las innovaciones y estimaciones
    xInnov(n+1) = y(n+1)-C*x;   
    xPred(:,n+1) = x;
end

figure
hold all;
title('Innovaciones');
plot(xInnov);

figure
hold all;
title('Autocorrelacion de las innovaciones');
plot(xcorr(xInnov));

figure
hold all;
title('Coeficientes');
for k=1:p
    plot(xPred(k,:));
end

figure
hold all;
title('Salida medida vs salida estimada');
plot(y);

for n=0:N-1
    salida(n+1) = u(n-[0:p-1]) * xPred(:,n+1);
end

plot(salida);