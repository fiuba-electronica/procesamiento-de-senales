
clear
clc
close all

%% Ejemplo 4
%% Dise�ar un filtro tal que:

% Ganancia 0 por debajo de 
ws = 0.3*pi;  
% con ripple maximo:
deltas = 0.05;

% ganancia unitaria entre:
wp1 = 0.4*pi;
wp2 = 0.6*pi;
% con ripple:
deltap = 0.01;

% ganancia 2/3 por encima de 
wp3 = 0.8*pi;
% con el ripple deltap=0.01;

% El ripple en el salto de amplitud 1 sera deltas mientra que en el salto
% de amplitud 2/3 dara un ripple de 1/3*deltap si dise�amos para deltap. 
% Dise�amos entonces para:
delta = min([deltas,3*deltap,deltap])

% El ancho de la ventana da el ancho de la banda de paso, dise�amos para el
% minimo:
Deltaw = min(abs(ws-wp1), abs(wp2-wp3));
omegac1 = (ws+wp1)/2;
omegac2 = (wp2+wp3)/2;

deltadB = 20 * log10(delta);

hid = @(n,M,omegac1,omegac2) 2/3*sinc(n-M/2) - sinc(omegac1/pi*(n-M/2))*omegac1/pi...
    + 1/3 * sinc(omegac2/pi*(n-M/2))*omegac2/pi;


%% Ventana de Kaiser:
A = -deltadB;

betaK = @(A) (0.5842 *(A-21)^0.4 + 0.07886 *(A-21)) * (A>=21) * (A<=50) + ...
    0.1102 * (A-8.7) * (A>50);

MK = @(A) (A-8)/(2.285*Deltaw);

beta = betaK(A);
fprintf(['Beta de Kaiser es: %.2f\n'], beta)

M2 = MK(A);
fprintf(['M de Kaiser (redondeado hacia arriba) es: %.2f\n'], M2)
disp('M debe ser par porque el filtro es pasa alto. Tomo 46 porque 44 no va.');
M2 = floor(M2)+2;

n2 = 0:M2;

hid2 = hid(n2,M2,omegac1,omegac2);
w2 = kaiser(M2+1,beta);
% f2 = hid2;
f2 = w2.'.*hid2;
%% Grafico del filtro y los coeficientes
figure(1)
hold off
plot(n2,hid2)
hold on
plot(n2,w2,'r')
stem(n2,f2,'markerfacecolor','b')
legend('Filtro ideal truncado a ventanear','Ventana de Kaiser','Filtro obtenido por Kaiser')
grid on
xlabel('Tiempo discreto')
ylabel('Amplitud')

% Grafico de la respuesta en modulo
nfft = 1024;
omegan = 0:2/nfft:2*(nfft-1)/nfft;
F2 = fft(f2,nfft);
F2 = F2(1:nfft/2+1);
omegan = omegan(1:nfft/2+1);

% Respuesta en frecuencia en dB
figure(2)
plot(omegan,20*log10(abs(F2)),'r','linewidth',2)
axis tight
ylim([-60,1])
grid on
legend(['Respuesta por ventana de Kaiser - M=' num2str(M2)],...
    'location','southeast')
ylabel('Amplitud [dB]')
xlabel('Frecuencia normalizada')

% Respuesta en frecuencia en amplitud
figure(3)
hold off
plot(omegan,(abs(F2)),'r','linewidth',2)
axis tight
ylim([0,1.1])
grid on
legend(['Respuesta por ventana de Kaiser - M=' num2str(M2)],...
    'location','southeast')
ylabel('Amplitud')
xlabel('Frecuencia normalizada')
wp1 = 0.4*pi;
wp2 = 0.6*pi;
% con ripple:
deltap = 0.01;

% Funcion de error en veces
figure(4)
fspec = (omegan > wp1/pi) .* (omegan < wp2/pi) +  2/3 * (omegan > wp3/pi);
ErrorKaiser = abs(abs(F2)-fspec) .* ((omegan > wp1/pi) .* (omegan < wp2/pi)...
    +(omegan > wp3/pi)+(omegan < ws/pi));

plot(omegan,ErrorKaiser,'r','linewidth',2)
hold on
plot([0 ws/pi; wp1/pi, wp2/pi; wp3/pi, 1]', ...
    [deltas, deltas ;deltap, deltap; deltap, deltap]','k--','linewidth',2)
ylim([0,1.1*deltas])
grid on
legend('Error','Tolerancia permitida')
ylabel('Amplitud')
xlabel('Frecuencia normalizada')
title('Grafico del error frente a las tolerancias deseadas')

