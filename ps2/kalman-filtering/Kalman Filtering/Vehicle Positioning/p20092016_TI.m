clear all
close all
load('datos.mat')
clc 

h = 1;
sigma = 10;
eta = randn(length(tiempo),3)'*sigma;

x0 = [1e-6*ones(3,1)
      zeros(6,1)]; 
  
P0 = [1*eye(3) zeros(3) zeros(3)
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

x = x0;
P = P0;
ultimaMuestra = 1;

figure
hold all

P = dare(A',C',B*Q*B',R);
K = P*C'* inv(R+C*P*C')

% K =[0.4312         0         0
%          0    0.4312         0
%          0         0    0.4312
%     0.0751         0         0
%          0    0.0751         0
%          0         0    0.0751
%     0.0065         0         0
%          0    0.0065         0
%          0         0    0.0065];


%     [0.3145         0         0
%          0    0.3145         0
%          0         0    0.3145
%     0.0592         0         0
%          0    0.0592         0
%          0         0    0.0592
%     0.0055         0         0
%          0    0.0055         0
%          0         0    0.0055];

for k=1:length(tiempo)
    x = A*x;
    %P = A*P*A' + B*Q*B';
    %K = P*C'*inv(C*P*C'+R);
    
    if randi(100) < 50 || (k-ultimaMuestra)>=4
        x = x + K*(y_hat(:,k)-C*x);
        %P = (eye(9)-K*C)*P;
        ultimaMuestra = k;
        %fprintf('Actualizacion en T=%d\n',ultimaMuestra);
        
        plot3(y_hat(1,k),y_hat(2,k),y_hat(3,k),'r*');
    end
    
    xPred(:,k) = x;
end

plot3(y(1,:),y(2,:),y(3,:))
plot3(xPred(1,:),xPred(2,:),xPred(3,:),'*-')
grid on

figure
subplot(3,1,1);
plot(tiempo,y(1,:)-xPred(1,:));
subplot(3,1,2);
plot(tiempo,y(2,:)-xPred(2,:));
subplot(3,1,3);
plot(tiempo,y(3,:)-xPred(3,:));

