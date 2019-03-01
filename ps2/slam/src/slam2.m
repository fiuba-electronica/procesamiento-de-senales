clear all
close all
load('Acel.mat')
load('trayectoria.mat')
clc 

%% Variables temporales
time = Acel(:,1);
h = time(2)-time(1);

%% Variables espaciales
xi = [
      0 0
      0 1000
      1000 1000
      1000 0
     ]; %Cuadrilatero
zj = [
      345 234
      500 12
      987 654
     ]; %Puntos zj

Theta(:,2) = Theta(:,2)*pi/180;

d_real = [dist(zj,Preal(:,2:3)');dist(xi,Preal(:,2:3)')]'; %Distancias reales

%Rotacion de la aceleracion en la terna inercial
a = zeros(length(time),2);
for i=1:length(Theta(:,1))   
    rotation = [cos(Theta(i,2)) -sin(Theta(i,2))
               sin(Theta(i,2)) cos(Theta(i,2))];
    a(i,:) = (rotation*Acel(i,2:3)')';
end
clear i

adot = diff(a);
adot = [adot
        adot(length(time)-1,1) adot(length(time)-1,2)];


%% Variables estocasticas
sigma_d = 1; %Desvio del ruido de medicion de la distancia relativa [m]
sigmaAcel = 0.5; %Desvio del ruido de la aceleracion

eta_d = randn(length(time),7)*sigma_d; %Ruido de de las distancias
eta_a = randn(length(time),2)*sigmaAcel; %Ruido de la aceleracion

d_medida = d_real + eta_d; %Distancias medidas
a_medida = a + eta_a; %aceleracion medida

y_medida = [a_medida d_medida];

%% Condiciones iniciales
x0 = [
        Preal(1,2)+randn()*1000
        Preal(1,3)+randn()*1000
        Vreal(1,2)+randn()*1000
        Vreal(1,3)+randn()*1000
        Acel(1,2)+randn()*1000
        Acel(1,3)+randn()*1000
        zj(1,1)+randn()*1000
        zj(1,2)+randn()*1000
        zj(2,1)+randn()*1000
        zj(2,2)+randn()*1000
        zj(3,1)+randn()*1000
        zj(3,2)+randn()*1000
     ];

P0 = diag([100^2, 100^2, 100^2, 100^2, ...
    100^2, 100^2, 100^2, 100^2, 100^2, ...
    100^2,100^2,100^2]);
 
%% Matrices
Q = eye(12)*0.5; %Matriz de covarianza del ruido de proceso

R = diag([sigmaAcel^2,sigmaAcel^2,sigma_d^2*ones(1,7)]);
      %Matriz de covarianza del ruido de medicion

H = eye(12);
F = [eye(2) h*eye(2) h^2/2*eye(2) zeros(2,6)
    zeros(2) eye(2) h*eye(2) zeros(2,6)
    zeros(8,6) eye(8,6)];
D = [eye(2)*0
     eye(2)*0
     eye(2)*h
     zeros(6,2)];
 
%% Algoritmo de Kalman Extendido
x = x0;
P = P0;
xhat = zeros(12,length(time));
e = zeros(9,length(time));

for k=1:length(time)
    
    %Prediccion
    x = F*x+D*adot(k,:)';
    P = F*P*F' + H*Q*H';
    
    %Actualizacion
    g = [
        x(5)
        x(6)
        dist(x(7:8)',x(1:2))      % dp,z1
        dist(x(9:10)',x(1:2))     % dp,z2
        dist(x(11:12)',x(1:2))    % dp,z3
        dist(xi(1,:),x(1:2))      % dp,x0  
        dist(xi(2,:),x(1:2))      % dp,x1
        dist(xi(3,:),x(1:2))      % dp,x2
        dist(xi(4,:),x(1:2))      % dp,x3
        ];
    
    % Jacobiano
    G = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
         0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
        (x(1)-x(5))/g(1),(x(2)-x(6))/g(1),0, 0, 0, 0,-(x(1)-x(5))/g(1),-(x(2)-x(6))/g(1),0,0,0,0
        (x(1)-x(7))/g(2),(x(2)-x(8))/g(2),0, 0, 0, 0, 0, 0,-(x(1)-x(7))/g(2), -(x(2)-x(8))/g(2),0,0
        (x(1)-x(9))/g(3),(x(2)-x(10))/g(3),0, 0, 0, 0, 0, 0, 0, 0,-(x(1)-x(9))/g(3),-(x(2)-x(10))/g(3)
        (x(1)-xi(1,1))/g(4),(x(2)-xi(1,2))/g(4), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        (x(1)-xi(2,1))/g(5),(x(2)-xi(2,2))/g(5), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        (x(1)-xi(3,1))/g(6),(x(2)-xi(3,1))/g(6), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        (x(1)-xi(4,1))/g(7),(x(2)-xi(4,2))/g(7), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
        ];
    
    K = P*G'*inv(G*P*G'+R);
    x = x + K*(y_medida(k,:)'-g);
    P = (eye(12)-K*G)*P;
        
    %Guardamos las innovaciones
    e(:,k) = y_medida(k,:)'-g;        
    xhat(:,k) = x;
end

% perr = zeros(length(time),2);
% perr(:,1) = Preal(:,2)-xhat(1,:)';
% perr(:,2) = Preal(:,3)-xhat(2,:)';
% verr = zeros(length(time),2);
% verr(:,1) = Vreal(:,2)-xhat(3,:)'; 
% verr(:,2) = Vreal(:,3)-xhat(4,:)';

figure('name','Trayectoria real, estimada; Puntos reales y estimados')
hold on
title('Trayectoria real, estimada; Puntos reales y estimados')
ylabel('Posición en eje y [m]')
xlabel('Posición en eje x [m]')

plot(Preal(:,2),Preal(:,3))       %Trayectoria real
plot(xhat(1,:),xhat(2,:),'m')     %Trayectoria estimada

plot(xi(:,1),xi(:,2),'r+')        %Punto x

plot(zj(:,1),zj(:,2),'g+')        %Punto z
plot(x(7,:),x(8,:),'bx')          %Punto z1hat
plot(x(9,:),x(10,:),'bx')          %Punto z2hat
plot(x(10,:),x(12,:),'bx')         %Punto z3hat

legend('Trayectoria real','Trayectoria estimada','Puntos x','Puntos z', 'Puntos z estimados')

grid on
% % 
% % figure('name','Innovaciones')
% % title('Innovaciones')
% % xlabel('Tiempo [s]')
% % ylabel('Error')
% % subplot(7,1,1)
% % plot(time,e(1,:))
% % subplot(7,1,2)
% % plot(time,e(2,:))
% % subplot(7,1,3)
% % plot(time,e(3,:))
% % subplot(7,1,4)
% % plot(time,e(4,:))
% % subplot(7,1,5)
% % plot(time,e(5,:))
% % subplot(7,1,6)
% % plot(time,e(6,:))
% % subplot(7,1,7)
% % plot(time,e(7,:))
% % grid on
% % 
% % figure('name','Autocorrelacion de las innovaciones')
% % hold on
% % title('Autocorrelacion de las innovaciones')
% % xlabel('k')
% % ylabel('Amplitud')
% % plot(xcorr(e(1,:)),'g')
% % plot(xcorr(e(2,:)),'r')
% % plot(xcorr(e(3,:)),'b')
% % plot(xcorr(e(4,:)),'m')
% % plot(xcorr(e(5,:)),'y')
% % plot(xcorr(e(6,:)),'k')
% % plot(xcorr(e(7,:)),'c')
% % legend('Distancia a z1','Distancia a z2','Distancia a z3','Distancia a x0', ...
% %     'Distancia a x1','Distancia a x2','Distancia a x3')
% % grid on
% % 
% % 
% % figure('name','Estimacion de los puntos z')
% % hold on
% % title('Estimacion de los puntos z en el tiempo')
% % ylabel('Posicion en x/y')
% % xlabel('Tiempo [s]')
% % plot(time,xhat(5,:),'g')
% % plot(time,xhat(6,:),'r')
% % plot(time,xhat(7,:),'b')
% % plot(time,xhat(8,:),'m')
% % plot(time,xhat(9,:),'y')
% % plot(time,xhat(10,:),'c')
% % legend('z1x','z1y','z2x','z2y','z3x','z3y')
% % grid on
% % 
% % figure('name','Error de la posicion')
% % hold on
% % plot(time,perr(:,1))
% % plot(time,perr(:,2))
% % legend('px','py')
% % grid on
% % 
% % figure('name','Error de la velocidad')
% % hold on
% % plot(time,verr(:,1))
% % plot(time,verr(:,2))
% % legend('vx','vy')
% % grid on
% % 
% % figure('name','Error de estimacion de los puntos z')
% % hold on
% % title('Error de estimacion de los puntos z')
% % ylabel('Error [m]')
% % xlabel('Tiempo [s]')
% % plot(time(20000:end),xhat(5,20000:end)-zj(1,1)*ones(1,length(time)-20000+1),'g')
% % plot(time(20000:end),xhat(6,20000:end)-zj(1,2)*ones(1,length(time)-20000+1),'r')
% % plot(time(20000:end),xhat(7,20000:end)-zj(2,1)*ones(1,length(time)-20000+1),'b')
% % plot(time(20000:end),xhat(8,20000:end)-zj(2,2)*ones(1,length(time)-20000+1),'m')
% % plot(time(20000:end),xhat(9,20000:end)-zj(3,1)*ones(1,length(time)-20000+1),'y')
% % plot(time(20000:end),xhat(10,20000:end)-zj(3,2)*ones(1,length(time)-20000+1),'c')
% % legend('z1x','z1y','z2x','z2y','z3x','z3y')
% % grid on


