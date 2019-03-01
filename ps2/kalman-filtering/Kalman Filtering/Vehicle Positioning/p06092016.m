clear all
close all
load('datos.mat')
clc 

h = 1;
sigma = 10;
eta = randn(length(tiempo),3)'*sigma;

x0 = [1e-6*ones(3,1)
      zeros(6,1)]; 
  
P0_0 = [1*eye(3) zeros(3) zeros(3)
        zeros(3) 1e-3*eye(3) zeros(3)
        zeros(3) zeros(3) 1*eye(3)];
Q = [(0.2*h^3/3)^2*eye(3) zeros(3) zeros(3)
        zeros(3) (0.2*h^2/3)^2*eye(3) zeros(3)
        zeros(3) zeros(3) (0.2*h/3)^2*eye(3)];
R = sigma^2*eye(3);    
A = [1*eye(3) h*eye(3) 0.5*h^2*eye(3)
    zeros(3) 1*eye(3) h*eye(3)
    zeros(3) zeros(3) 1*eye(3)];
B = eye(9);
C = [eye(3) zeros(3) zeros(3)];
D = zeros(9);

%% Prediccion (gaussiano)
eta = randn(length(tiempo),3)'*sigma;
y = [Pos]';
y_hat = y + eta;

xk_k1 = zeros(9,length(tiempo));
xk_k =  zeros(9,length(tiempo));

xk_k1(:,1) = A*x0;
Pk_k1 = A*P0_0*A' + B*Q*B';
K_k = Pk_k1*C'*inv(C*Pk_k1*C'+R);
xk_k(:,1) = xk_k1(:,1)+K_k*(y_hat(:,1)-C*xk_k1(:,1));
Pk_k = (eye(9)-K_k*C)*Pk_k1;

for k=2:length(tiempo)
    xk_k1(:,k) = A*xk_k(:,k-1);
    Pk_k1 = A*Pk_k*A' + B*Q*B';
    K_k = Pk_k1*C'*inv(C*Pk_k1*C'+R);
    xk_k(:,k) = xk_k1(:,k)+K_k*(y_hat(:,k)-C*xk_k1(:,k));
    Pk_k = (eye(9)-K_k*C)*Pk_k1;
end

figure
hold all
plot3(y(1,:),y(2,:),y(3,:))
plot3(xk_k1(1,:),xk_k1(2,:),xk_k1(3,:))
grid on

figure
subplot(3,1,1);
plot(tiempo,y(1,:)-xk_k1(1,:));
subplot(3,1,2);
plot(tiempo,y(2,:)-xk_k1(2,:));
subplot(3,1,3);
plot(tiempo,y(3,:)-xk_k1(3,:));

%% Prediccion (uniforme)
eta = (2*rand(length(tiempo),3)'-1)*sigma*3;
y = [Pos]';
y_hat = y + eta;

xk_k1 = zeros(9,length(tiempo));
xk_k =  zeros(9,length(tiempo));

xk_k1(:,1) = A*x0;
Pk_k1 = A*P0_0*A' + B*Q*B';
K_k = Pk_k1*C'*inv(C*Pk_k1*C'+R);
xk_k(:,1) = xk_k1(:,1)+K_k*(y_hat(:,1)-C*xk_k1(:,1));
Pk_k = (eye(9)-K_k*C)*Pk_k1;

for k=2:length(tiempo)
    xk_k1(:,k) = A*xk_k(:,k-1);
    Pk_k1 = A*Pk_k*A' + B*Q*B';
    K_k = Pk_k1*C'*inv(C*Pk_k1*C'+R);
    xk_k(:,k) = xk_k1(:,k)+K_k*(y_hat(:,k)-C*xk_k1(:,k));
    Pk_k = (eye(9)-K_k*C)*Pk_k1;
end

figure
hold all
plot3(y(1,:),y(2,:),y(3,:))
plot3(xk_k1(1,:),xk_k1(2,:),xk_k1(3,:))
grid on

figure
subplot(3,1,1);
plot(tiempo,y(1,:)-xk_k1(1,:));
subplot(3,1,2);
plot(tiempo,y(2,:)-xk_k1(2,:));
subplot(3,1,3);
plot(tiempo,y(3,:)-xk_k1(3,:));

%% Prediccion (gaussiano p y v)

sigma_p = 10;
sigma_v = 0.2;
eta = [randn(length(tiempo),3)'*sigma_p
    rand(length(tiempo),3)'*sigma_v];
C = [eye(3) zeros(3) zeros(3)
    zeros(3) eye(3)  zeros(3)];
R = [sigma_p^2*eye(3) zeros(3)
    zeros(3)  sigma_v^2*eye(3)]; 
y = [Pos Vel]';
y_hat = y + eta;

xk_k1 = zeros(9,length(tiempo));
xk_k =  zeros(9,length(tiempo));

xk_k1(:,1) = A*x0;
Pk_k1 = A*P0_0*A' + B*Q*B';
K_k = Pk_k1*C'*inv(C*Pk_k1*C'+R);
xk_k(:,1) = xk_k1(:,1)+K_k*(y_hat(:,1)-C*xk_k1(:,1));
Pk_k = (eye(9)-K_k*C)*Pk_k1;

for k=2:length(tiempo)
    xk_k1(:,k) = A*xk_k(:,k-1);
    Pk_k1 = A*Pk_k*A' + B*Q*B';
    K_k = Pk_k1*C'*inv(C*Pk_k1*C'+R);
    xk_k(:,k) = xk_k1(:,k)+K_k*(y_hat(:,k)-C*xk_k1(:,k));
    Pk_k = (eye(9)-K_k*C)*Pk_k1;
end

figure
hold all
plot3(y(1,:),y(2,:),y(3,:))
plot3(xk_k1(1,:),xk_k1(2,:),xk_k1(3,:))
grid on

figure
subplot(3,1,1);
plot(tiempo,y(1,:)-xk_k1(1,:));
subplot(3,1,2);
plot(tiempo,y(2,:)-xk_k1(2,:));
subplot(3,1,3);
plot(tiempo,y(3,:)-xk_k1(3,:));

figure
subplot(3,1,1);
plot(tiempo,y(4,:)-xk_k1(4,:));
subplot(3,1,2);
plot(tiempo,y(5,:)-xk_k1(5,:));
subplot(3,1,3);
plot(tiempo,y(6,:)-xk_k1(6,:));
