close all;
clear all;
clc;

load('ensayo.mat');

%constantes
g=9.8;
varNoise=[0.25 0.64];
pos_0 = [0 0];
vel_0 = [1 3];

%Ax+r=b
%b son las aceleraciones
%r es el ruido blanco
%Las filas de A son -g*sen(Tita_k) | 1 
%X es vector a estimar: (1+k_x | sesgo_x)^t

%Se ignora r, y se estima X usando cuadrados minimos. Ax ~= b

b_x = datos(:,1);  % Aceleraciones en x

A_x = [-g.*sin(tita) ones(1,length(tita))']; 

x_x = A_x\b_x; %Resolucion del sistema por cuadrados minimos

sesgo_x = x_x(2) %Estimador del sesgo en x
k_x = x_x(1) - 1 %Estimador del error de escalado en x

covar_x=(A_x'*A_x)^-1;
covk_x = covar_x(1,1)*varNoise(1);
covsesgo_x = covar_x(2,2)*varNoise(1);


b_y = datos(:,2);  % Aceleraciones en y
A_y = [-g.*cos(tita) ones(1,length(tita))'];

x_y = A_y\b_y; %Resolucion del sistema por cuadrados minimos

sesgo_y = x_y(2) %Estimador del sesgo en y
k_y = x_y(1) - 1 %Estimador del error de escalado en y

covar_y=(A_y'*A_y)^-1;
covk_y = covar_y(1,1)*varNoise(2);
covsesgo_y = covar_y(2,2)*varNoise(2);

%% Punto 3
load('acel.mat');
load('puntos.mat');

Areal(:,1) = (Aerr(:,1) - sesgo_x)/(1+k_x); %Estimacion de las aceleraciones reales en x
Areal(:,2) = (Aerr(:,2) - sesgo_y)/(1+k_y); %Estimacion de las aceleraciones reales en y

dt = t(2) - t(1); %Tiempo entre muestras

Vreal(:,1) = cumtrapz(Areal(:,1))*dt + vel_0(1); %Integracion numerica de la aceleracion en x
Vreal(:,2) = cumtrapz(Areal(:,2))*dt + vel_0(2); %Integracion numerica de la aceleracion en y

Preal(:,1) = cumtrapz(Vreal(:,1))*dt; %Integracion numerica de la velocidad en x
Preal(:,2) = cumtrapz(Vreal(:,2))*dt; %Integracion numerica de la velocidad en y

Verr(:,1) = cumtrapz(Aerr(:,1))*dt + vel_0(1); %Integracion numerica de la aceleracion en x
Verr(:,2) = cumtrapz(Aerr(:,2))*dt + vel_0(2); %Integracion numerica de la aceleracion en y

Perr(:,1) = cumtrapz(Verr(:,1))*dt; %Integracion numerica de la velocidad en x
Perr(:,2) = cumtrapz(Verr(:,2))*dt; %Integracion numerica de la velocidad en y

figure('name','Trayectoria del vehículo')

title('Trayectoria en el plano')
xlabel('Posición en el eje x')
ylabel('Posición en el eje y')
grid on
hold on

plot(Preal(:,1),Preal(:,2),'r');
plot(Perr(:,1),Perr(:,2),'k');

% Posibles puntos de llegada
scatter(A(:,1),A(:,2),'r'); 
scatter(B(:,1),B(:,2),'g');
scatter(C(:,1),C(:,2),'b');
scatter(D(:,1),D(:,2),'k');

dots = [A;B;C;D]

distancias = sqrt((dots(:,1) - Preal(length(Preal),1)).^2 + (dots(:,2)-Preal(length(Preal),2)).^2);
[d_c final_dot] = min(distancias)


%% Punto 4

% Distancia entre puntos de llegada

d_min = 10000;

% Menor distancia entre pares de posibles puntos de llegada
for i=1:4
    for j=i+1:4
        if norm(dots(i,:)-dots(j,:))<d_min
            d_min = norm(dots(i,:)-dots(j,:));
        end
    end
end

var_r = norm(varNoise);
A_max = 0;

% Maxima aceleracion estimada
for i=1:length(Areal)
    if norm(Areal(i,:))>A_max
        A_max = norm(Areal(i,:));
    end
end

% Cantidad minima de muestras para estimar
N_min = (t(length(t))^2*var_r)/d_min*(1+2*A_max/g^2);

sprintf('La cantidad de muestras minimas es %d',ceil(N_min))