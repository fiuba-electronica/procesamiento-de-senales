clear all
close all
load('TP1-10dB.mat')
clc 

% Límites
N = 100; %Tiempo max
p = 10; %Coeficientes a estimar

% Condiciones iniciales
x0 = [ones(p,1)*2;randn()*10;zeros(p-1,1)]; 
P0 = [0.5^2*eye(p+1) zeros(p+1,p-1)
    zeros(p-1,p+1) zeros(p-1)];
    
%Ruido de proceso
Q = [eye(p+1)*1.0 zeros(p+1,p-1)
    zeros(p-1,p+1) zeros(p-1)];
B = eye(p+p);

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
    Af = diag(exp(-alpha(p,[0:p-1])*n));
    A = [Af zeros(p)
         zeros(p)    toeplitz([0 1 zeros(1,p-2)],zeros(1,p))];
          
    x = A*x;
    P = A*P*A' + B*Q*B';
  
    %Linealizacion Salida
    g = x(1:10)' * x(11:20);
    C = [x(11:20)' x(1:10)'];    
    
    K = P*C'*inv(C*P*C'+R);
    x = x + K*(y(n+1)-g); %Usamos la función de salida no lineal
    P = (eye(p+p)-K*C)*P;
        
    %Guardamos las innovaciones y estimaciones (tomando la fcn no lineal)
    xInnov(n+1) = y(n+1)-g;
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
title('Entrada');
plot(xPred(11,:));
legend('K11');
plot(u(0:99));

figure
hold all;
title('Coeficientes');
for k=1:10
    plot(xPred(k,:));
end


figure
hold all;
title('Salida real');
plot(y);

