
clc
clear
close all

% El objetivo de este script es obtener la ventana de Dolph utilizando la
% formula vista en clase y compararla con la ventana de Dolph normalizada
% que se obtiene en Matlab.

% Puede usarse para diseñar un filtro por ventaneo en forma manual.

%% Parametros de ajuste:
M = 32; % Largo total de la ventana M + 1
a = 1; %20*a dB de atenuacion de lobulos secundarios


b = cosh(acosh(10^a)/M);
dBval = @(x) 20 * log10(abs(x));

%% Calculo de Matlab de la ventana
wD = chebwin(M+1,20*a);
wD = wD/sum(abs(wD)); % NO ESTA NORMALIZADA COMO LAS OTRAS!!

WD = fft(wD);


%% Calculo de la ventana en el dominio de la frecuencia:

% Valores donde calculo la ventana para usar la IFFT:
omegan = (0:1/(M+1):M/(M+1))*2; %2 equivale a 2*pi, muestreo para obtener la ventana

% Valores sobremuestreados para ver la forma real de la ventana:
omegaos = linspace(0,2*pi,128*2^4); % muestreo para ver la ventana verdadera


% Ventana calculada por mi
W0 = @(w) cos(M*acos(b * cos(w/2)))/cosh(M*acosh(b));

% Ancho del Lobulo principal:
MLW = 2*acos(1/(b))/pi;

%% Graficos:
figure(1)
hold off
plot(omegaos/pi,dBval(W0(omegaos)),'--')
hold on
plot(omegan,dBval(W0(omegan*pi)),'rd','markerfacecolor','r')
ylim([-50,0])
plot(MLW,-20*a,'dk','markerfacecolor','k','markersize',10)
ylabel('Amplitud (dB)')
xlabel('Frecuencia normalizada (x \pi)')
legend('Ventana continua','Ventana muestreada para hallar IFFT','Ancho del lobulo principal');

% Ventana en el dominio temporal
w0 = ifft(W0(omegan*pi).*exp(-1i*omegan*pi*M/2));
figure(2)
hold off
plot(0:M,wD)
hold on
plot(0:M,real(w0),'rd','markerfacecolor','r')
grid on
xlabel('Tiempo discreto')
ylabel('Amplitud')
legend('Ventana de Dolph hallada con chebwin (normalizada)','Ventana de Dolph computada')